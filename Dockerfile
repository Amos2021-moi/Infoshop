FROM php:8.2-apache

# 1. Install system dependencies and PostgreSQL development libraries
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libpng-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo pdo_pgsql gd

# 2. Install Node.js (needed for building Inertia/Vite assets)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 3. Configure Apache Document Root to point to Laravel's public folder
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 4. Enable Apache mod_rewrite and explicitly allow directory overrides
RUN a2enmod rewrite
RUN echo '<Directory /var/www/html/public>\n\
    Options Indexes FollowSymLinks\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>' >> /etc/apache2/apache2.conf

# 5. Change Apache port from 80 to 10000 for Render compatibility
RUN sed -i 's/Listen 80/Listen 10000/' /etc/apache2/ports.conf
RUN sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:10000>/' /etc/apache2/sites-available/000-default.conf

# 6. Set working directory
WORKDIR /var/www/html

# 7. Copy application code into the container
COPY . .

# 8. Install Composer (multi-stage copy from official image)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# 9. Run Composer install optimized for production
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-interaction --optimize-autoloader --no-dev

# 10. Install Node dependencies and compile assets for production
RUN npm ci || npm install
RUN npm run build

# 11. Set strict permissions for Laravel storage and cache directories
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 12. Expose port 10000
EXPOSE 10000

# 13. Use your entrypoint script to handle migrations and optimization runtime
COPY docker-entrypoint.sh /usr/local/bin/run-app
RUN chmod +x /usr/local/bin/run-app

ENTRYPOINT ["run-app"]