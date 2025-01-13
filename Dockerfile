FROM php:7.4.33-apache
#TODO DevOps - Versão para sandbox. Requer revisão para execução em produção

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    zip \
    unzip \
    git \
    libzip-dev \
    gettext-base \
    nodejs \
    npm \
    openssl \
    cron \
    acl

# Instalar Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Configurar e instalar extensões PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install gd
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install zip

# Copiar arquivos do projeto para o diretório temporário
RUN mkdir -p /var/www

#TODO DevOps - definir a versão. As versões superiores apresentaram bugs significativos. A documentação oficial indica essa versão: https://sendportal.io/docs
RUN git clone --depth 1 --branch v2.0.0 https://github.com/mettle/sendportal.git /var/www/html

WORKDIR /var/www/html/

COPY .env .
COPY app/ .
COPY routes/ .

RUN mkdir -p /var/www/html/storage /var/www/html/bootstrap/cache

RUN chown -R www-data:www-data /var/www/html/
RUN git config --global --add safe.directory /var/www/html

# Executar Composer install sem pedir confirmação do usuário
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Configurar permissões antes de rodar os comandos npm
RUN chown -R www-data:www-data /var/www/html/vendor/mettle/sendportal-core
RUN chmod -R 755 /var/www/html/vendor/mettle/sendportal-core

# Configurar o diretório de trabalho final
WORKDIR /var/www/html/public

# Configurar permissões finais
RUN chown -R www-data:www-data /var/www/html/public /var/www/html/storage /var/www/html/bootstrap/cache
RUN chmod -R 775 /var/www/html/public
RUN setfacl -R -d -m u:www-data:rwx /var/www/html/storage /var/www/html/bootstrap/cache

# Navegar para o diretório do Sendportal Core e executar npm ci e npm run dev
RUN cd /var/www/html/vendor/mettle/sendportal-core && npm ci && npm run dev

# Habilitar o módulo de reescrita do Apache
RUN a2enmod rewrite

# Habilitar o módulo dir do Apache
RUN a2enmod dir

# Habilitar o módulo SSL do Apache
RUN a2enmod ssl

# Gerar certificado autoassinado
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/selfsigned.key -out /etc/ssl/certs/selfsigned.crt -subj "/CN=localhost"

# Adicionar a configuração do virtual host ao Apache
COPY vhost-ssl.conf.template /etc/apache2/sites-available/localhost.conf

# Adicionar a configuração SSL do virtual host ao Apache
COPY vhost-ssl.conf.template /etc/apache2/sites-available/localhost-ssl.conf

# Habilitar o site (criar link simbólico em sites-enabled)
RUN ln -s /etc/apache2/sites-available/localhost.conf /etc/apache2/sites-enabled/localhost.conf
RUN ln -s /etc/apache2/sites-available/localhost-ssl.conf /etc/apache2/sites-enabled/localhost-ssl.conf

# Configurar o ServerName e outras diretivas globalmente no Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf
RUN echo 'DirectoryIndex index.php index.html' >> /etc/apache2/apache2.conf
RUN echo 'DocumentRoot /var/www/html/public' >> /etc/apache2/apache2.conf

# Desabilitar o virtual host padrão do Apache
RUN a2dissite 000-default.conf

# Habilitar o host customizado
RUN a2ensite localhost.conf
RUN a2ensite localhost-ssl.conf

# Adicionar o cron job ao crontab e redirecionar o log para cron.log
RUN echo "* * * * * cd /var/www/html && /usr/local/bin/php artisan schedule:run >> /var/log/cron.log 2>&1" > /etc/cron.d/artisan-schedule
RUN chmod 0644 /etc/cron.d/artisan-schedule
RUN crontab /etc/cron.d/artisan-schedule

# Criar o diretório para o PID do cron e iniciar o cron e o Apache
RUN touch /var/log/cron.log

# Expor as portas 80 e 443
EXPOSE 80 443

# Comando para iniciar o cron e o Apache
CMD ["sh", "-c", "cron && tail -f /var/log/cron.log & apache2-foreground"]
