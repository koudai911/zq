#!/bin/bash

# 获取命令行传参
MINIO_URL="$1"  # 第一个参数：MinIO 服务器 URL
ACCESS_KEY="$2"  # 第二个参数：Access Key
SECRET_KEY="$3"  # 第三个参数：Secret Key
MINIO_BUCKET="$4"  # 第四个参数：存储桶名称
LOCAL_DIR="$5"  # 第五个参数：本地文件夹路径
REMOTE_DIR="$6"  # 第六个参数：MinIO 中的目标路径


# 下载 MinIO 客户端
wget https://dl.min.io/client/mc/release/linux-amd64/mc

# 给 mc 添加执行权限
chmod +x mc

# 将 mc 移动到 /usr/local/bin 目录，以便全局使用
sudo mv mc /usr/local/bin/
mc alias set myminio $MINIO_URL $ACCESS_KEY $SECRET_KEY


# 配置变量
MINIO_ALIAS="myminio"  # MinIO 别名

# 检查本地文件夹是否存在，如果不存在则创建
if [ ! -d "$LOCAL_DIR" ]; then
  echo "本地文件夹不存在，正在创建：$LOCAL_DIR"
  mkdir -p "$LOCAL_DIR"
fi

# 下载文件夹从 MinIO 到本地
echo "开始从 MinIO 下载文件夹..."
mc cp -r "$MINIO_ALIAS/$MINIO_BUCKET/$REMOTE_DIR" "$LOCAL_DIR"

# 检查下载是否成功
if [ $? -eq 0 ]; then
  echo "文件夹已成功下载到本地：$LOCAL_DIR"
else
  echo "下载失败，请检查 MinIO 配置或网络连接。"
  exit 1
fi
