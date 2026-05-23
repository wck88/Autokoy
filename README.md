# 🚀 科学上网节点极速部署指南 (Sing-box + Cloudflare Tunnel)  Koyeb

本项目提供了一个基于 Docker 容器的轻量级、高隐匿性科学上网节点部署方案。通过集成 `sing-box` 和 `cloudflared`，你可以轻松地在各类云平台（如 Koyeb、Render 等）或个人 VPS 上一键构建安全隧道。

## ✨ 核心特性

* **轻量高效**：基于 Alpine Linux 和 Docker 构建，占用资源极低。
* **高隐匿性**：利用 Cloudflare Tunnel 穿透内网，隐藏真实服务器 IP，有效防封锁。
* **协议先进**：采用目前最强大的核心 `sing-box`，默认配置 VLESS 协议。
* **自动化构建**：已配置 GitHub Actions，修改代码后自动打包 Docker 镜像到 Github Packages (`ghcr.io`)。
* **灵活配置**：通过环境变量注入 UUID 和 Token，无需修改代码即可动态部署。

## 📦 项目结构

* `Dockerfile`: 自动拉取并构建所需组件的 Docker 镜像配置。
* `config.json`: `sing-box` 的核心路由与协议配置文件。
* `start.sh`: 容器启动脚本，负责替换环境变量并同时运行双进程。

---

## 🛠️ 部署教程

本项目支持在任何兼容 Docker 的环境中部署。以下以常见云 PaaS 平台为例。

### 准备工作

1.  **Cloudflare Tunnel**:
    * 登录 [Cloudflare Zero Trust](https://dash.teams.cloudflare.com/) 面板。
    * 导航至 **Networks** -> **Tunnels**，创建一个新的 Tunnel。
    * 保存生成的 **Tunnel Token** (即 `ARGO_TOKEN`)。
    * 为该 Tunnel 配置一个 Public Hostname（例如 `proxy.yourdomain.com`），并将服务指向 `**http://localhost:8085**`。

2.  **生成 UUID**:
    * 使用在线工具或命令行（如 `uuidgen`）生成一个符合标准格式的 UUID（例如：`123e4567-e89b-12d3-a456-426614174000`）。

### 开始部署

在部署平台（如 Koyeb）创建新应用时，请确保设置以下**环境变量 (Environment Variables)**：

| 变量名 | 说明 | 示例 |
| :--- | :--- | :--- |
| `UUID` | 你的节点连接密码 | `你的随机UUID` |
| `ARGO_TOKEN` | Cloudflare Tunnel 的 Token | `eyJh...` |
| `DOMAIN`|隧道域名|
|`PORT`|8080|

uuid生成器 [点击生成](https://99688988.xyz/uuid-generator/)

Koyeb 改端口为：8080  

### 客户端连接

部署成功后，在你的代理客户端（如 v2rayN, Clash 等）中添加如下节点信息：

* **地址 (Address)**: 你在 Cloudflare 设置的 Public Hostname (例如 `proxy.yourdomain.com`)
* **端口 (Port)**: `443`
* **用户 ID (UUID)**: 你设置的 `$UUID`
* **传输协议 (Network)**: `ws` (WebSocket)
* **伪装域名 (SNI)**: 你的 Public Hostname
* **底层安全 (TLS)**: 开启 (`tls`)

快捷分享链接 (URI 格式) 示例

如果你熟悉直接拼接链接，它大概长这个样子（把中括号里的内容替换成你的真实信息）：

vless://你的UUID@你的Tunnel域名（或者优选域名）:443?encryption=none&security=tls&sni=你的Tunnel域名&insecure=0&allowInsecure=0&type=ws&host=你的Tunnel域名&path=%2Fvless#Koyeb-Singbox

如果速度太慢在 地址 (Address) 可换成优选域名 [点击获取优选域名](https://kjgx668.blogspot.com/2023/08/cloudflare-ip-cloudflare-cf.html)

**登录 Cloudflare Zero Trust 控制台。**
**原来可能是：http://localhost:8080    请修改为http://localhost:8085**

## 进阶玩法：保活

重新提交并测试
把修改后的代码推送到 GitHub，等待 GitHub Actions 编译并重新发布。

重新部署完成后，再次刷新 https://app-name-username.koyeb.app/。

此时页面应该能正常打开，并显示：Keep-Alive Server OK。

只要这个页面能打开，你的 sing-box 代理节点（通过隧道或者直连）就能正常恢复连接。

去 UptimeRobot 官网注册一个免费账号，添加一个 HTTP(s) 监控，网址填入你的这个 koyeb.app 链接，频率设置为 5分钟。
