FROM nginx

COPY nginx.conf /etc/nginx/nginx.conf

COPY app /usr/share/nginx/html

EXPOSE 80
