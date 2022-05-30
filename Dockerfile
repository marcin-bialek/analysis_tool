FROM nginx
COPY ./build/web/ /usr/share/nginx/html
EXPOSE 8000:80

