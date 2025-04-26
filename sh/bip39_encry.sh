#!/data/data/com.termux/files/usr/bin/env bash

# BIP39 Mnemonic Manager for Termux
# Author: AI Assistant
# Version: 1.1

# --- Configuration ---
# 加密算法 (确保 Termux 的 openssl 支持)
# AES-256-CBC 是广泛支持且安全的选项
# -pbkdf2 使用更安全的密钥派生函数 (需要 OpenSSL 1.1.1+)
ENCRYPTION_ALGO="aes-256-cbc"
OPENSSL_OPTS="-${ENCRYPTION_ALGO} -pbkdf2 -a -salt" # -a for base64 encoding, -salt is crucial
MIN_PASSWORD_LENGTH=8 # 密码最小长度

# --- Helper Functions ---

# 检查并安装必要的依赖
check_dependencies() {
    # 安装系统级依赖
    local sys_deps=(clang make python-dev)
    for dep in "${sys_deps[@]}"; do
        if ! pkg list-install | grep -q "$dep"; then
            echo "安装系统依赖: $dep..."
            pkg install -y "$dep" >/dev/null 2>&1 || {
                echo "错误：安装 $dep 失败，请检查网络连接后重试！" >&2
                exit 1
            }
        fi
    done
    # 安装Python库
    if ! python -m pip show bip_utils >/dev/null 2>&1; then
        echo "安装Python依赖: bip_utils..."
        # 尝试使用二进制包安装
        if ! python -m pip install --user --no-cache-dir bip_utils >/dev/null 2>&1; then
            echo "警告：标准安装失败，尝试使用替代方法..."
            # 尝试从源码安装并禁用部分依赖
            if ! python -m pip install --user --no-cache-dir --no-build-isolation --no-binary bip_utils bip_utils >/dev/null 2>&1; then
                echo "错误：无法安装 bip_utils，请尝试以下方法：" >&2
                echo "1. 手动安装Rust工具链: pkg install rust" >&2
                echo "2. 手动安装: python -m pip install bip_utils" >&2
                exit 1
            fi
        fi
    fi
    # 再次验证安装
    if ! python -m pip show bip_utils >/dev/null 2>&1; then
        echo "错误：bip_utils 安装验证失败，请检查安装日志！" >&2
        exit 1
    fi
}
# 生成 24 位 BIP39 助记词 (使用 Python 和 bip_utils 库)
# 这个函数只应该被内部调用，并且其输出绝不直接打印到主脚本的 stdout
generate_mnemonic_internal() {
    python -c '
import sys
from bip_utils import Bip39MnemonicGenerator, Bip39WordsNum, Bip39Languages
import os

try:
    # 使用 cryptographically secure random bytes 生成
    # bip_utils 内部会处理熵的生成
    mnemonic = Bip39MnemonicGenerator(Bip39Languages.ENGLISH).FromWordsNumber(Bip39WordsNum.WORDS_NUM_24)
    # 仅打印助记词到 stdout
    print(str(mnemonic))
    sys.stdout.flush()
except ImportError:
    print("Error: bip_utils library not found. Please run: pip install bip_utils", file=sys.stderr)
    sys.exit(1)
except Exception as e:
    print(f"Error generating mnemonic: {e}", file=sys.stderr)
    sys.exit(1)
'
}

# 获取并验证密码
get_password() {
    local prompt_message=$1
    local password=""
    local password_confirm=""
    while true; do
        read -sp "$prompt_message (输入时不会显示，最少 $MIN_PASSWORD_LENGTH 位): " password
        echo # 换行
        if [[ -z "$password" ]]; then
            echo "错误：密码不能为空！请重新输入。"
            continue
        fi
        if [[ ${#password} -lt $MIN_PASSWORD_LENGTH ]]; then
            echo "错误：密码太短，至少需要 $MIN_PASSWORD_LENGTH 个字符。请重新输入。"
            continue
        fi
        # 基础复杂度检查：可以根据需要添加更多规则 (例如: =~ [A-Z] && =~ [a-z] && =~ [0-9])
        # 为了通用性，这里只检查长度
        read -sp "请再次输入密码以确认: " password_confirm
        echo # 换行
        if [[ "$password" == "$password_confirm" ]]; then
            break
        else
            echo "错误：两次输入的密码不匹配！请重新输入。"
        fi
    done
    # 将密码存储在提供的变量名中 (通过 caller)
    # 注意：这里我们将密码直接返回给调用者处理，而不是存储在全局变量中
    # 调用者负责在使用后 unset 变量
     printf "%s" "$password" # 使用 printf 避免换行符
}

# 清理敏感变量
cleanup_vars() {
    unset mnemonic password password_decrypt encrypted_string decrypted_mnemonic password_input encrypted_string_input
    # echo "Debug: Sensitive variables cleared." # 用于调试
}

# --- 主逻辑 ---

# 选项 1: 生成并加密
generate_and_encrypt() {
    echo "正在生成 24 位 BIP39 助记词 (不会显示)..."
    local mnemonic
    # 捕获内部函数的输出到变量，而不是打印
    mnemonic=$(generate_mnemonic_internal)
    if [[ $? -ne 0 ]] || [[ -z "$mnemonic" ]]; then
        echo "错误：生成助记词失败。" >&2
        cleanup_vars # 清理可能的残留
        return 1 # 返回错误状态
    fi
    # echo "Debug: Mnemonic generated (length: ${#mnemonic})" # 仅用于调试，生产中注释掉

    local password_input
    echo "请输入用于加密助记词的密码。"
    password_input=$(get_password "设置加密密码")
    if [[ -z "$password_input" ]]; then
         echo "错误: 未能获取有效密码。" >&2
         cleanup_vars
         return 1
    fi

    echo "正在使用 ${ENCRYPTION_ALGO} 加密助记词..."
    local encrypted_string
    # 使用 heredoc 将助记词传递给 openssl stdin，避免在命令行参数中暴露
    # 使用 -pass pass:"$password" 直接传递密码
    encrypted_string=$(openssl enc $OPENSSL_OPTS -pass pass:"$password_input" <<< "$mnemonic")

    if [[ $? -ne 0 ]] || [[ -z "$encrypted_string" ]]; then
        echo "错误：加密失败！" >&2
        cleanup_vars # 清理密码和助记词
        return 1
    fi

    echo "--------------------------------------------------"
    echo "✅ 助记词已生成并加密成功！"
    echo "👇 请妥善备份以下【加密后的字符串】:"
    echo ""
    echo "$encrypted_string"
    echo ""
    echo "--------------------------------------------------"
    echo "⚠️ 重要提示："
    echo "   1. **务必记住** 您刚才设置的【密码】！"
    echo "   2. 没有正确的密码，上面的加密字符串将【无法解密】！"
    echo "   3. 助记词原文未在此过程中显示或保存。"
    echo "--------------------------------------------------"

    # 操作完成后清理敏感变量
    cleanup_vars
    # 显式清除 password_input (虽然 cleanup_vars 应该包含了它)
    unset password_input
}

# 选项 2: 解密并显示
decrypt_and_display() {
    echo "--------------------------------------------------"
    echo "⚠️ 警告：强烈建议在断开网络连接（例如开启飞行模式）的情况下执行此操作！"
    echo "--------------------------------------------------"
    read -p "按 Enter 键继续，或按 Ctrl+C 取消..."

    local encrypted_string_input
    echo "请粘贴之前保存的【加密字符串】:"
    # 使用 read -r 防止反斜杠被解释
    read -r encrypted_string_input
    if [[ -z "$encrypted_string_input" ]]; then
        echo "错误：未输入加密字符串。" >&2
        cleanup_vars
        return 1
    fi

    local password_input
    echo "请输入解密密码。"
    password_input=$(get_password "输入解密密码")
     if [[ -z "$password_input" ]]; then
         echo "错误: 未能获取有效密码。" >&2
         cleanup_vars
         return 1
    fi

    echo "正在尝试解密..."
    local decrypted_mnemonic
    # 使用 heredoc 传递加密字符串给 openssl stdin
    decrypted_mnemonic=$(openssl enc -d $OPENSSL_OPTS -pass pass:"$password_input" <<< "$encrypted_string_input" 2> /dev/null) # 将 stderr 重定向，避免显示 "bad decrypt" 等信息给用户，只通过退出码判断

    # 检查 openssl 的退出状态码
    if [[ $? -ne 0 ]]; then
        echo "--------------------------------------------------"
        echo "❌ 错误：解密失败！" >&2
        echo "   - 请仔细检查您输入的【加密字符串】是否完整且无误。" >&2
        echo "   - 请确认您输入的【解密密码】是否完全正确。" >&2
        echo "--------------------------------------------------"
        cleanup_vars # 清理密码和输入的字符串
        return 1
    fi

     if [[ -z "$decrypted_mnemonic" ]]; then
         echo "--------------------------------------------------"
         echo "❌ 错误：解密结果为空！" >&2
         echo "   这可能表示解密过程异常，即使没有报告错误。" >&2
         echo "   请检查原始加密字符串和密码。" >&2
         echo "--------------------------------------------------"
         cleanup_vars
         return 1
     fi


    echo "--------------------------------------------------"
    echo "✅ 解密成功！您的 BIP39 助记词是:"
    echo ""
    echo "$decrypted_mnemonic"
    echo ""
    echo "--------------------------------------------------"
    echo "⚠️ 重要提示："
    echo "   1. **立即安全地记录** 上述助记词原文！确保周围无人窥视。"
    echo "   2. 最好将其抄写在物理介质上，并存放在安全的地方。"
    echo "   3. 确认记录无误后，**强烈建议清除终端屏幕和历史记录**！"
    echo "      - 清屏: 可以尝试输入 'clear' 命令。"
    echo "      - 清除历史记录: 输入 'history -c && history -w' (或退出 Termux 会话)。"
    echo "--------------------------------------------------"

    # 操作完成后清理敏感变量
    cleanup_vars
    # 显式清除 password_input (虽然 cleanup_vars 应该包含了它)
    unset password_input
}

# --- 脚本入口 ---

# 首先检查依赖
check_dependencies

# 主菜单循环
while true; do
    echo ""
    echo "=============================="
    echo "  BIP39 助记词安全管理器"
    echo "=============================="
    echo "请选择操作:"
    echo "  1. 生成新的 BIP39 助记词并加密保存"
    echo "  2. 解密已保存的字符串以查看助记词"
    echo "  q. 退出脚本"
    echo "------------------------------"
    read -p "请输入选项 [1/2/q]: " choice

    case "$choice" in
        1)
            generate_and_encrypt
            ;;
        2)
            decrypt_and_display
            ;;
        q | Q)
            echo "正在退出..."
            cleanup_vars # 退出前也清理一下
            exit 0
            ;;
        *)
            echo "无效选项 '$choice'，请重新输入。"
            ;;
    esac
    # 在每次操作后暂停，等待用户确认，防止信息快速滚动消失
    read -n 1 -s -r -p "按任意键返回主菜单..."
    echo # 换行
done
