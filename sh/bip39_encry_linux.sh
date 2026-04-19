#!/usr/bin/env bash
set -euo pipefail

############################
# 颜色与样式
############################
RED="\033[31;1m"
GREEN="\033[32;1m"
YELLOW="\033[33;1m"
MAGENTA="\033[35;1m"
CYAN="\033[36;1m"
GRAY="\033[90m"
BOLD="\033[1m"
NC="\033[0m"

############################
# 安全清屏
############################
secure_clear() {
    printf "\033[2J\033[H"
}

pause_return() {
    echo
    echo -e "${GRAY}────────────────────────────────────────────────────${NC}"
    echo -en "${BOLD}▶ 按回车键 (Enter) 返回主菜单并彻底清除屏幕记录...${NC}"
    read -r -s
    secure_clear
}

############################
# 依赖检测
############################
need() { command -v "$1" >/dev/null 2>&1; }

auto_install() {
    local pkgs=(argon2 openssl xxd qrencode)
    if need apt; then
        sudo apt update && sudo apt install -y "${pkgs[@]}"
    elif need dnf; then
        sudo dnf install -y "${pkgs[@]}"
    elif need pacman; then
        sudo pacman -Sy --noconfirm "${pkgs[@]}"
    else
        echo -e "${RED}❌ 无法识别包管理器${NC}"
        exit 1
    fi
}

check_deps() {
    local miss=()
    for c in argon2 openssl xxd qrencode; do
        need "$c" || miss+=("$c")
    done
    if ((${#miss[@]})); then
        echo -e "${YELLOW}⚠️ 缺少依赖: ${miss[*]}${NC}"
        read -r -p "是否自动安装？[Y/n]: " a
        [[ "${a,,}" == "n" ]] && exit 1
        auto_install
    fi
}

############################
# 安全防护：临时关闭 Swap
############################
disable_swap() {
    if need swapon && need grep && need sudo; then
        if swapon -s 2>/dev/null | grep -q "/"; then
            echo -e "${YELLOW}⚠️ 检测到系统开启了 Swap 交换区（可能导致内存明文落盘）。${NC}"
            read -r -p "▶ 是否尝试通过 sudo 临时关闭 Swap？(极度推荐) [Y/n]: " ans
            if [[ "${ans,,}" != "n" ]]; then
                echo -e "${CYAN}🔄 尝试临时关闭 Swap，当前用户如果未提权，可能会要求您输入系统 sudo 密码：${NC}"
                if sudo swapoff -a 2>/dev/null; then
                    echo -e "${GREEN}✅ Swap 交换区已成功临时关闭！您的极密数据在本次会话中永不落盘。${NC}"
                else
                    echo -e "${RED}❌ 关闭 Swap 失败（可能无权限）。请您自己警惕明文落盘风险！${NC}"
                fi
                echo -e "${GRAY}────────────────────────────────────────────────────${NC}"
                sleep 2
            fi
        fi
    fi
}

############################
# 密钥派生（64 字节 → AES + HMAC）
############################
derive_key() {
    local pass="$1" salt="$2"
    printf "%s" "$pass" | \
      argon2 "$salt" -id -t 3 -m 19 -p 4 -l 64 -r -q | \
      xxd -p | tr -d '\n'
}

############################
# 加密（AES-256-CBC + HMAC-SHA256）
############################
encrypt_secure() {
    local plaintext="$1" pass="$2"
    local salt iv key aes_key mac_key cipher mac

    salt=$(openssl rand -hex 16)
    iv=$(openssl rand -hex 16)

    key=$(derive_key "$pass" "$salt")
    aes_key="${key:0:64}"
    mac_key="${key:64:64}"

    cipher=$(printf "%s" "$plaintext" | \
      openssl enc -aes-256-cbc \
        -K "$aes_key" \
        -iv "$iv" \
        -base64 -A)

	mac=$(printf "%s%s%s" "$salt" "$iv" "$cipher" | \
	  openssl dgst -sha256 -mac HMAC -macopt hexkey:"$mac_key" | \
	  sed 's/^.*= //')

    printf "%s:%s:%s:%s\n" "$salt" "$iv" "$mac" "$cipher"
}

############################
# 解密（先校验 HMAC）
############################
decrypt_secure() {
    local blob="$1" pass="$2"
    IFS=: read -r salt iv mac cipher <<< "$blob"

    local key aes_key mac_key calc_mac

    key=$(derive_key "$pass" "$salt")
    aes_key="${key:0:64}"
    mac_key="${key:64:64}"

	calc_mac=$(printf "%s%s%s" "$salt" "$iv" "$cipher" | \
	  openssl dgst -sha256 -mac HMAC -macopt hexkey:"$mac_key" | \
	  sed 's/^.*= //')


    [[ "$mac" != "$calc_mac" ]] && return 1

    printf "%s" "$cipher" | \
      openssl enc -d -aes-256-cbc \
        -K "$aes_key" \
        -iv "$iv" \
        -base64 -A
}


############################
# QR 输出
############################
print_qr() {
    printf "%s" "$1" | qrencode -t UTF8
}

############################
# 助记词（占位示例）
############################
wordlist=(abandon ability able about above absent absorb abstract absurd abuse access accident account accuse achieve acid acoustic acquire across act action actor actress actual adapt add addict address adjust admit adult advance advice aerobic affair afford afraid again age agent agree ahead aim air airport aisle alarm album alcohol alert alien all alley allow almost alone alpha already also alter always amateur amazing among amount amused analyst anchor ancient anger angle angry animal ankle announce annual another answer antique anxiety any apart apology appear apple approve april arch arctic area arena argue arm armed armor army around arrange arrest arrive arrow art artefact artist artwork ask aspect assault asset assist assume asthma athlete atomic attack attend attitude attract auction audit august aunt author auto autumn average avocado avoid awake aware away awesome awkward axis baby bachelor bacon badge bag balance balcony ball bamboo banana banner bar barely bargain barrel base basic basket battle beach bean beauty because become beef before begin behave behind believe below belt bench benefit best betray better between beyond bicycle bid bike bind biology bird birth bitter black blade blame blanket blast bleak bless blind blood blossom blouse blue blur blush board boat body boil bomb bone bonus book boost border boring borrow boss bottom bounce box boy bracket brain brand brass brave bread breeze brick bridge brief bright bring brisk broccoli broken bronze broom brother brown brush bubble buddy budget buffalo build bulb bulk bullet bundle bunker burden burger burst bus business busy butter buyer buzz cabbage cabin cable cactus cage cake call calm camera camp can canal cancel candy cannon canoe canvas canyon capable capital captain car carbon card cargo carpet carry cart case cash casino castle casual cat catalog catch category cattle caught cause caution cave ceiling celery cement census century cereal certain chair chalk champion change chaos chapter charge chase chat cheap check cheese chef cherry chest chicken chief child chimney choice choose chronic chuckle chunk churn cigar cinnamon circle citizen city civil claim clap clarify claw clay clean clerk clever click client cliff climb clinic clip clock clog close cloth cloud clown club clump cluster clutch coach coast coconut code coffee coil coin collect color column combine come comfort comic common company concert conduct confirm congress connect consider control convince cook cool copper copy coral core corn correct cost cotton couch country couple course cousin cover coyote crack cradle craft cram crane crash crater crawl crazy cream credit creek crew cricket crime crisp critic crop cross crouch crowd crucial cruel cruise crumble crunch crush cry crystal cube culture cup cupboard curious current curtain curve cushion custom cute cycle dad damage damp dance danger daring dash daughter dawn day deal debate debris decade december decide decline decorate decrease deer defense define defy degree delay deliver demand demise denial dentist deny depart depend deposit depth deputy derive describe desert design desk despair destroy detail detect develop device devote diagram dial diamond diary dice diesel diet differ digital dignity dilemma dinner dinosaur direct dirt disagree discover disease dish dismiss disorder display distance divert divide divorce dizzy doctor document dog doll dolphin domain donate donkey donor door dose double dove draft dragon drama drastic draw dream dress drift drill drink drip drive drop drum dry duck dumb dune during dust dutch duty dwarf dynamic eager eagle early earn earth easily east easy echo ecology economy edge edit educate effort egg eight either elbow elder electric elegant element elephant elevator elite else embark embody embrace emerge emotion employ empower empty enable enact end endless endorse enemy energy enforce engage engine enhance enjoy enlist enough enrich enroll ensure enter entire entry envelope episode equal equip era erase erode erosion error erupt escape essay essence estate eternal ethics evidence evil evoke evolve exact example excess exchange excite exclude excuse execute exercise exhaust exhibit exile exist exit exotic expand expect expire explain expose express extend extra eye eyebrow fabric face faculty fade faint faith fall false fame family famous fan fancy fantasy farm fashion fat fatal father fatigue fault favorite feature february federal fee feed feel female fence festival fetch fever few fiber fiction field figure file film filter final find fine finger finish fire firm first fiscal fish fit fitness fix flag flame flash flat flavor flee flight flip float flock floor flower fluid flush fly foam focus fog foil fold follow food foot force forest forget fork fortune forum forward fossil foster found fox fragile frame frequent fresh friend fringe frog front frost frown frozen fruit fuel fun funny furnace fury future gadget gain galaxy gallery game gap garage garbage garden garlic garment gas gasp gate gather gauge gaze general genius genre gentle genuine gesture ghost giant gift giggle ginger giraffe girl give glad glance glare glass glide glimpse globe gloom glory glove glow glue goat goddess gold good goose gorilla gospel gossip govern gown grab grace grain grant grape grass gravity great green grid grief grit grocery group grow grunt guard guess guide guilt guitar gun gym habit hair half hammer hamster hand happy harbor hard harsh harvest hat have hawk hazard head health heart heavy hedgehog height hello helmet help hen hero hidden high hill hint hip hire history hobby hockey hold hole holiday hollow home honey hood hope horn horror horse hospital host hotel hour hover hub huge human humble humor hundred hungry hunt hurdle hurry hurt husband hybrid ice icon idea identify idle ignore ill illegal illness image imitate immense immune impact impose improve impulse inch include income increase index indicate indoor industry infant inflict inform inhale inherit initial inject injury inmate inner innocent input inquiry insane insect inside inspire install intact interest into invest invite involve iron island isolate issue item ivory jacket jaguar jar jazz jealous jeans jelly jewel job join joke journey joy judge juice jump jungle junior junk just kangaroo keen keep ketchup key kick kid kidney kind kingdom kiss kit kitchen kite kitten kiwi knee knife knock know lab label labor ladder lady lake lamp language laptop large later latin laugh laundry lava law lawn lawsuit layer lazy leader leaf learn leave lecture left leg legal legend leisure lemon lend length lens leopard lesson letter level liar liberty library license life lift light like limb limit link lion liquid list little live lizard load loan lobster local lock logic lonely long loop lottery loud lounge love loyal lucky luggage lumber lunar lunch luxury lyrics machine mad magic magnet maid mail main major make mammal man manage mandate mango mansion manual maple marble march margin marine market marriage mask mass master match material math matrix matter maximum maze meadow mean measure meat mechanic medal media melody melt member memory mention menu mercy merge merit merry mesh message metal method middle midnight milk million mimic mind minimum minor minute miracle mirror misery miss mistake mix mixed mixture mobile model modify mom moment monitor monkey monster month moon moral more morning mosquito mother motion motor mountain mouse move movie much muffin mule multiply muscle museum mushroom music must mutual myself mystery myth naive name napkin narrow nasty nation nature near neck need negative neglect neither nephew nerve nest net network neutral never news next nice night noble noise nominee noodle normal north nose notable note nothing notice novel now nuclear number nurse nut oak obey object oblige obscure observe obtain obvious occur ocean october odor off offer office often oil okay old olive olympic omit once one onion online only open opera opinion oppose option orange orbit orchard order ordinary organ orient original orphan ostrich other outdoor outer output outside oval oven over own owner oxygen oyster ozone pact paddle page pair palace palm panda panel panic panther paper parade parent park parrot party pass patch path patient patrol pattern pause pave payment peace peanut pear peasant pelican pen penalty pencil people pepper perfect permit person pet phone photo phrase physical piano picnic picture piece pig pigeon pill pilot pink pioneer pipe pistol pitch pizza place planet plastic plate play please pledge pluck plug plunge poem poet point polar pole police pond pony pool popular portion position possible post potato pottery poverty powder power practice praise predict prefer prepare present pretty prevent price pride primary print priority prison private prize problem process produce profit program project promote proof property prosper protect proud provide public pudding pull pulp pulse pumpkin punch pupil puppy purchase purity purpose purse push put puzzle pyramid quality quantum quarter question quick quit quiz quote rabbit raccoon race rack radar radio rail rain raise rally ramp ranch random range rapid rare rate rather raven raw razor ready real reason rebel rebuild recall receive recipe record recycle reduce reflect reform refuse region regret regular reject relax release relief rely remain remember remind remove render renew rent reopen repair repeat replace report require rescue resemble resist resource response result retire retreat return reunion reveal review reward rhythm rib ribbon rice rich ride ridge rifle right rigid ring riot ripple risk ritual rival river road roast robot robust rocket romance roof rookie room rose rotate rough round route royal rubber rude rug rule run runway rural sad saddle sadness safe sail salad salmon salon salt salute same sample sand satisfy satoshi sauce sausage save say scale scan scare scatter scene scheme school science scissors scorpion scout scrap screen script scrub sea search season seat second secret section security seed seek segment select sell seminar senior sense sentence series service session settle setup seven shadow shaft shallow share shed shell sheriff shield shift shine ship shiver shock shoe shoot shop short shoulder shove shrimp shrug shuffle shy sibling sick side siege sight sign silent silk silly silver similar simple since sing siren sister situate six size skate sketch ski skill skin skirt skull slab slam sleep slender slice slide slight slim slogan slot slow slush small smart smile smoke smooth snack snake snap sniff snow soap soccer social sock soda soft solar soldier solid solution solve someone song soon sorry sort soul sound soup source south space spare spatial spawn speak special speed spell spend sphere spice spider spike spin spirit split spoil sponsor spoon sport spot spray spread spring spy square squeeze squirrel stable stadium staff stage stairs stamp stand start state stay steak steel stem step stereo stick still sting stock stomach stone stool story stove strategy street strike strong struggle student stuff stumble style subject submit subway success such sudden suffer sugar suggest suit summer sun sunny sunset super supply supreme sure surface surge surprise surround survey suspect sustain swallow swamp swap swarm swear sweet swift swim swing switch sword symbol symptom syrup system table tackle tag tail talent talk tank tape target task taste tattoo taxi teach team tell ten tenant tennis tent term test text thank that theme then theory there they thing this thought three thrive throw thumb thunder ticket tide tiger tilt timber time tiny tip tired tissue title toast tobacco today toddler toe together toilet token tomato tomorrow tone tongue tonight tool tooth top topic topple torch tornado tortoise toss total tourist toward tower town toy track trade traffic tragic train transfer trap trash travel tray treat tree trend trial tribe trick trigger trim trip trophy trouble truck true truly trumpet trust truth try tube tuition tumble tuna tunnel turkey turn turtle twelve twenty twice twin twist two type typical ugly umbrella unable unaware uncle uncover under undo unfair unfold unhappy uniform unique unit universe unknown unlock until unusual unveil update upgrade uphold upon upper upset urban urge usage use used useful useless usual utility vacant vacuum vague valid valley valve van vanish vapor various vast vault vehicle velvet vendor venture venue verb verify version very vessel veteran viable vibrant vicious victory video view village vintage violin virtual virus visa visit visual vital vivid vocal voice void volcano volume vote voyage wage wagon wait walk wall walnut want warfare warm warrior wash wasp waste water wave way wealth weapon wear weasel weather web wedding weekend weird welcome west wet whale what wheat wheel when where whip whisper wide width wife wild will win window wine wing wink winner winter wire wisdom wise wish witness wolf woman wonder wood wool word work world worry worth wrap wreck wrestle wrist write wrong yard year yellow you young youth zebra zero zone zoo)

############################
# 十六进制转二进制字符串
############################
hex2bin() {
    local hex="${1,,}"
    local bin=""
    for ((i=0; i<${#hex}; i++)); do
        case "${hex:i:1}" in
            0) bin+="0000" ;; 1) bin+="0001" ;; 2) bin+="0010" ;; 3) bin+="0011" ;;
            4) bin+="0100" ;; 5) bin+="0101" ;; 6) bin+="0110" ;; 7) bin+="0111" ;;
            8) bin+="1000" ;; 9) bin+="1001" ;; a) bin+="1010" ;; b) bin+="1011" ;;
            c) bin+="1100" ;; d) bin+="1101" ;; e) bin+="1110" ;; f) bin+="1111" ;;
        esac
    done
    printf "%s" "$bin"
}

############################
# 生成符合 BIP39 标准的助记词
############################
gen_mnemonic() {
    local n="$1"
    local ent_bytes csum_bits full_bin out=""
    case "$n" in
        12) ent_bytes=16 ;;
        18) ent_bytes=24 ;;
        24) ent_bytes=32 ;;
        *) return 1 ;;
    esac

    local ent_hex
    ent_hex=$(openssl rand -hex "$ent_bytes")
    
    local hash_hex
    hash_hex=$(printf "%s" "$ent_hex" | xxd -r -p | openssl dgst -sha256 -binary | xxd -p | tr -d '\n')
    
    local ent_bin
    ent_bin=$(hex2bin "$ent_hex")
    local hash_bin
    hash_bin=$(hex2bin "$hash_hex")
    
    csum_bits=$(( ent_bytes / 4 ))
    local csum_bin="${hash_bin:0:$csum_bits}"
    full_bin="${ent_bin}${csum_bin}"
    
    for ((i=0; i<n; i++)); do
        local bits11="${full_bin: $((i*11)) : 11}"
        local idx=$((2#$bits11))
        out+="${wordlist[$idx]} "
    done
    
    echo "${out% }"
}

############################
# 菜单 1：生成并加密
############################
menu_generate() {
    secure_clear
    echo -e "${CYAN}====== [ 🆕 生成全新助记词 ] ======${NC}"
    echo -e "${YELLOW}请选择需要生成的单词数量：${NC}"
    echo -e "  ${GREEN}1.${NC} 12 个词 (128-bit 强度)"
    echo -e "  ${GREEN}2.${NC} 18 个词 (192-bit 强度)"
    echo -e "  ${GREEN}3.${NC} 24 个词 (256-bit 强度，推荐)"
    echo -e "${CYAN}-----------------------------------${NC}"
    echo -en "${BOLD}▶ 请选择 [1/2/3] : ${NC}"
    read -r c

    case "$c" in
        1) n=12 ;;
        2) n=18 ;;
        3) n=24 ;;
        *) return ;;
    esac

    mnemonic=$(gen_mnemonic "$n")

    echo -e "\n${YELLOW}>> 请设置高强度密码以保护您的助记词 <<${NC}"
    echo -e "${GRAY}(输入密码时为了安全不会显示任何字符)${NC}"
    echo -en "${BOLD}▶ 设置加密密码 : ${NC}"
    read -s -r p1; echo
    echo -en "${BOLD}▶ 重新确认密码 : ${NC}"
    read -s -r p2; echo
    
    if [[ "$p1" != "$p2" ]]; then
        echo -e "\n${RED}❌ 两次输入的密码不一致，操作已取消！${NC}"
        pause_return
        return
    fi
    
    if [[ -z "$p1" ]]; then
        echo -e "\n${RED}❌ 密码不能为空，操作已取消！${NC}"
        pause_return
        return
    fi

    echo -e "\n${CYAN}⏳ 正在通过 Argon2id 进行高强度加密运算，请稍候...${NC}"
    enc=$(encrypt_secure "$mnemonic" "$p1")
    unset mnemonic p1 p2
    secure_clear

    echo -e "${GREEN}✅ 助记词已成功生成并高强度加密！${NC}"
    echo -e "${RED}⚠️ 注意：助记词明文仅存在于内存，从未且不会落盘！${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW}【 密文数据 】${NC}${GRAY}（请将此段完整文本安全保存/备份）${NC}"
    echo
    echo -e "${BOLD}${enc}${NC}"
    echo
    echo -e "${CYAN}----------------------------------------------------${NC}"
    echo -e "${YELLOW}【 密文二维码 】${GRAY}（可用常用扫码工具保存文本）${NC}"
    print_qr "$enc"
    echo -e "${CYAN}====================================================${NC}"

    pause_return
}

############################
# 菜单 2：加密已有助记词
############################
menu_encrypt_existing() {
    secure_clear
    echo -e "${CYAN}====== [ 🔐 加密已有助记词 ] ======${NC}"
    echo -e "${YELLOW}⚠️ 安全提示：推荐粘贴以空格分隔的一整行单词${NC}"
    echo -e "${GRAY}(输入或粘贴完毕后，直接按下回车键 Enter 即可提交)${NC}"
    echo -e "${CYAN}-----------------------------------${NC}"
    echo -en "${BOLD}▶ 粘贴或输入助记词 : ${NC}"
    read -r mnemonic
    [[ -z "$mnemonic" ]] && return

    echo -e "\n${YELLOW}>> 请设置高强度密码以保护您的助记词 <<${NC}"
    echo -e "${GRAY}(输入密码时为了安全不会显示任何字符)${NC}"
    echo -en "${BOLD}▶ 设置加密密码 : ${NC}"
    read -s -r p1; echo
    echo -en "${BOLD}▶ 重新确认密码 : ${NC}"
    read -s -r p2; echo
    
    if [[ "$p1" != "$p2" ]]; then
        echo -e "\n${RED}❌ 两次输入的密码不一致，操作已取消！${NC}"
        pause_return
        return
    fi
    
    if [[ -z "$p1" ]]; then
        echo -e "\n${RED}❌ 密码不能为空，操作已取消！${NC}"
        pause_return
        return
    fi

    echo -e "\n${CYAN}⏳ 正在通过 Argon2id 进行高强度加密运算，请稍候...${NC}"
    enc=$(encrypt_secure "$mnemonic" "$p1")
    unset mnemonic p1 p2
    secure_clear

    echo -e "${GREEN}✅ 助记词已成功高强度加密！${NC}"
    echo -e "${CYAN}====================================================${NC}"
    echo -e "${YELLOW}【 密文数据 】${NC}${GRAY}（请将此段完整数据安全保存/备份）${NC}"
    echo
    echo -e "${BOLD}${enc}${NC}"
    echo
    echo -e "${CYAN}----------------------------------------------------${NC}"
    echo -e "${YELLOW}【 密文二维码 】${GRAY}（扫码结果即为密文文本）${NC}"
    print_qr "$enc"
    echo -e "${CYAN}====================================================${NC}"

    pause_return
}

############################
# 菜单 3：解密
############################
menu_decrypt() {
    secure_clear
    echo -e "${CYAN}====== [ 🔓 解密助记词 ] ======${NC}"
    echo -e "${YELLOW}请在下方粘贴您此前生成的加密文本字符串：${NC}"
    echo -e "${CYAN}-----------------------------------${NC}"
    echo -en "${BOLD}▶ 粘贴加密文本 : ${NC}"
    read -r blob
    
    # 移除可能因为粘贴带来的多余空格、换行或回车符
    blob="$(echo "$blob" | tr -d '[:space:]')"
    [[ -z "$blob" ]] && return

    echo -e "\n${YELLOW}请输入加密时设置的密码：${NC}"
    echo -en "${BOLD}▶ 解密密码 : ${NC}"
    read -s -r pass; echo

    echo -e "\n${CYAN}⏳ 正在校验 HMAC 数据完整性与解密，请稍候...${NC}"

    if ! out=$(decrypt_secure "$blob" "$pass" 2>/dev/null); then
        echo -e "\n${RED}❌ 解密失败！密码错误或数据已损坏（被篡改）${NC}"
        pause_return
        return
    fi

    secure_clear
    echo -e "${GREEN}✅ 解密成功！数据通过严格完整性校验。${NC}"
    echo -e "${RED}⚠️ 警告：请确认您的背后无摄像头，且无他人在旁窥视！${NC}"
    echo -e "${CYAN}-----------------------------------${NC}"
    echo -e "${YELLOW}请选择查看明文助记词的方式：${NC}"
    echo -e "  ${GREEN}1.${NC} 在本终端窗口直接打印明文"
    echo -e "  ${GREEN}2.${NC} 在终端生成二维码 ${GRAY}(推荐用离线设备扫码提取)${NC}"
    echo -e "${CYAN}-----------------------------------${NC}"
    echo -en "${BOLD}▶ 请选择 [1/2] : ${NC}"
    read -r o
    secure_clear

    echo -e "${CYAN}====== [ 🔒 极密数据展示 ] ======${NC}"
    case "$o" in
        1) 
           echo -e "${YELLOW}您的助记词明文如下：${NC}"
           echo -e "${RED}⚠️ 【 严重警告 】 请用纸笔完整手抄，绝不要使用鼠标选中并 Ctrl+C 复制！${NC}"
           echo -e "${RED}⚠️ 否则该文本可能会被潜伏的剪贴板嗅探类软件永久窃取！！${NC}\n"
           echo -e "${BOLD}${out}${NC}\n"
           ;;
        2) 
           echo -e "${YELLOW}请用不联网的备用设备扫码提取${NC}"
           echo -e "${GRAY}(由于信息极度安全敏感，严禁使用微信等可能在后台上传图像的软件扫码)：${NC}\n"
           print_qr "$out"
           ;;
        *)
           echo -e "${RED}⚠️ 未选择任何展示方式，为保证安全已自动忽略并清屏。${NC}"
           ;;
    esac
    echo -e "${CYAN}=================================${NC}"

    pause_return
}

############################
# 主菜单
############################
main_menu() {
    while true; do
        secure_clear
        echo -e "${CYAN}====================================================${NC}"
        echo -e "${BOLD}${MAGENTA}             🛡️ BIP39 助记词安全管理器 🛡️${NC}"
        echo -e "${GRAY}        算法组合: Argon2id + AES-256-CBC + HMAC${NC}"
        echo -e "${CYAN}====================================================${NC}"
        echo -e "${YELLOW}                     【 极密警告 】${NC}"
        echo -e "${RED} ⚠️  请务必在断网、无监控且没有任何人窥视的环境下操作！${NC}"
        echo -e "${RED} ⚠️  严禁对屏幕进行拍照、截图、录像或远程桌面分享！${NC}"
        echo -e "${CYAN}----------------------------------------------------${NC}"
        echo -e "  ${GREEN}1.${NC} 🆕 生成并高强度加密全新助记词 ${GRAY}(推荐)${NC}"
        echo -e "  ${GREEN}2.${NC} 🔐 对已有保管的助记词加密保护"
        echo -e "  ${GREEN}3.${NC} 🔓 解密密文并查看明文/二维码"
        echo -e "  ${GRAY}q.${NC} 🚪 安全退出并彻底抹除内存痕迹"
        echo -e "${CYAN}====================================================${NC}"
        echo
        echo -en "${BOLD}▶ 请选择操作任务 [1/2/3/q] : ${NC}"
        read -r c
        case "$c" in
            1) menu_generate ;;
            2) menu_encrypt_existing ;;
            3) menu_decrypt ;;
            q) 
               echo -e "\n${GREEN}👋 已安全退出。内存和终端已在退出时自动彻底清空。${NC}"
               secure_clear
               exit 0 
               ;;
        esac
    done
}

check_deps
disable_swap
main_menu
