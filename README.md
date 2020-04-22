# Container with all necessary to use develop lumen

This image contains a all necessary to use lumen (laravel api)

- **php**: 7.4; with **xdebug** on port 9001

By default, the user is docker (docker:1000:1000), a non root user.

example of docker-compose.yml:

```yml
version: "3.7"
services:
  app:
    image: markdomkan/lumen
    container_name: app_name-php
    restart: unless-stopped
    working_dir: /app
    volumes:
      - ./:/app
      - ./container-config/php/local.ini:/usr/local/etc/php/conf.d/local.ini
    networks:
      - app_name-network
    depends_on:
      - "nginx"

  db:
    image: mysql:8.0.19
    container_name: app_name-db
    restart: unless-stopped
    command: --default-authentication-plugin=mysql_native_password
    ports:
      - 3306:3306
    environment:
      MYSQL_DATABASE: ${DB_DATABASE}
      MYSQL_ROOT_PASSWORD: ${DB_PASSWORD}
      MYSQL_PASSWORD: ${DB_PASSWORD}
      MYSQL_USER: ${DB_USERNAME}
    volumes:
      - dbdata:/var/lib/mysql/
    networks:
      - app_name-network

  nginx:
    image: nginx:alpine
    container_name: app_name-nginx
    restart: unless-stopped
    ports:
      - 8000:80
    volumes:
      - ./:/app
      - ./container-config/nginx:/etc/nginx/conf.d/
    networks:
      - app_name-network

networks:
  app_name-network:
    driver: bridge
volumes:
  dbdata:
    driver: local
```

docker-compose/nginx/default.conf:

```conf
server {
    listen 80;
    index index.php index.html;
    error_log  /var/log/nginx/error.log;
    access_log /var/log/nginx/access.log;
    root /app/public;
    location ~ \.php$ {
        try_files $uri =404;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass app_name-php:9000;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PATH_INFO $fastcgi_path_info;
    }
    location / {
        try_files $uri $uri/ /index.php?$query_string;
        gzip_static on;
    }
}

```

Put on **container-config/php/local.ini** your custom php configuration.
