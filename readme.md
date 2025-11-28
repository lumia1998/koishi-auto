# Koishi-Auto 使用教程

## 部署

1.  确保您的 Linux 服务器已安装 Docker 功能并配置好科学上网。
2.  通过 SSH 连接到您的服务器并执行以下命令：
    ```bash
    git clone https://github.com/lumia1998/koishi-auto
    cd koishi-auto
    NAPCAT_UID=$(id -u) NAPCAT_GID=$(id -g) docker-compose up -d
    ```
    ![部署命令](https://pic1.imgdb.cn/item/690da1b83203f7be00e12073.png)

## Napcat 配置

1.  进入 Napcat 的管理界面：`http://服务器ip:6099`，输入密码 `root` 进入。然后点击扫码登录，使用您的 QQ 扫描二维码进入后台。
2.  点击左侧第二个选项“网络配置”，新建一个 Websocket 服务器，配置如下图所示：
    ![新建 Websocket 服务器](https://pic1.imgdb.cn/item/690da2203203f7be00e12164.png)
    ![配置详情1](https://pic1.imgdb.cn/item/690da2613203f7be00e121e6.png)
    ![配置详情2](https://pic1.imgdb.cn/item/690da2783203f7be00e1224f.png)
    ![配置详情3](https://pic1.imgdb.cn/item/690da28b3203f7be00e122c6.png)

## Koishi 配置

1.  进入 Koishi 的管理界面：`http://服务器ip:5140`，账号和密码均为 `admin`。
    ![Koishi 登录](https://pic1.imgdb.cn/item/690da2f93203f7be00e12411.png)
2.  点击左侧第二个齿轮图标，然后依次点击分组：`系统配置` -> `adapter-onebot` -> `插件配置` -> `连接设置`。将 `path` 修改为 `ws://服务器ip:43001`。
    ![修改 Path](https://pic1.imgdb.cn/item/690da3fb3203f7be00e12819.png)
3.  检查 OneBot 机器人是否连接成功（查看右下角是否获取到 Bot 头像并且指示灯为绿色）。
    ![检查连接状态](https://pic1.imgdb.cn/item/690da42f3203f7be00e12837.png)
4.  点击左下角个人图标，输入您的 Bot QQ 账号后点击“获取验证码”，然后将收到的验证码私聊发送给您的 Bot。
    ![获取验证码](https://pic1.imgdb.cn/item/690da4563203f7be00e12843.png)
5.  进入“插件管理”，打开“系统配置”分组下的 `change-auth-callme` 插件。私聊您的 Bot 发送 `changeauth 5`，之后关闭此插件。
    ![配置插件](https://pic1.imgdb.cn/item/690da4853203f7be00e12858.png)
