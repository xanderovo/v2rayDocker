#!/bin/bash
# FILE="/etc/Caddy"
domain="$1"
v2ray_path="$2"
uuid="51be9a06-299f-43b9-b713-1ec5eb76e3d7"
if  [ ! "$3" ] ;then
    uuid=$(uuidgen)
    echo "uuid 将会系统随机生成"
else
    uuid="$3"
fi
cat > /etc/Caddyfile <<'EOF'
domain
{
  log ./caddy.log
  proxy /v2ray_path :2333 {
    websocket
    header_upstream -Origin
  }
}

EOF
sed -i "s/domain/${domain}/" /etc/Caddyfile
sed -i "s/v2ray_path/${v2ray_path}/" /etc/Caddyfile

# v2ray
cat > /etc/v2ray/config.json <<'EOF'
{
  "inbounds": [
    {
      "port": 2333,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "uuid",
            "alterId": 64
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": {
        "path": "/v2ray_path"
        }
      }
    }
  ],
  "outbounds": [
    {
      "protocol": "freedom",
      "settings": {}
    }
  ]
}

EOF

sed -i "s/uuid/${uuid}/" /etc/v2ray/config.json
sed -i "s/v2ray_path/${v2ray_path}/" /etc/v2ray/config.json

cat > /srv/sebs.js <<'EOF'
 {
    "add":"domain",
    "aid":"64",
    "host":"",
    "id":"uuid",
    "net":"ws",
    "path":"/v2ray_path",
    "port":"443",
    "ps":"V2RAY_WS",
    "tls":"tls",
    "type":"none",
    "v":"2"
  }
EOF

sed -i "s/domain/${domain}/" /srv/sebs.js
sed -i "s/uuid/${uuid}/" /srv/sebs.js
sed -i "s/v2ray_path/${v2ray_path}/" /srv/sebs.js
pwd
cp /etc/Caddyfile .
nohup /bin/parent caddy  --log stdout --agree=false &
echo "配置 JSON 详情"
echo " "
cat /etc/v2ray/config.json
echo " "
node v2ray.js
/usr/bin/v2ray -config /etc/v2ray/config.json
