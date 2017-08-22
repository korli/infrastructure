#!/bin/sh

cat nginx.conf.top >nginx.conf

SERVERS="${@/%/.haiku-os.org}"
SERVERS="haiku-os.org $SERVERS"

echo "### auto-generated by $0" >>nginx.conf
for server in $SERVERS
do
	echo "Adding section for $server..."
	cat >>nginx.conf <<EOF
	server {
		listen 443 ssl http2;
		listen [::]:443 ssl http2;
		server_name $server;
		ssl_certificate /letsencrypt/live/$server/fullchain.pem;
		ssl_certificate_key /letsencrypt/live/$server/privkey.pem;

		location / {
			proxy_pass http://78.46.189.196:8081;
			proxy_set_header Host \$host;
			proxy_set_header X-Real-IP \$remote_addr;
			proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
		}

		location /.well-known/acme-challenge/ {
			alias /letsencrypt/acme/;
		}
	}
EOF
done

cat nginx.conf.bottom >>nginx.conf

