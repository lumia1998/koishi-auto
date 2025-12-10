#!/bin/bash

# --- 1. 创建目标文件夹 ---
echo "📁 正在创建 koishi-napcat 文件夹..."
mkdir -p koishi-napcat
if [ $? -eq 0 ]; then
    echo "✅ 文件夹创建成功。"
else
    echo "❌ 文件夹创建失败。"
    exit 1
fi

# --- 2. 解压 koishi_ai.tar.xz ---
echo "⚙️ 正在解压 koishi_ai.tar.xz 到 koishi-napcat 目录..."
tar -xvf koishi_ai.tar.xz -C koishi-napcat
if [ $? -eq 0 ]; then
    echo "✅ koishi_ai 解压成功。"
else
    echo "❌ koishi_ai 解压失败，请检查 'tar' 命令是否已安装以及文件是否完整。"
    exit 1
fi

# --- 3. 解压 napcat.tar.xz ---
echo "⚙️ 正在解压 napcat.tar.xz 到 koishi-napcat 目录..."
tar -xvf napcat.tar.xz -C koishi-napcat
if [ $? -eq 0 ]; then
    echo "✅ napcat 解压成功。"
else
    echo "❌ napcat 解压失败，请检查 'tar' 命令是否已安装以及文件是否完整。"
    exit 1
fi

# --- 4. 检查依赖 ---
if ! (command -v docker-compose &> /dev/null || command -v docker compose &> /dev/null); then
    echo "错误：未找到 'docker-compose' 或 'docker compose' 命令。请先安装 Docker 和 Docker Compose。"
    exit 1
fi

# --- 5. 动态获取当前用户 ID (UID) 和组 ID (GID) ---
HOST_UID=$(id -u)
HOST_GID=$(id -g)

echo "================================================="
echo "⚙️ 正在使用当前宿主机用户权限启动服务："
echo "   - NAPCAT_UID: $HOST_UID"
echo "   - NAPCAT_GID: $HOST_GID"
echo "================================================="

# --- 6. 运行 Docker Compose ---
# 将获取到的 UID 和 GID 作为环境变量传入 docker-compose up 命令
# -d 代表后台运行
# 尝试使用 docker-compose up -d
NAPCAT_UID=$HOST_UID NAPCAT_GID=$HOST_GID docker-compose up -d &> /dev/null

# 检查上一条命令的退出状态码
if [ $? -ne 0 ]; then
    echo "⚠️ 'docker-compose up' 执行失败，正在尝试 'docker compose up'..."
    # 尝试使用 docker compose up -d
    NAPCAT_UID=$HOST_UID NAPCAT_GID=$HOST_GID docker compose up -d
fi

# 再次检查退出状态码
if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 服务启动成功！"
    echo "Koishi 控制台访问端口: 5140 (如果 koishi 容器运行正常)"
else
    echo ""
    echo "❌ Docker Compose 启动失败，请检查错误信息。"
    echo "   请确认 Docker 是否正在运行，以及 docker-compose.yml 文件是否正确。"
fi
