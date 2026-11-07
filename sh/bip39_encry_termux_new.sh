#!/usr/bin/env bash
set -euo pipefail
# ============================================================
#  BIP39 助记词安全管理器  V3
#  核心: Argon2id + AES-256-CBC + HMAC-SHA256 (Encrypt-then-MAC)
#  新特性 (V3):
#   * v3 密文格式内嵌 KDF 参数 (argon2id:m:t:p:outlen) -> 跨平台互通
#     (iOS 32MB/p1 生成的密文可在 Linux/Termux 512MB/p4 上解密, 反之亦然)
#   * 保留 v1 / v2 向后兼容解密
#   * 全平台初始化进度条 (init_progress)
#   * iOS 二维码: 宽度+高度双检测, 字体调整后重测, 专用全屏布局
#   * 解密后统一 1/2 展示菜单 (三平台一致)
#  PLATFORM: termux
# ============================================================

############################
# 平台参数 (按 PLATFORM 分支)
############################
PLATFORM="termux"
case "$PLATFORM" in
    linux|termux)
        KDF_M=19   # 512 MiB
        KDF_P=4
        KDF_T=3
        PLATFORM_NAME="${PLATFORM^}"
        ;;
    ios)
        KDF_M=15   # 32 MiB (iSH 沙盒限制, 不得擅自提高)
        KDF_P=1
        KDF_T=3
        PLATFORM_NAME="iOS (iSH)"
        ;;
    *)
        KDF_M=19; KDF_P=4; KDF_T=3; PLATFORM_NAME="Generic" ;;
esac
OUTLEN=64   # argon2 -l 输出 64 字节 (AES key 32 + HMAC key 32)
VERSION="v3"
CIPHER_SUITE="argon2id:${KDF_M}:${KDF_T}:${KDF_P}:${OUTLEN}"

############################
# 异常退出与敏感变量清理
############################
cleanup() {
    unset mnemonic custom_entropy pass p1 p2 out enc blob original_blob 2>/dev/null || true
    unset key aes_key mac_key cipher mac salt iv raw_hex key_hex 2>/dev/null || true
    unset k1 k2 k1b test_plaintext test_password 2>/dev/null || true
    secure_clear 2>/dev/null || true
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM
trap 'echo; echo -e "${YELLOW}⚠️ 收到 SIGHUP，安全退出并清理...${NC}"; exit 129' HUP

############################
# 颜色
############################
RED="\033[31;1m"; GREEN="\033[32;1m"; YELLOW="\033[33;1m"; MAGENTA="\033[35;1m"
CYAN="\033[36;1m"; GRAY="\033[90m"; BOLD="\033[1m"; BLUE="\033[34;1m"; NC="\033[0m"

secure_clear() {
    clear 2>/dev/null || true
    printf "\033[H\033[2J\033[3J"
}

pause_return() {
    echo
    echo -e "${GRAY}────────────────────────────────────────────────────${NC}"
    echo -en "${BOLD}▶ 按回车键 (Enter) 返回主菜单并清屏...${NC}"
    read -r -s || true
    secure_clear
}

# 统一安全输入: 封装 EOF, 防止 set -e 下遇 EOF 崩溃
safe_read() {
    local _var="$1"; shift
    read -r "$@" "$_var" || return 1
}


############################
# 依赖与 bootstrap (按平台分支)
############################
need() { command -v "$1" >/dev/null 2>&1; }
CORE_DEPS=(argon2 openssl xxd)
OPTIONAL_DEPS=(qrencode)

do_bootstrap() {
    # 首次运行环境初始化 (iSH 走 apk; Termux 走 pkg; Linux 走 apt/dnf/pacman)
    case "$PLATFORM" in
        ios)
            if [ -z "$BASH_VERSION" ]; then
                echo "▶ 检测到 ash 环境，正在初始化..."; echo "▶ 安装核心组件 (bash, argon2, openssl, xxd)..."
                if [ -f /etc/apk/repositories ] && grep -q "apk.ish.app" /etc/apk/repositories 2>/dev/null; then
                    cp /etc/apk/repositories /etc/apk/repositories.bak.$(date +%s) 2>/dev/null || true
                fi
                apk update >/dev/null 2>&1 || echo "⚠️ apk update 异常，继续..."
                apk add bash argon2 openssl xxd --no-cache 2>/dev/null || { echo "❌ 核心依赖安装失败"; exit 1; }
                apk add libqrencode --no-cache 2>/dev/null || apk add libqrencode-tools --no-cache 2>/dev/null || true
            fi
            ;;
        termux)
            if ! need pkg; then echo "❌ 未检测到 Termux pkg 包管理器"; exit 1; fi
            # Termux 命令->包 映射 (命令名 != 包名):
            #   openssl(CLI) <- openssl-tool   tput <- ncurses-utils   qrencode(CLI) <- libqrencode
            local need_core=0
            for c in argon2 openssl xxd; do need "$c" || need_core=1; done
            if (( need_core )); then
                echo "▶ 正在安装核心依赖 (ncurses-utils argon2 openssl-tool xxd)..."
                pkg install -y ncurses-utils argon2 openssl-tool xxd 2>/dev/null \
                    || echo "⚠️ 核心依赖安装异常 (需 openssl-tool 提供 openssl 命令)"
            fi
            if ! need qrencode; then
                echo "▶ 安装可选二维码组件 (libqrencode)..."
                pkg install -y libqrencode >/dev/null 2>&1 || pkg install -y qrencode >/dev/null 2>&1 || true
            fi
            ;;
        *)
            # linux: 用户确认后才安装 (GPT6 P1: 不擅自 auto-update)
            for c in "${CORE_DEPS[@]}"; do
                if ! need "$c"; then
                    echo -e "${YELLOW}⚠️ 缺少核心依赖: $c，是否安装？[Y/n]:${NC}"; read -r a
                    [[ "${a,,}" == "n" ]] && { echo "取消"; return 1; }
                    if need apt; then sudo apt-get install -y "$c" >/dev/null 2>&1 || true
                    elif need dnf; then sudo dnf install -y "$c" >/dev/null 2>&1 || true
                    elif need pacman; then sudo pacman -Sy --noconfirm "$c" >/dev/null 2>&1 || true
                    else echo "❌ 未知包管理器"; return 1; fi
                fi
            done
            if ! need qrencode; then
                echo -e "${YELLOW}ℹ️ qrencode(可选,二维码)未安装, 核心功能不受影响${NC}"
            fi
            ;;
    esac
}

check_deps() {
    local miss=()
    for c in "${CORE_DEPS[@]}"; do need "$c" || miss+=("$c"); done
    if ((${#miss[@]})); then
        echo -e "${YELLOW}⚠️ 缺少依赖: ${miss[*]}，尝试自动安装...${NC}"
        do_bootstrap || true
        local miss2=()
        for c in "${CORE_DEPS[@]}"; do need "$c" || miss2+=("$c"); done
        if ((${#miss2[@]})); then
            echo -e "${RED}❌ 依赖仍缺失: ${miss2[*]}，请手动安装后重试${NC}"; exit 1
        fi
    fi
}

############################
# 密钥派生 (V3: 显式 KDF 参数, 跨平台互通)
# 用法: derive_key <pass> <salt> <m> <t> <p>
# 输出: 128 位十六进制 (64 字节): 前 32B=AES key, 后 32B=HMAC key
############################
derive_key() {
    local pass="$1" salt="$2" m="$3" t="$4" p="$5"
    local raw_hex key_hex
    # argon2 -r 因构建不同有两种输出形态:
    #   (a) 128 位十六进制文本(带换行) -> 经 xxd -p 二次编码为 256/258 hex
    #   (b) 64 字节原始二进制          -> 经 xxd -p 得 128 hex
    # 统一还原成 128 位有效十六进制
    raw_hex=$(printf "%s" "$pass" | \
      argon2 "$salt" -id -t "$t" -m "$m" -p "$p" -l "$OUTLEN" -r | \
      xxd -p | tr -d '\n') || return 1
    # 去掉可能混入的尾部 0a (xxd 对换行字节的编码)
    while [[ ${#raw_hex} -ge 2 && "${raw_hex: -2}" == "0a" ]]; do
        raw_hex="${raw_hex:0:${#raw_hex}-2}"
    done
    case ${#raw_hex} in
        128) key_hex="$raw_hex" ;;
        256) key_hex=$(printf "%s" "$raw_hex" | xxd -r -p) || return 1 ;;
        *) return 1 ;;
    esac
    # 最终防线: 恰好 128 位十六进制 (64 字节)
    [[ "$key_hex" =~ ^[0-9a-fA-F]{128}$ ]] || return 1
    printf "%s" "${key_hex,,}"
}

############################
# 平台默认参数派生 (v1/v2 向后兼容 + 自检; 无法得知旧密文来源平台)
derive_key_default() { derive_key "$1" "$2" "$KDF_M" "$KDF_T" "$KDF_P"; }

############################
# KDF 自检: 同口令两次一致 + 不同口令不同 + 跨参数可复现
############################
kdf_selftest() {
    local s; s=$(openssl rand -hex 16) || return 1
    local k1 k2 k1b
    k1=$(derive_key "selftest-A" "$s" "$KDF_M" "$KDF_T" "$KDF_P") || return 1
    k2=$(derive_key "selftest-B" "$s" "$KDF_M" "$KDF_T" "$KDF_P") || return 1
    k1b=$(derive_key "selftest-A" "$s" "$KDF_M" "$KDF_T" "$KDF_P") || return 1
    [[ "$k1" =~ ^[0-9a-f]{128}$ ]] || return 1
    [[ "$k1" != "$k2" ]] || return 1   # 不同口令 -> 不同密钥
    [[ "$k1" == "$k1b" ]] || return 1   # 确定性
    return 0
}


############################
# 加密 (V3: 密文内嵌 KDF 参数, 跨平台互通)
# 格式: v3:argon2id:<m>:<t>:<p>:<outlen>:<salt>:<iv>:<mac>:<cipher>
# 其中 m/t/p/outlen 为生成端平台参数; 解密端据此派生, 与本地平台无关
# ⚠️ 已知残余风险: 派生密钥经 openssl -K / -macopt 参数瞬时出现在进程参数,
#    同机他用户或可经 /proc/<pid>/cmdline 读到。仅限单用户离线设备。
############################
encrypt_secure() {
    local plaintext="$1" pass="$2"
    local salt iv key aes_key mac_key cipher mac header
    salt=$(openssl rand -hex 16) || return 1
    iv=$(openssl rand -hex 16) || return 1
    [[ ${#salt} -eq 32 && ${#iv} -eq 32 ]] || return 1

    # v3 用本平台 KDF 参数; 参数随密文存储, 解密端照用
    key=$(derive_key "$pass" "$salt" "$KDF_M" "$KDF_T" "$KDF_P") || return 1
    [[ ${#key} -eq 128 ]] || return 1
    aes_key="${key:0:64}"; mac_key="${key:64:64}"

    cipher=$(printf "%s" "$plaintext" | \
      openssl enc -aes-256-cbc -K "$aes_key" -iv "$iv" -base64 -A) || return 1
    [[ -n "$cipher" ]] || return 1

    header="v3:argon2id:${KDF_M}:${KDF_T}:${KDF_P}:${OUTLEN}"
    mac=$(printf "%s" "${header}:${salt}:${iv}:${cipher}" | \
      openssl dgst -sha256 -mac HMAC -macopt hexkey:"$mac_key" | \
      sed 's/^.*= //') || return 1
    [[ "$mac" =~ ^[0-9a-fA-F]{64}$ ]] || return 1

    printf "%s:%s:%s:%s:%s\n" "$header" "$salt" "$iv" "$mac" "$cipher"
}

############################
# 恒定时间比较 (HMAC 校验; shell 层尽力而为)
############################
ct_equal() {
    local a="${1,,}" b="${2,,}" i diff=0 ca cb
    [[ ${#a} -eq ${#b} ]] || return 1
    for ((i=0; i<${#a}; i++)); do
        printf -v ca '%d' "'${a:i:1}"; printf -v cb '%d' "'${b:i:1}"
        diff=$(( diff | (ca ^ cb) ))
    done
    [[ $diff -eq 0 ]]
}

############################
# 解密: 兼容 v3 (KDF 参数在密文内) / v2 (四段+版本) / v1 (四段无版本)
############################
decrypt_secure() {
    local blob="$1" pass="$2"
    local ver kdf_m="$KDF_M" kdf_t="$KDF_T" kdf_p="$KDF_P" outlen="$OUTLEN"
    local body salt iv mac cipher

    if [[ "$blob" == v3:* ]]; then
        ver="v3"; body="${blob#v3:}"
        # 9 字段: argon2id:m:t:p:outlen:salt:iv:mac:cipher
        local kdf_hdr _m _t _p _o
        IFS=: read -r kdf_hdr _m _t _p _o salt iv mac cipher <<< "$body"
        [[ "$kdf_hdr" == "argon2id" ]] || return 1
        [[ -n "$_m" && -n "$_t" && -n "$_p" && -n "$_o" ]] || return 1
        [[ "$_m" =~ ^[0-9]+$ && "$_t" =~ ^[0-9]+$ && "$_p" =~ ^[0-9]+$ && "$_o" =~ ^[0-9]+$ ]] || return 1
        kdf_m="$_m"; kdf_t="$_t"; kdf_p="$_p"; outlen="$_o"
    elif [[ "$blob" == v2:* ]]; then
        ver="v2"; body="${blob#v2:}"
        IFS=: read -r salt iv mac cipher <<< "$body"
    else
        ver="v1"; body="$blob"
        IFS=: read -r salt iv mac cipher <<< "$body"
    fi

    # 严格字段/长度校验 (GPT6 P0: Argon2 前拦截畸形输入)
    [[ "$salt" =~ ^[0-9a-fA-F]{32}$ ]] || return 1
    [[ "$iv"   =~ ^[0-9a-fA-F]{32}$ ]] || return 1
    [[ "$mac"  =~ ^[0-9a-fA-F]{64}$ ]] || return 1
    [[ -n "$cipher" ]] || return 1
    [[ "$cipher" =~ ^[A-Za-z0-9+/]*={0,2}$ ]] || return 1
    if (( ${#cipher} > 8192 )); then return 1; fi

    local key aes_key mac_key calc_mac mac_input
    key=$(derive_key "$pass" "$salt" "$kdf_m" "$kdf_t" "$kdf_p") || return 1
    [[ ${#key} -eq 128 ]] || return 1
    aes_key="${key:0:64}"; mac_key="${key:64:64}"

    case "$ver" in
        v3) mac_input="v3:argon2id:${kdf_m}:${kdf_t}:${kdf_p}:${outlen}:${salt}:${iv}:${cipher}" ;;
        v2) mac_input="v2:${salt}:${iv}:${cipher}" ;;
        v1) mac_input="${salt}${iv}${cipher}" ;;
    esac
    calc_mac=$(printf "%s" "$mac_input" | \
      openssl dgst -sha256 -mac HMAC -macopt hexkey:"$mac_key" | sed 's/^.*= //') || return 1
    [[ "$calc_mac" =~ ^[0-9a-fA-F]{64}$ ]] || return 1
    ct_equal "$mac" "$calc_mac" || return 1

    printf "%s" "$cipher" | openssl enc -d -aes-256-cbc -K "$aes_key" -iv "$iv" -base64 -A
}

############################
# 全链路密码学自检 (V3 固定测试向量 + 篡改 + 错误口令)
############################
crypto_selftest() {
    local pt="abandon ability able about above absent absent absent absent absent absent absent"
    local pw="crypto-selftest-pw-2026!@#"
    local enc dec
    enc=$(encrypt_secure "$pt" "$pw") || return 1
    [[ "$enc" == v3:* ]] || return 1
    dec=$(decrypt_secure "$enc" "$pw") || return 1
    [[ "$dec" == "$pt" ]] || return 1
    dec=$(decrypt_secure "$enc" "$pw") || return 1
    [[ "$dec" == "$pt" ]] || return 1
    local prefix="${enc%:*}:"; local cpart="${enc##*:}"; local tampered
    if [[ "${cpart:0:1}" == "A" ]]; then tampered="${prefix}B${cpart:1}"; else tampered="${prefix}A${cpart:1}"; fi
    if decrypt_secure "$tampered" "$pw" 2>/dev/null; then return 1; fi
    if decrypt_secure "$enc" "wrong-password-xyz-999" 2>/dev/null; then return 1; fi
    if decrypt_secure "${enc:0:20}" "$pw" 2>/dev/null; then return 1; fi
    if decrypt_secure "v3:argon2id:19:3:4:64:bad!!!!:::" "$pw" 2>/dev/null; then return 1; fi
    return 0
}

############################
# 初始化进度条 (全平台): [████████░░░░] NN% 步骤 x/y
############################
init_progress() {
    local step="$1" total="$2" label="$3"
    local barwidth=24 filled empty i out=""
    filled=$(( barwidth * step / total ))
    (( filled > barwidth )) && filled=$barwidth
    empty=$(( barwidth - filled ))
    for ((i=0;i<filled;i++)); do out+="█"; done
    for ((i=0;i<empty;i++)); do out+="░"; done
    local pct=$(( 100 * step / total ))
    printf "\r${CYAN}[%s]${NC} ${GRAY}%3d%%${NC}  步骤 %d/%d  %s${NC}" \
        "$out" "$pct" "$step" "$total" "$label"
    printf "\n"
}

############################
# 二维码输出 (GPT6 原版 + 撕裂防护)
#  - qrencode -l L -m 1 -t UTF8i (最小静区, 最窄终端渲染)
#  - 渲染后实测二维码所需显示列; 终端不够宽 -> 循环提示缩字/横屏并每次重测,
#    直到放得下才输出 (避免折行撕裂); 持续放不下 -> 退回纯文本兜底
############################
get_term_cols() {
    local cols
    cols=$(tput cols 2>/dev/null || stty size 2>/dev/null | awk '{print $2}')
    if [[ -z "$cols" || "$cols" -le 0 ]]; then cols="${COLUMNS:-80}"; fi
    printf '%s' "$cols"
}

# 渲染 + 列宽检测 + 循环等待 + 文本兜底
qr_fit_show() {
    local text="$1"
    if ! command -v qrencode >/dev/null 2>&1; then
        echo -e "${YELLOW}（未检测到 qrencode，二维码不可用；请安装 qrencode 后启用：Termux=pkg install libqrencode / iSH=apk add libqrencode / Linux=apt install qrencode）${NC}"
        return 0
    fi
    local qr
    if ! qr=$(printf '%s' "$text" | qrencode -l L -m 1 -t UTF8i 2>/dev/null); then
        # UTF8i 渲染失败则退化为普通渲染 (可能撕裂但保证可见)
        printf '%s' "$text" | qrencode -l L -m 1 -t UTF8 2>/dev/null || \
        echo -e "${RED}二维码渲染失败，请手动保存上方文本${NC}"
        return 0
    fi
    # 实测二维码所需显示列: 取最宽行的字节数, 按 UTF8i 实测 ~2.6 字节/列,
    # 用 /2.4 保守上取整 (略高估, 宁多提示不撕裂)
    local bytew need
    bytew=$(printf '%s\n' "$qr" | LC_ALL=C awk '{if (length($0)>m) m=length($0)} END{print m+0}')
    need=$(( (bytew * 5 + 11) / 12 ))   # ≈ ceil(bytew / 2.4)
    (( need < 8 )) && need=8

    local cols tries=0 ans
    while :; do
        cols=$(get_term_cols)
        if (( cols >= need )); then
            break
        fi
        tries=$((tries+1))
        echo -e "${YELLOW}📱 二维码需约 ${RED}${need}${YELLOW} 列完整显示，当前终端仅 ${RED}${cols}${YELLOW} 列，直接渲染会折行撕裂。${NC}"
        echo -e "${CYAN}   请【双指缩小字体】或【旋转横屏】让终端宽度达到 ${need} 列以上，完成后按回车重新检测。${NC}"
        echo -en "${BOLD}   ▶ 已调整按回车重试 / 输入 q 放弃二维码仅看文本 : ${NC}"
        IFS= read -r ans || ans="q"
        [[ "${ans,,}" == "q" || "${ans,,}" == "quit" || "${ans,,}" == "退出" ]] && { echo; echo -e "${YELLOW}已放弃二维码，请直接抄录上方文本（切勿 Ctrl+C 复制密文到联网设备）：${NC}"; echo -e "${BOLD}${text}${NC}"; return 0; }
        if (( tries >= 5 )); then
            echo; echo -e "${YELLOW}多次重试仍未达到所需宽度，转为纯文本展示（避免撕裂）：${NC}"
            echo -e "${BOLD}${text}${NC}"
            return 0
        fi
    done
    echo
    echo -e "${CYAN}────────────── [ 二维码（内存瞬时渲染·不写文件） ] ──────────────${NC}"
    printf '%s\n' "$qr"
    echo -e "${CYAN}──────────────────────────────────────────────────────────────────${NC}"
}

print_qr() {
    # 三平台统一: 实测二维码宽度 + 循环等待终端够宽 + 文本兜底 (防撕裂)
    qr_fit_show "$1"
}
############################
# BIP39 2048 词表 (内嵌, 无外部依赖)
############################
wordlist=(abandon ability able about above absent absorb abstract absurd abuse access accident account accuse achieve acid acoustic acquire across act action actor actress actual adapt add addict address adjust admit adult advance advice aerobic affair afford afraid again age agent agree ahead aim air airport aisle alarm album alcohol alert alien all alley allow almost alone alpha already also alter always amateur amazing among amount amused analyst anchor ancient anger angle angry animal ankle announce annual another answer antenna antique anxiety any apart apology appear apple approve april arch arctic area arena argue arm armed armor army around arrange arrest arrive arrow art artefact artist artwork ask aspect assault asset assist assume asthma athlete atom attack attend attitude attract auction audit august aunt author auto autumn average avocado avoid awake aware away awesome awful awkward axis baby bachelor bacon badge bag balance balcony ball bamboo banana banner bar barely bargain barrel base basic basket battle beach bean beauty because become beef before begin behave behind believe below belt bench benefit best betray better between beyond bicycle bid bike bind biology bird birth bitter black blade blame blanket blast bleak bless blind blood blossom blouse blue blur blush board boat body boil bomb bone bonus book boost border boring borrow boss bottom bounce box boy bracket brain brand brass brave bread breeze brick bridge brief bright bring brisk broccoli broken bronze broom brother brown brush bubble buddy budget buffalo build bulb bulk bullet bundle bunker burden burger burst bus business busy butter buyer buzz cabbage cabin cable cactus cage cake call calm camera camp can canal cancel candy cannon canoe canvas canyon capable capital captain car carbon card cargo carpet carry cart case cash casino castle casual cat catalog catch category cattle caught cause caution cave ceiling celery cement census century cereal certain chair chalk champion change chaos chapter charge chase chat cheap check cheese chef cherry chest chicken chief child chimney choice choose chronic chuckle chunk churn cigar cinnamon circle citizen city civil claim clap clarify claw clay clean clerk clever click client cliff climb clinic clip clock clog close cloth cloud clown club clump cluster clutch coach coast coconut code coffee coil coin collect color column combine come comfort comic common company concert conduct confirm congress connect consider control convince cook cool copper copy coral core corn correct cost cotton couch country couple course cousin cover coyote crack cradle craft cram crane crash crater crawl crazy cream credit creek crew cricket crime crisp critic crop cross crouch crowd crucial cruel cruise crumble crunch crush cry crystal cube culture cup cupboard curious current curtain curve cushion custom cute cycle dad damage damp dance danger daring dash daughter dawn day deal debate debris decade december decide decline decorate decrease deer defense define defy degree delay deliver demand demise denial dentist deny depart depend deposit depth deputy derive describe desert design desk despair destroy detail detect develop device devote diagram dial diamond diary dice diesel diet differ digital dignity dilemma dinner dinosaur direct dirt disagree discover disease dish dismiss disorder display distance divert divide divorce dizzy doctor document dog doll dolphin domain donate donkey donor door dose double dove draft dragon drama drastic draw dream dress drift drill drink drip drive drop drum dry duck dumb dune during dust dutch duty dwarf dynamic eager eagle early earn earth easily east easy echo ecology economy edge edit educate effort egg eight either elbow elder electric elegant element elephant elevator elite else embark embody embrace emerge emotion employ empower empty enable enact end endless endorse enemy energy enforce engage engine enhance enjoy enlist enough enrich enroll ensure enter entire entry envelope episode equal equip era erase erode erosion error erupt escape essay essence estate eternal ethics evidence evil evoke evolve exact example excess exchange excite exclude excuse execute exercise exhaust exhibit exile exist exit exotic expand expect expire explain expose express extend extra eye eyebrow fabric face faculty fade faint faith fall false fame family famous fan fancy fantasy farm fashion fat fatal father fatigue fault favorite feature february federal fee feed feel female fence festival fetch fever few fiber fiction field figure file film filter final find fine finger finish fire firm first fiscal fish fit fitness fix flag flame flash flat flavor flee flight flip float flock floor flower fluid flush fly foam focus fog foil fold follow food foot force forest forget fork fortune forum forward fossil foster found fox fragile frame frequent fresh friend fringe frog front frost frown frozen fruit fuel fun funny furnace fury future gadget gain galaxy gallery game gap garage garbage garden garlic garment gas gasp gate gather gauge gaze general genius genre gentle genuine gesture ghost giant gift giggle ginger giraffe girl give glad glance glare glass glide glimpse globe gloom glory glove glow glue goat goddess gold good goose gorilla gospel gossip govern gown grab grace grain grant grape grass gravity great green grid grief grit grocery group grow grunt guard guess guide guilt guitar gun gym habit hair half hammer hamster hand happy harbor hard harsh harvest hat have hawk hazard head health heart heavy hedgehog height hello helmet help hen hero hidden high hill hint hip hire history hobby hockey hold hole holiday hollow home honey hood hope horn horror horse hospital host hotel hour hover hub huge human humble humor hundred hungry hunt hurdle hurry hurt husband hybrid ice icon idea identify idle ignore ill illegal illness image imitate immense immune impact impose improve impulse inch include income increase index indicate indoor industry infant inflict inform inhale inherit initial inject injury inmate inner innocent input inquiry insane insect inside inspire install intact interest into invest invite involve iron island isolate issue item ivory jacket jaguar jar jazz jealous jeans jelly jewel job join joke journey joy judge juice jump jungle junior junk just kangaroo keen keep ketchup key kick kid kidney kind kingdom kiss kit kitchen kite kitten kiwi knee knife knock know lab label labor ladder lady lake lamp language laptop large later latin laugh laundry lava law lawn lawsuit layer lazy leader leaf learn leave lecture left leg legal legend leisure lemon lend length lens leopard lesson letter level liar liberty library license life lift light like limb limit link lion liquid list little live lizard load loan lobster local lock logic lonely long loop lottery loud lounge love loyal lucky luggage lumber lunar lunch luxury lyrics machine mad magic magnet maid mail main major make mammal man manage mandate mango mansion manual maple marble march margin marine market marriage mask mass master match material math matrix matter maximum maze meadow mean measure meat mechanic medal media melody melt member memory mention menu mercy merge merit merry mesh message metal method middle midnight milk million mimic mind minimum minor minute miracle mirror misery miss mistake mix mixed mixture mobile model modify mom moment monitor monkey monster month moon moral more morning mosquito mother motion motor mountain mouse move movie much muffin mule multiply muscle museum mushroom music must mutual myself mystery myth naive name napkin narrow nasty nation nature near neck need negative neglect neither nephew nerve nest net network neutral never news next nice night noble noise nominee noodle normal north nose notable note nothing notice novel now nuclear number nurse nut oak obey object oblige obscure observe obtain obvious occur ocean october odor off offer office often oil okay old olive olympic omit once one onion online only open opera opinion oppose option orange orbit orchard order ordinary organ orient original orphan ostrich other outdoor outer output outside oval oven over own owner oxygen oyster ozone pact paddle page pair palace palm panda panel panic panther paper parade parent park parrot party pass patch path patient patrol pattern pause pave payment peace peanut pear peasant pelican pen penalty pencil people pepper perfect permit person pet phone photo phrase physical piano picnic picture piece pig pigeon pill pilot pink pioneer pipe pistol pitch pizza place planet plastic plate play please pledge pluck plug plunge poem poet point polar pole police pond pony pool popular portion position possible post potato pottery poverty powder power practice praise predict prefer prepare present pretty prevent price pride primary print priority prison private prize problem process produce profit program project promote proof property prosper protect proud provide public pudding pull pulp pulse pumpkin punch pupil puppy purchase purity purpose purse push put puzzle pyramid quality quantum quarter question quick quit quiz quote rabbit raccoon race rack radar radio rail rain raise rally ramp ranch random range rapid rare rate rather raven raw razor ready real reason rebel rebuild recall receive recipe record recycle reduce reflect reform refuse region regret regular reject relax release relief rely remain remember remind remove render renew rent reopen repair repeat replace report require rescue resemble resist resource response result retire retreat return reunion reveal review reward rhythm rib ribbon rice rich ride ridge rifle right rigid ring riot ripple risk ritual rival river road roast robot robust rocket romance roof rookie room rose rotate rough round route royal rubber rude rug rule run runway rural sad saddle sadness safe sail salad salmon salon salt salute same sample sand satisfy satoshi sauce sausage save say scale scan scare scatter scene scheme school science scissors scorpion scout scrap screen script scrub sea search season seat second secret section security seed seek segment select sell seminar senior sense sentence series service session settle setup seven shadow shaft shallow share shed shell sheriff shield shift shine ship shiver shock shoe shoot shop short shoulder shove shrimp shrug shuffle shy sibling sick side siege sight sign silent silk silly silver similar simple since sing siren sister situate six size skate sketch ski skill skin skirt skull slab slam sleep slender slice slide slight slim slogan slot slow slush small smart smile smoke smooth snack snake snap sniff snow soap soccer social sock soda soft solar soldier solid solution solve someone song soon sorry sort soul sound soup source south space spare spatial spawn speak special speed spell spend sphere spice spider spike spin spirit split spoil sponsor spoon sport spot spray spread spring spy square squeeze squirrel stable stadium staff stage stairs stamp stand start state stay steak steel stem step stereo stick still sting stock stomach stone stool story stove strategy street strike strong struggle student stuff stumble style subject submit subway success such sudden suffer sugar suggest suit summer sun sunny sunset super supply supreme sure surface surge surprise surround survey suspect sustain swallow swamp swap swarm swear sweet swift swim swing switch sword symbol symptom syrup system table tackle tag tail talent talk tank tape target task taste tattoo taxi teach team tell ten tenant tennis tent term test text thank that theme then theory there they thing this thought three thrive throw thumb thunder ticket tide tiger tilt timber time tiny tip tired tissue title toast tobacco today toddler toe together toilet token tomato tomorrow tone tongue tonight tool tooth top topic topple torch tornado tortoise toss total tourist toward tower town toy track trade traffic tragic train transfer trap trash travel tray treat tree trend trial tribe trick trigger trim trip trophy trouble truck true truly trumpet trust truth try tube tuition tumble tuna tunnel turkey turn turtle twelve twenty twice twin twist two type typical ugly umbrella unable unaware uncle uncover under undo unfair unfold unhappy uniform unique unit universe unknown unlock until unusual unveil update upgrade uphold upon upper upset urban urge usage use used useful useless usual utility vacant vacuum vague valid valley valve van vanish vapor various vast vault vehicle velvet vendor venture venue verb verify version very vessel veteran viable vibrant vicious victory video view village vintage violin virtual virus visa visit visual vital vivid vocal voice void volcano volume vote voyage wage wagon wait walk wall walnut want warfare warm warrior wash wasp waste water wave way wealth weapon wear weasel weather web wedding weekend weird welcome west wet whale what wheat wheel when where whip whisper wide width wife wild will win window wine wing wink winner winter wire wisdom wise wish witness wolf woman wonder wood wool word work world worry worth wrap wreck wrestle wrist write wrong yard year yellow you young youth zebra zero zone zoo)

############################
# 词表完整性自检 + 单词索引
# 指纹 = 2048 词逐行拼接 SHA256, 与内置常量比对, 拦截词表篡改/截断
############################
WORDLIST_SHA256="2f5eed53a4727b4bf8880d8f3f199efc90e58503646d9ff8eff3a2ed3b24dbda"
declare -A WORD_INDEX=()

check_wordlist() {
    [[ ${#wordlist[@]} -eq 2048 ]] || return 1
    [[ "${wordlist[0]}" == "abandon" && "${wordlist[2047]}" == "zoo" ]] || return 1
    local fp
    fp=$(printf '%s\n' "${wordlist[@]}" | openssl dgst -sha256 | sed 's/^.*= //') || return 1
    [[ "${fp,,}" == "$WORDLIST_SHA256" ]] || return 1
    return 0
}
build_word_index() {
    local i; WORD_INDEX=()
    for ((i=0; i<${#wordlist[@]}; i++)); do WORD_INDEX["${wordlist[$i]}"]=$i; done
}

############################
# 二进制串 <-> 十六进制
############################
bin2hex() {
    local bin="$1" out="" i chunk
    for ((i=0; i<${#bin}; i+=4)); do
        chunk="${bin:i:4}"
        case "$chunk" in
            0000) out+="0" ;; 0001) out+="1" ;; 0010) out+="2" ;; 0011) out+="3" ;;
            0100) out+="4" ;; 0101) out+="5" ;; 0110) out+="6" ;; 0111) out+="7" ;;
            1000) out+="8" ;; 1001) out+="9" ;; 1010) out+="a" ;; 1011) out+="b" ;;
            1100) out+="c" ;; 1101) out+="d" ;; 1110) out+="e" ;; 1111) out+="f" ;;
            *) return 1 ;;
        esac
    done
    printf "%s" "$out"
}
hex2bin() {
    local hex="${1,,}" bin=""
    for ((i=0; i<${#hex}; i++)); do
        case "${hex:i:1}" in
            0) bin+="0000" ;; 1) bin+="0001" ;; 2) bin+="0010" ;; 3) bin+="0011" ;;
            4) bin+="0100" ;; 5) bin+="0101" ;; 6) bin+="0110" ;; 7) bin+="0111" ;;
            8) bin+="1000" ;; 9) bin+="1001" ;; a) bin+="1010" ;; b) bin+="1011" ;;
            c) bin+="1100" ;; d) bin+="1101" ;; e) bin+="1110" ;; f) bin+="1111" ;;
            *) return 1 ;;
        esac
    done
    printf "%s" "$bin"
}

############################
# BIP39 反向校验: 词数∈{12,15,18,21,24} + 词表内 + 校验和正确
############################
validate_mnemonic() {
    local phrase="$1"
    local -a words=()
    read -r -a words <<< "$phrase"
    local n=${#words[@]}
    case "$n" in 12|15|18|21|24) ;; *) return 1 ;; esac
    if (( ${#WORD_INDEX[@]} == 0 )); then build_word_index; fi
    local full_bin="" w idx j b
    for w in "${words[@]}"; do
        idx="${WORD_INDEX[$w]:-}"; [[ -n "$idx" ]] || return 1
        b=""
        for ((j=10; j>=0; j--)); do b+="$(( (idx >> j) & 1 ))"; done
        full_bin+="$b"
    done
    local total=${#full_bin}
    local ent_bits=$(( total * 32 / 33 ))
    local cs_bits=$(( total / 33 ))
    local ent_bin="${full_bin:0:$ent_bits}"
    local cs_expected="${full_bin:$ent_bits:$cs_bits}"
    local ent_hex hash_hex hash_bin cs_actual
    ent_hex=$(bin2hex "$ent_bin") || return 1
    hash_hex=$(printf "%s" "$ent_hex" | xxd -r -p | openssl dgst -sha256 -binary | xxd -p | tr -d '\n') || return 1
    hash_bin=$(hex2bin "$hash_hex") || return 1
    cs_actual="${hash_bin:0:$cs_bits}"
    [[ "$cs_expected" == "$cs_actual" ]]
}

############################
# 全量 CSPRNG (单一可信 OpenSSL 源; GPT6 P1: 改名, 不假装双源)
############################
secure_random_hex() {
    local bytes="$1" openssl_cmd hex
    openssl_cmd="$(resolve_openssl_cmd)"
    [[ -n "$openssl_cmd" ]] || { echo -e "${RED}❌ 找不到 openssl${NC}" >&2; return 1; }
    hex=$($openssl_cmd rand -hex "$bytes") || return 1
    [[ ${#hex} -eq $(( bytes * 2 )) ]] || { echo -e "${RED}❌ openssl rand 长度异常${NC}" >&2; return 1; }
    printf '%s' "$hex"
}
# 保留旧名向后兼容
double_rand() { secure_random_hex "$1"; }

resolve_openssl_cmd() {
    if command -v openssl >/dev/null 2>&1; then echo openssl
    elif [ -x "${PREFIX:-}/bin/openssl" ]; then echo "${PREFIX:-}/bin/openssl"
    elif [ -x "$HOME/.termux/bin/openssl" ]; then echo "$HOME/.termux/bin/openssl"
    elif [ -x "$HOME/.local/bin/openssl" ]; then echo "$HOME/.local/bin/openssl"
    else
        for p in /usr/bin/openssl /usr/local/bin/openssl "${PREFIX:-}/bin/openssl" "$HOME/.local/bin/openssl"; do
            [ -x "$p" ] && { echo "$p"; return; }
        done
        echo ""
    fi
}

############################
# 熵自检: 4096B 样本, 全零/全F + 卡方 (诊断级, 非安全证明)
############################
check_entropy() {
    local o cmd sample_hex result
    o=$(secure_random_hex 4096) || { echo -e "${RED}❌ 熵源随机失败${NC}" >&2; return 1; }
    [[ ${#o} -eq 8192 ]] || { echo -e "${RED}❌ openssl rand 长度异常${NC}" >&2; return 1; }
    result=$(printf '%s' "$o" | awk '
        BEGIN { chi2=0; all_zero=1; all_f=1; n=0
                for (k=0;k<256;k++) cnt[sprintf("%02x",k)]=0 }
        { for (i=1;i<=length($0);i+=2) { byte=substr($0,i,2)
            if (byte!="00") all_zero=0; if (byte!="ff") all_f=0
            cnt[byte]++; n++ } }
        END { ev=n/256
            for (b in cnt) { d=cnt[b]-ev; chi2 += d*d/ev }
            if (all_zero||all_f) print "DEGRADED"
            else if (chi2>400) print "NONUNIFORM " chi2
            else print "OK" }') || return 1
    case "$result" in
        OK) return 0 ;;
        DEGRADED|NONUNIFORM*|*) echo -e "${RED}❌ 熵自检失败: ${result}，拒绝生成${NC}" >&2; return 1 ;;
    esac
}

############################
# 自定义熵质量下限校验 (credit model: 骰子 log2(6)/次, 普通字符 2bit; 纵深防御)
############################
check_custom_entropy() {
    local custom="${1:-}" n="${2:-}"
    local required_bits=0
    case "$n" in 12) required_bits=128 ;; 18) required_bits=192 ;; 24) required_bits=256 ;; *) return 0 ;; esac
    local len=${#custom}
    if (( len < 30 )); then echo -e "${YELLOW}⚠️  输入不足 30 字符，建议加长${NC}" >&2; fi
    local is_dice=1 i ch
    for ((i=0;i<len;i++)); do ch="${custom:i:1}"; [[ ! "$ch" =~ [1-6] ]] && { is_dice=0; break; }; done
    local credited_bits=0
    if (( is_dice )); then
        credited_bits=$(( len * 2585 / 1000 ))
        local run=1 longest=1 up=0 down=0 m=${#custom}
        for ((i=1;i<m;i++)); do
            local cur="${custom:i:1}" prv="${custom:i-1:1}"
            [ "$cur" == "$prv" ] && { run=$((run+1)); ((run>longest)) && longest=$run; } || run=1
            [ "$cur" == "$((prv+1))" ] && up=$((up+1))
            [ "$cur" == "$((prv-1))" ] && down=$((down+1))
        done
        if (( longest>=8 )) || (( 3*up>m )) || (( 3*down>m )); then
            echo -e "${RED}⚠️  骰子健康度异常，请重新输入或改用系统随机熵${NC}" >&2; return 1
        fi
    else
        credited_bits=$(( len * 2 ))
    fi
    if (( credited_bits < required_bits )); then
        echo -e "${RED}❌ 自定义熵不足: ${credited_bits} < ${required_bits} bit（${n}词）${NC}" >&2
        echo -e "${YELLOW}   请加长输入或改用系统随机熵${NC}" >&2; return 1
    fi
    echo -e "${GREEN}✅ 自定义输入健康度通过（估算下限 ${credited_bits} bit）${NC}" >&2
    return 0
}

############################
# 生成 BIP39 助记词 (标准 domain-separation 混合, GPT6 P1)
############################
gen_mnemonic() {
    local n="$1" entropy_mode="${2:-system}" custom_entropy="${3-}"
    local ent_bytes
    case "$n" in 12) ent_bytes=16 ;; 18) ent_bytes=24 ;; 24) ent_bytes=32 ;; *) return 1 ;; esac
    local ent_hex
    if [[ "$entropy_mode" == "custom" ]]; then
        check_custom_entropy "$custom_entropy" "$n" >/dev/null 2>&1 || return 1
        local sys o aux mixed
        sys=$(secure_random_hex "$ent_bytes") || return 1
        check_entropy || return 1
        aux=$(secure_random_hex 16) || return 1
        # domain-separated HKDF-SHA256 风格混合:
        #   IKM = sys || custom;  经 独立 salt/info 标签避免域混淆
        mixed="$sys"
        mixed=$(printf '%s' "${mixed}|" | \
          openssl dgst -sha256 -hmac "bip39-custom-entropy" -binary | xxd -p | tr -d '\n') || return 1
        mixed=$(printf '%s' "${mixed}${aux}" | \
          openssl dgst -sha256 -hmac "bip39-${n}-words" -binary | xxd -p | tr -d '\n') || return 1
        ent_hex="${mixed:0:$((ent_bytes*2))}"
    else
        ent_hex=$(secure_random_hex "$ent_bytes") || return 1
        check_entropy || return 1
    fi
    local hash_hex ent_bin hash_bin csum_bits csum_bin full_bin out="" i bits11 idx
    hash_hex=$(printf "%s" "$ent_hex" | xxd -r -p | openssl dgst -sha256 -binary | xxd -p | tr -d '\n') || return 1
    ent_bin=$(hex2bin "$ent_hex") || return 1
    hash_bin=$(hex2bin "$hash_hex") || return 1
    csum_bits=$(( ent_bytes / 4 ))
    csum_bin="${hash_bin:0:$csum_bits}"
    full_bin="${ent_bin}${csum_bin}"
    for ((i=0;i<n;i++)); do
        bits11="${full_bin:$((i*11)):11}"; idx=$((2#$bits11)); out+="${wordlist[$idx]} "
    done
    echo "${out% }"
}


############################
# 菜单 1: 生成并加密
############################
menu_generate() {
    local n="" entropy_choice="" entropy_mode="" p1="" p2="" enc="" mnemonic="" c
    secure_clear
    echo -e "${CYAN}====== [ 🆕 生成全新助记词 ] ======${NC}"
    echo -e "${YELLOW}请选择需要生成的单词数量：${NC}"
    echo -e "  ${GREEN}1.${NC} 12 个词 (128-bit)"
    echo -e "  ${GREEN}2.${NC} 18 个词 (192-bit)"
    echo -e "  ${GREEN}3.${NC} 24 个词 (256-bit，推荐)"
    echo -e "${CYAN}-----------------------------------${NC}"
    echo -en "${BOLD}▶ 请选择 [1/2/3] : ${NC}"; read -r c
    case "$c" in 1) n=12 ;; 2) n=18 ;; 3) n=24 ;; *) return ;; esac
    echo -e "${CYAN}-----------------------------------${NC}"
    echo -e "${YELLOW}请选择助记词熵来源：${NC}"
    echo -e "  ${GREEN}1.${NC} 使用系统随机熵 ${GRAY}(推荐)${NC}"
    echo -e "  ${GREEN}2.${NC} 系统熵 + 自定义输入混合 ${GRAY}(骰子/随机字符)${NC}"
    echo -en "${BOLD}▶ 请选择 [1/2] : ${NC}"; read -r entropy_choice
    case "$entropy_choice" in 1) entropy_mode="system" ;; 2) entropy_mode="custom" ;; *) return ;; esac
    local custom_entropy=""
    if [[ "$entropy_mode" == "custom" ]]; then
        echo -e "${YELLOW}请输入自定义输入（最多 4096 字符，不含换行）：${NC}"
        echo -en "${BOLD}▶ 输入自定义熵 : ${NC}"
        while true; do
            if ! IFS= read -r -s custom_entropy; then
                echo; unset custom_entropy
                echo -e "\n${RED}❌ 未读取到输入，已取消！${NC}"; pause_return; return
            fi
            echo
            local clen=${#custom_entropy}
            if [[ -z "$custom_entropy" ]]; then
                echo -e "${RED}❌ 不能为空，请重新输入！${NC}"; unset custom_entropy
            elif (( clen > 4096 )); then
                echo -e "${RED}❌ 超过 4096 字符，请重新输入！${NC}"; unset custom_entropy
            elif ! check_custom_entropy "$custom_entropy" "$n"; then
                unset custom_entropy
            else
                break
            fi
            echo -en "${BOLD}▶ 输入自定义熵 : ${NC}"
        done
    fi
    if ! mnemonic=$(gen_mnemonic "$n" "$entropy_mode" "$custom_entropy"); then
        unset custom_entropy; echo -e "\n${RED}❌ 熵生成失败，已取消！${NC}"; pause_return; return
    fi
    unset custom_entropy
    echo -e "\n${YELLOW}>> 请设置高强度密码（至少 14 字符，切勿用弱口令）<<${NC}"
    echo -en "${BOLD}▶ 设置加密密码 : ${NC}"; IFS= read -s -r p1; echo
    echo -en "${BOLD}▶ 重新确认密码 : ${NC}"; IFS= read -s -r p2; echo
    if [[ "$p1" != "$p2" ]]; then echo -e "\n${RED}❌ 两次密码不一致，已取消！${NC}"; pause_return; return; fi
    if [[ -z "$p1" ]]; then echo -e "\n${RED}❌ 密码不能为空！${NC}"; pause_return; return; fi
    if (( ${#p1} < 14 )); then echo -e "\n${RED}❌ 密码强度不足：至少 14 字符！${NC}"; pause_return; return; fi
    echo -e "\n${CYAN}⏳ 正在通过 Argon2id 高强度加密（参数 $CIPHER_SUITE），请稍候...${NC}"
    if ! enc=$(encrypt_secure "$mnemonic" "$p1"); then
        unset mnemonic p1 p2; echo -e "\n${RED}❌ 加密失败，已取消！${NC}"; pause_return; return
    fi
    unset mnemonic p1 p2
    secure_clear
    echo -e "${GREEN}✅ 助记词已生成并高强度加密（v3 跨平台互通格式）！${NC}"
    echo -e "${RED}⚠️ 助记词明文仅在内存处理，未写入磁盘！${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW}【 密文数据 】${GRAY}（完整保存/备份这段）${NC}"
    echo; echo -e "${BOLD}${enc}${NC}"
    echo -e "${CYAN}----------------------------------------------------${NC}"
    echo -e "${YELLOW}【 密文二维码 】${NC}"
    print_qr "$enc"
    echo -e "${CYAN}====================================================${NC}"
    unset enc
    pause_return
}

############################
# 菜单 2: 加密已有助记词
############################
menu_encrypt_existing() {
    local p1="" p2="" enc="" mnemonic=""
    secure_clear
    echo -e "${CYAN}====== [ 🔐 加密已有助记词 ] ======${NC}"
    echo -e "${YELLOW}⚠️ 推荐粘贴以空格分隔的一整行单词${NC}"
    echo -e "${CYAN}-----------------------------------${NC}"
    echo -en "${BOLD}▶ 粘贴或输入助记词 : ${NC}"; read -r mnemonic
    [[ -z "$mnemonic" ]] && return
    mnemonic="$(printf "%s" "$mnemonic" | tr -s '[:space:]' ' ' | sed 's/^ //; s/ $//')"
    if ! validate_mnemonic "$mnemonic"; then
        echo -e "\n${RED}❌ 助记词校验未通过（词数/词表/校验和），已取消！${NC}"; unset mnemonic; pause_return; return
    fi
    echo -e "${GREEN}✅ 助记词通过 BIP39 校验${NC}"
    echo -e "\n${YELLOW}>> 请设置高强度密码（至少 14 字符）<<${NC}"
    echo -en "${BOLD}▶ 设置加密密码 : ${NC}"; IFS= read -s -r p1; echo
    echo -en "${BOLD}▶ 重新确认密码 : ${NC}"; IFS= read -s -r p2; echo
    if [[ "$p1" != "$p2" ]]; then echo -e "\n${RED}❌ 两次密码不一致！${NC}"; pause_return; return; fi
    if [[ -z "$p1" ]]; then echo -e "\n${RED}❌ 密码不能为空！${NC}"; pause_return; return; fi
    if (( ${#p1} < 14 )); then echo -e "\n${RED}❌ 密码强度不足：至少 14 字符！${NC}"; pause_return; return; fi
    echo -e "\n${CYAN}⏳ 正在通过 Argon2id 高强度加密（$CIPHER_SUITE），请稍候...${NC}"
    if ! enc=$(encrypt_secure "$mnemonic" "$p1"); then
        unset mnemonic p1 p2; echo -e "\n${RED}❌ 加密失败！${NC}"; pause_return; return
    fi
    unset mnemonic p1 p2
    secure_clear
    echo -e "${GREEN}✅ 助记词已高强度加密（v3）！${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW}【 密文数据 】${NC}"; echo; echo -e "${BOLD}${enc}${NC}"
    echo -e "${CYAN}----------------------------------------------------${NC}"
    echo -e "${YELLOW}【 密文二维码 】${NC}"; print_qr "$enc"
    echo -e "${CYAN}====================================================${NC}"
    unset enc
    pause_return
}

############################
# 菜单 3: 解密 (V3 兼容 v1/v2; 展示方式三平台统一 1/2)
############################
menu_decrypt() {
    secure_clear
    local blob="" pass="" out="" o
    echo -e "${CYAN}====== [ 🔓 解密助记词 ] ======${NC}"
    echo -e "${YELLOW}请粘贴加密文本（v3 跨平台 / 旧版 v1·v2 均可）：${NC}"
    echo -e "${CYAN}-----------------------------------${NC}"
    echo -en "${BOLD}▶ 粘贴加密文本 : ${NC}"; read -r blob
    blob="$(echo "$blob" | tr -d '[:space:]')"
    [[ -z "$blob" ]] && return
    echo -e "\n${YELLOW}请输入加密时的密码：${NC}"
    echo -en "${BOLD}▶ 解密密码 : ${NC}"
    if ! IFS= read -r -s pass; then unset pass; echo; echo -e "\n${RED}❌ 未读取到密码，已取消！${NC}"; pause_return; return; fi
    echo
    echo -e "\n${CYAN}⏳ 正在校验 HMAC 完整性并解密（v3 按密文内嵌 KDF 参数派生），请稍候...${NC}"
    local original_blob="$blob"
    if ! out=$(decrypt_secure "$blob" "$pass" 2>/dev/null); then
        unset pass out original_blob; echo -e "\n${RED}❌ 解密失败！密码错误或数据损坏/被篡改${NC}"; pause_return; return
    fi
    secure_clear
    echo -e "${GREEN}✅ 解密成功！数据通过完整性校验。${NC}"
    if ! validate_mnemonic "$out" 2>/dev/null; then
        echo -e "${YELLOW}⚠️  解密明文未通过 BIP39 校验（可能是旧版自定义文本或数据受损）${NC}"
    fi
    echo -e "${RED}⚠️ 请确认背后无摄像头、无他人在旁窥视！${NC}"
    echo -e "${CYAN}-----------------------------------${NC}"
    echo -e "${YELLOW}请选择查看明文助记词的方式：${NC}"
    echo -e "  ${GREEN}1.${NC} 在本终端直接打印明文"
    echo -e "  ${GREEN}2.${NC} 在终端生成二维码 ${GRAY}(推荐离线设备扫码)${NC}"
    echo -e "  ${GRAY}(空输入=取消, 不显示任何明文)${NC}"
    echo -e "${CYAN}-----------------------------------${NC}"
    echo -en "${BOLD}▶ 请选择 [1/2] : ${NC}"; read -r o
    secure_clear
    echo -e "${CYAN}====== [ 🔒 极密数据展示 ] ======${NC}"
    case "$o" in
        1)
            echo -e "${YELLOW}您的助记词明文如下：${NC}"
            echo -e "${RED}⚠️ 【 严重警告 】请用纸笔手抄，切勿 Ctrl+C 复制（剪贴板可被嗅探窃取）${NC}"
            echo -e "${BOLD}${out}${NC}\n"
            ;;
        2)
            echo -e "${YELLOW}请用不联网的备用设备扫码提取（严禁微信等后台上传类软件）：${NC}\n"
            print_qr "$out"
            ;;
        *)
            echo -e "${RED}⚠️ 未选择展示方式，为安全已忽略并清屏。${NC}"
            ;;
    esac
    echo -e "${CYAN}=================================${NC}"
    case "$original_blob" in
        v1:*|"") if [[ "$original_blob" != v2:* && "$original_blob" != v3:* ]]; then
            echo -e "\n${YELLOW}💡 格式升级提示：当前为旧版格式，推荐用主菜单【选项 2】重新加密升级为 v3 跨平台互通格式。${NC}"
        fi;;
    esac
    unset pass out blob original_blob
    pause_return
}

############################
# 主菜单
############################
main_menu() {
    local c
    while true; do
        secure_clear
        echo -e "${CYAN}====================================================${NC}"
        echo -e "${BOLD}${MAGENTA}       🛡️ BIP39 助记词安全管理器 · V3 (跨平台) 🛡️${NC}"
        echo -e "${GRAY}  平台: ${PLATFORM_NAME}   算法: $CIPHER_SUITE${NC}"
        echo -e "${CYAN}====================================================${NC}"
        echo -e "${YELLOW}                  【 极密警告 】${NC}"
        echo -e "${RED} ⚠️  请务必在断网、无监控且无人窥视环境下操作！${NC}"
        echo -e "${RED} ⚠️  严禁拍照/截图/录像/远程桌面分享屏幕！${NC}"
        echo -e "${CYAN}----------------------------------------------------${NC}"
        echo -e "  ${GREEN}1.${NC} 🆕 生成并高强度加密全新助记词 ${GRAY}(推荐)${NC}"
        echo -e "  ${GREEN}2.${NC} 🔐 加密已有助记词"
        echo -e "  ${GREEN}3.${NC} 🔓 解密密文 (v3 跨平台 / 旧版兼容)"
        echo -e "  ${GRAY}q.${NC} 🚪 安全退出"
        echo -e "${CYAN}====================================================${NC}"
        echo
        echo -en "${BOLD}▶ 请选择操作任务 [1/2/3/q] : ${NC}"
        if ! read -r c; then echo; exit 0; fi
        case "$c" in
            1) menu_generate ;;
            2) menu_encrypt_existing ;;
            3) menu_decrypt ;;
            q) echo -e "\n${GREEN}👋 已安全退出。请手动清空终端滚回并关闭本窗口。${NC}"; secure_clear; exit 0 ;;
        esac
    done
}


############################
# 启动自检 (带进度条; 开头 3 秒内按回车可跳过全部自检)
############################
TOTAL_STEPS=6
echo -e "${CYAN}====================================================${NC}"
echo -e "${BOLD}${MAGENTA}       🛡️ BIP39 助记词安全管理器 · V3 初始化${NC}"
echo -e "${GRAY}  平台: ${PLATFORM_NAME}   参数: $CIPHER_SUITE${NC}"
echo -e "${CYAN}====================================================${NC}"
echo

# 跳过自检: 3 秒内按回车 -> 跳过全部自检直接进菜单; 超时未操作 -> 完整自检
echo -en "${BLUE}⚡ 本次是否跳过全部自检直接进入菜单？ [按回车=跳过 | 3秒不操作=完整自检]${NC} "
SKIP_ALL=0
if read -r -t 3 _skip_ans 2>/dev/null; then
    SKIP_ALL=1
fi
echo

# 无论是否跳过, 核心依赖必须先就位 (check_wordlist 需 openssl; KDF 需 argon2)
echo -e "${CYAN}▶ 确保核心依赖就位 (argon2/openssl/xxd)...${NC}"
check_deps

# 词表 2048 指纹是加密正确性硬前置(决定词索引), 必做
echo -e "${CYAN}▶ 校验词表完整性指纹 (2048 词, 快速)...${NC}"
if ! check_wordlist; then
    echo -e "${RED}❌ 词表完整性自检失败（词数或 SHA256 指纹不符），词表可能已被篡改，拒绝运行！${NC}"
    echo -en "${BOLD}▶ 按回车键退出...${NC}"; read -r _; exit 1
fi
build_word_index

if [[ $SKIP_ALL -eq 1 ]]; then
    echo -e "${GREEN}⚡ 已跳过全部自检，直接进入菜单 (依赖+词表指纹已核验)${NC}"
    echo -e "${GRAY}  提示: 本次未做 KDF/全链路/二维码自检; 如需完整校验请再运行且 3 秒内不要按键${NC}"
    echo; sleep 2
    main_menu
fi

# ---- 完整自检流程 ----
# 步骤 1/6: 依赖
echo -e "${CYAN}▶ 初始化 1/6: 检查核心依赖 (argon2/openssl/xxd)...${NC}"
check_deps
init_progress 1 6 "依赖检查"

# 步骤 2/6: 词表指纹
echo -e "${CYAN}▶ 初始化 2/6: 词表完整性指纹校验 (2048 词)...${NC}"
if ! check_wordlist; then
    echo -e "${RED}❌ 词表完整性自检失败（词数或 SHA256 指纹不符），词表可能已被篡改，拒绝运行！${NC}"
    echo -en "${BOLD}▶ 按回车键退出...${NC}"; read -r _; exit 1
fi
build_word_index
init_progress 2 6 "词表指纹"

# 步骤 3/6: KDF 自检
echo -e "${CYAN}▶ 初始化 3/6: KDF 确定性自检 (Argon2id ${KDF_M}/${KDF_P})...${NC}"
if ! kdf_selftest; then
    echo -e "${RED}❌ KDF 自检失败：argon2 输出异常（参数/构建不兼容），拒绝运行以防密钥静默降级！${NC}"
    echo -en "${BOLD}▶ 按回车键退出...${NC}"; read -r _; exit 1
fi
init_progress 3 6 "KDF自检"
echo -e "${CYAN}▶ 初始化 4/6: 密码学全链路自检 (v3 加密/解密/篡改/错口令)...${NC}"
if ! crypto_selftest; then
    echo -e "${RED}❌ 全链路自检失败：AES/HMAC 或防篡改异常，拒绝运行！${NC}"
    echo -en "${BOLD}▶ 按回车键退出...${NC}"; read -r _; exit 1
fi
init_progress 4 6 "全链路自检"

# 步骤 5/6: 二维码依赖 (可选)
if ! command -v qrencode >/dev/null 2>&1; then
    echo -e "${YELLOW}ℹ️ qrencode 未安装(可选)，二维码功能暂不可用，核心加解密不受影响。${NC}"
fi
init_progress 5 6 "二维码依赖"

# 步骤 6/6: 就绪
init_progress 6 6 "就绪"
echo -e "${GREEN}✅ 初始化完成，所有安全自检通过！${NC}"
echo; sleep 2

main_menu
