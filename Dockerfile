FROM php:8.2-apache

# 1. Install system dependencies and PostgreSQL development libraries
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libpng-dev \
    zip \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_pgsql gd

# 2. Configure Apache Document Root to point to Laravel's public folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 3. Enable Apache mod_rewrite and explicitly allow directory overrides
RUN a2enmod rewrite
RUN echo '<Directory /var/www/html/public>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf

# 4. Change Apache port from 80 to 10000 for Render compatibility
RUN sed -i 's/Listen 80/Listen 10000/' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:10000>/' /etc/apache2/sites-available/000-default.conf

# 5. Set working directory
WORKDIR /var/www/html

# 6. Copy application code into the container
COPY . .

# 7. Install Composer (multi-stage copy from official image)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 8. Run Composer install optimized for production
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev

# 9. Set strict permissions for Laravel storage and cache directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 10. Expose port 10000
EXPOSE 10000

# 11. Use an entrypoint script to handle migrations and optimization runtime
COPY docker-entrypoint.sh /usr/local/bin/run-app
RUN chmod +x /usr/local/bin/run-app

ENTRYPOINT ["run-app"]