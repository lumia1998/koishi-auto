#!/bin/bash

# --- 1. 解压文件 ---
echo "⚙️ 正在解压 koishi-auto.zip..."
unzip -o koishi-auto.zip -d .
if [ $? -eq 0 ]; then
    echo "✅ 解压成功。"
    echo "🗑️ 正在删除 koishi-auto.zip..."
    rm koishi-auto.zip
    echo "✅ 压缩包已删除。"
else
    echo "❌ 解压失败，请检查 'unzip' 命令是否已安装以及文件是否完整。"
    exit 1
fi

# --- 2. 检查依赖 ---
if ! command -v docker-compose &> /dev/null
then
    echo "错误：未找到 docker-compose 命令。请先安装 Docker 和 Docker Compose。"
    exit 1
fi

# --- 2. 动态获取当前用户 ID (UID) 和组 ID (GID) ---
HOST_UID=$(id -u)
HOST_GID=$(id -g)

echo "================================================="
echo "⚙️ 正在使用当前宿主机用户权限启动服务："
echo "   - NAPCAT_UID: $HOST_UID"
echo "   - NAPCAT_GID: $HOST_GID"
echo "================================================="

# --- 3. 运行 Docker Compose ---
# 将获取到的 UID 和 GID 作为环境变量传入 docker-compose up 命令
# -d 代表后台运行
NAPCAT_UID=$HOST_UID NAPCAT_GID=$HOST_GID docker-compose up -d

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 服务启动成功！"
    echo "Koishi 控制台访问端口: 5140 (如果 koishi 容器运行正常)"
else
    echo ""
    echo "❌ Docker Compose 启动失败，请检查错误信息。"
fi
