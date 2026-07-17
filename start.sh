#!/bin/sh

# 替换配置文件中的 UUID
sed -i "s/PASTE_YOUR_UUID_HERE/$UUID/g" config.json

# ==================================================================
# 🚀 导出变量为全局环境变量，确保后台 web_server.sh 子进程能正确读取
# ==================================================================
if [ -n "$UUID" ] && [ -n "$DOMAIN" ]; then
    export NODE_TLS="vless://${UUID}@${DOMAIN}:443?encryption=none&security=tls&sni=${DOMAIN}&type=ws&host=${DOMAIN}&path=%2Fvless#🇸🇬🌍🇸🇬新加坡备用_Railway"
    export NODE_NOTLS="vless://${UUID}@www.shopify.com:80?encryption=none&security=none&sni=${DOMAIN}&type=ws&host=${DOMAIN}&path=%2Fvless#🇸🇬🌍🇸🇬新加坡备用_Railway"
else
    export NODE_TLS="[提示] 请在 Koyeb 环境变量里补全 UUID 和 DOMAIN 参数，否则链接无法正确生成"
    export NODE_NOTLS="[提示] 请在 Koyeb 环境变量里补全 UUID 和 DOMAIN 参数，否则链接无法正确生成"
fi

# ==================================================================
# 🛠️ 升级保活 Web 服务（注意：EOF 外面加了单引号，防止变量提前被清空）
# ==================================================================
cat << 'EOF' > /app/web_server.sh
#!/bin/sh
HTML_HOME_BODY="Keep-Alive Server OK"

while true; do
  # 监听 8080 端口，并读取客户端发送的 HTTP 请求第一行
  REQUEST=$(nc -lp 8080 | head -n 1)
  
  # 解析请求路径 (Path)
  PATH_REQ=$(echo "$REQUEST" | awk '{print $2}')
  
  if [ "$PATH_REQ" = "/sub" ]; then
    # 动态拼接节点内容，确保每次请求时都去读最新的环境变量
    HTML_SUB_BODY="${NODE_TLS}\n\n非TLS，用80端口，节点如下：\n${NODE_NOTLS}"
    RESPONSE="HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nConnection: close\r\n\r\n$HTML_SUB_BODY"
  else
    # 默认其他路径（如根路径 /）返回保活文本
    RESPONSE="HTTP/1.1 200 OK\r\nContent-Type: text/plain; charset=utf-8\r\nConnection: close\r\n\r\n$HTML_HOME_BODY"
  fi
  
  # 发送响应
  echo -e "$RESPONSE" | nc -lp 8080 >/dev/null 2>&1
done
EOF

chmod +x /app/web_server.sh
/app/web_server.sh & # 后台静默启动

# 1. 后台运行 sing-box（在内部监听 8050）
sing-box run -c config.json &

# ==================================================================
# 打印控制台提示（部署成功后可在 Koyeb 日志中看到）
# ==================================================================
echo "=================================================================="
echo "🚀 专属容器部署成功！您的 VLESS 万能快捷导入节点如下："
echo "------------------------------------------------------------------"
echo "TLS（443端口）节点："
echo "$NODE_TLS"
echo "------------------------------------------------------------------"
echo "非TLS（80端口）节点："
echo "$NODE_NOTLS"
echo "=================================================================="

# 2. 前台运行 Cloudflare Tunnel
if [ -n "$ARGO_TOKEN" ]; then
    echo "正在启动 Cloudflare Tunnel..."
    cloudflared tunnel --no-autoupdate run --token $ARGO_TOKEN
else
    echo "[警告] 未检测到 ARGO_TOKEN，寻求保持容器运行..."
    wait
fi
