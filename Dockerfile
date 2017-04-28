FROM httpd:alpine

LABEL maintainer "Stelligent, a divison of Hosting <http://www.stelligent.com>"

COPY html/index.html /usr/local/apache2/htdocs/index.html

EXPOSE 80

CMD ["httpd-foreground"]
