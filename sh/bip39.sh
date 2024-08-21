#!/bin/bash

# BIP-39 词表下载地址
WORDLIST_URL="https://raw.githubusercontent.com/bitcoin/bips/master/bip-0039/english.txt"
WORDLIST_FILE="/tmp/bip39_wordlist.txt"

# 下载词表文件到临时目录
if [[ ! -f $WORDLIST_FILE ]]; then
  echo "Downloading BIP-39 wordlist..."
  curl -s -o $WORDLIST_FILE $WORDLIST_URL
  if [[ $? -ne 0 ]]; then
    echo "Failed to download the BIP-39 wordlist."
    exit 1
  fi
fi

# 读取词表到数组中
mapfile -t WORDLIST < $WORDLIST_FILE

# 生成256位（32字节）的真随机熵
generate_entropy() {
  ENTROPY=""
  for ((i=0; i<32; i++)); do
    BYTE=$(printf "%02x" $((RANDOM%256)))
    ENTROPY="${ENTROPY}${BYTE}"
  done
  echo $ENTROPY
}

ENTROPY=$(generate_entropy)

# 计算校验和，将熵进行SHA-256哈希并取前8位二进制数作为校验位
CHECKSUM=$(echo -n $ENTROPY | sha256sum | cut -c1-2)
CHECKSUM_BIN=$(echo "ibase=16; obase=2; ${CHECKSUM^^}" | awk '{printf "%08d\n", $1}')

# 将熵转换为二进制字符串
ENTROPY_BIN=""
for ((i=0; i<${#ENTROPY}; i+=2)); do
  BYTE=${ENTROPY:$i:2}
  BYTE_BIN=$(echo "ibase=16; obase=2; ${BYTE^^}" | bc | awk '{printf "%08d\n", $1}')
  ENTROPY_BIN="${ENTROPY_BIN}${BYTE_BIN}"
done

# 拼接熵和校验位
FINAL_BIN="${ENTROPY_BIN}${CHECKSUM_BIN}"

# 将二进制字符串分割为11位一组，映射到助记词
for i in {0..23}; do
  # 提取11位
  BINARY_CHUNK=${FINAL_BIN:$(($i * 11)):11}
  
  # 将二进制转换为十进制数
  INDEX=$(echo "ibase=2; $BINARY_CHUNK" | bc)
  
  # 获取对应的助记词
  MNEMONIC="${WORDLIST[$INDEX]}"
  
  # 输出助记词
  echo -n "$MNEMONIC "
done

echo # 换行
