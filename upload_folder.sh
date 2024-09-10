#!/bin/bash

# 检查参数是否足够
if [ "$#" -ne 6 ]; then
    echo "用法: $0 <minio-server-url> <access-key> <secret-key> <bucket-name> <local-dir> <remote-dir>"
    echo "示例: $0 http://192.168.1.100:9000 myAccessKey mySecretKey myBucket /path/to/local/folder /path/on/minio"
    exit 1
fi

# 获取命令行传参
MINIO_URL="$1"  # 第一个参数：MinIO 服务器 URL
ACCESS_KEY="$2"  # 第二个参数：Access Key
SECRET_KEY="$3"  # 第三个参数：Secret Key
MINIO_BUCKET="$4"  # 第四个参数：存储桶名称
LOCAL_DIR="$5"  # 第五个参数：本地文件夹路径
REMOTE_DIR="$6"  # 第六个参数：MinIO 中的目标路径

# MinIO 客户端别名，随意设定
MINIO_ALIAS="myminio"

# 检查 MinIO 客户端 (mc) 是否安装
if ! command -v mc &> /dev/null
then
    echo "MinIO 客户端 (mc) 未安装，正在下载并安装..."
    wget https://dl.min.io/client/mc/release/linux-amd64/mc
    chmod +x mc
    sudo mv mc /usr/local/bin/
fi

# 配置 MinIO 远程服务器
echo "设置 MinIO 客户端别名..."
mc alias set $MINIO_ALIAS $MINIO_URL $ACCESS_KEY $SECRET_KEY

# 检查本地文件夹是否存在
if [ ! -d "$LOCAL_DIR" ]; then
  echo "本地文件夹不存在：$LOCAL_DIR"
  exit 1
fi


# 检查远程存储桶是否存在
if ! mc ls "$MINIO_ALIAS/$MINIO_BUCKET" &> /dev/null; then
  echo "存储桶 $MINIO_BUCKET 不存在，正在创建..."
  mc mb "$MINIO_ALIAS/$MINIO_BUCKET"
fi

# 上传文件夹到远程 MinIO
echo "正在上传文件夹到 MinIO..."
mc cp -r "$LOCAL_DIR" "$MINIO_ALIAS/$MINIO_BUCKET/$REMOTE_DIR"

# 检查上传结果
if [ $? -eq 0 ]; then
  echo "文件夹已成功上传到远程 MinIO！"
else
  echo "上传失败！"
fi
