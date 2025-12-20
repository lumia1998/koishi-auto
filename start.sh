#!/bin/bash

# --- 1. 配置与变量 ---
TARGET_DIR="koishi-napcat"
KOISHI_PKG="koishi_ai.tar.xz"
NAPCAT_PKG="napcat.tar.xz"
# 检查的端口范围：Koishi(5140), NapCat(6099), 以及一系列扩展端口
CHECK_PORTS=(5140 6099 3000 3001 3002 3003 3004 3005)

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' 

# 信号捕捉
trap "echo -e '\n${RED}🛑 操作已取消，正在退出...${NC}'; exit 1" INT

echo -e "${BLUE}=================================================${NC}"
echo -e "${BLUE}          Koishi-NapCat 自动化部署工具           ${NC}"
echo -e "${BLUE}=================================================${NC}"

# --- 2. 权限与系统识别 ---
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}❌ 权限不足：请使用 sudo ./脚本名 运行。${NC}"
    exit 1
fi

if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    OS_LIKE=$ID_LIKE
else
    echo -e "${RED}❌ 无法识别系统环境。${NC}"
    exit 1
fi
echo -e "✅ 检测到系统: ${GREEN}$PRETTY_NAME${NC}"

# --- 3. 环境依赖安装 ---
echo -e "⚙️ 正在检查 Docker 依赖..."
install_deps() {
    if [[ "$OS" == "ubuntu" || "$OS" == "debian" || "$OS_LIKE" == *"debian"* ]]; then
        apt-get update -y && apt-get install -y docker.io docker-compose-v2 tar xz-utils curl
    elif [[ "$OS" == "centos" || "$OS" == "rhel" || "$OS" == "rocky" || "$OS_LIKE" == *"rhel"* ]]; then
        yum install -y yum-utils
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin tar xz curl
    fi
    systemctl start docker && systemctl enable docker
}
install_deps > /dev/null 2>&1

# 确定 Compose 命令
COMPOSE_CMD="docker compose"
! $COMPOSE_CMD version &> /dev/null && COMPOSE_CMD="docker-compose"

# Docker 组优化
REAL_USER=${SUDO_USER:-$USER}
if [ "$REAL_USER" != "root" ]; then
    usermod -aG docker "$REAL_USER"
    echo -e "👤 用户权限已处理: ${GREEN}$REAL_USER${NC} 已加入 Docker 组。"
fi

# --- 4. 端口冲突预检 ---
echo -e "📡 正在扫描端口状态..."
OCCUPIED=()
for port in "${CHECK_PORTS[@]}"; do
    if ss -tuln | grep -q ":$port "; then
        OCCUPIED+=("$port")
    fi
done

if [ ${#OCCUPIED[@]} -ne 0 ]; then
    echo -e "${RED}❌ 部署终止：以下端口已被占用: ${OCCUPIED[*]}${NC}"
    echo -e "${YELLOW}💡 请关闭占用端口的服务后再重试。${NC}"
    exit 1
fi

# --- 5. 获取网络 IP ---
echo -e "🌐 正在获取网络信息..."
LOCAL_IP=$(hostname -I | awk '{print $1}')
PUBLIC_IP=$(curl -s --connect-timeout 3 ifconfig.me || echo "未分配/不可用")

# --- 6. 解压组件 ---
echo -e "📁 正在解压文件 (XZ 格式较慢，请稍等)..."
mkdir -p "$TARGET_DIR"
for pkg in "$KOISHI_PKG" "$NAPCAT_PKG"; do
    if [ ! -f "$pkg" ]; then
        echo -e "${RED}❌ 缺失文件: $pkg${NC}"
        exit 1
    fi
    echo -n "   📦 正在解压 $pkg... "
    tar -xf "$pkg" -C "$TARGET_DIR"
    echo -e "${GREEN}完成${NC}"
done

# --- 7. 启动服务与链接展示 ---
echo -e "🚀 正在通过 $COMPOSE_CMD 启动容器..."
cd "$TARGET_DIR" || exit 1

HOST_UID=$(id -u "$REAL_USER")
HOST_GID=$(id -g "$REAL_USER")



if NAPCAT_UID=$HOST_UID NAPCAT_GID=$HOST_GID $COMPOSE_CMD up -d; then
    echo -e "\n${GREEN}=================================================${NC}"
    echo -e "${GREEN}🎉 部署圆满成功！服务已在后台运行。${NC}"
    echo -e "-------------------------------------------------"
    
    echo -e "${BLUE}[ Koishi 控制台 ]${NC}"
    echo -e "  内网地址: ${YELLOW}http://$LOCAL_IP:5140${NC}"
    echo -e "  公网地址: ${YELLOW}http://$PUBLIC_IP:5140${NC}"
    
    echo -e "\n${BLUE}[ NapCat 管理界面 ]${NC}"
    echo -e "  内网地址: ${YELLOW}http://$LOCAL_IP:6099${NC}"
    echo -e "  公网地址: ${YELLOW}http://$PUBLIC_IP:6099${NC}"
    
    echo -e "-------------------------------------------------"
    echo -e "💡 温馨提示：若无法打开，请检查云服务器防火墙是否开放 5140/6099 端口。"
    echo -e "📄 查看运行状态: ${CYAN}$COMPOSE_CMD ps${NC}"
    echo -e "${GREEN}=================================================${NC}"
else
    echo -e "${RED}❌ 启动失败，请检查 docker-compose.yml 的配置。${NC}"
    exit 1
fi
