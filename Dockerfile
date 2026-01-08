# 1. Use PHP 8.2 with Apache
FROM php:8.2-apache

# 2. Install PHP extensions AND Node.js (for Vite/Frontend)
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# 3. Apache Config (Enable Mod Rewrite for Laravel)
RUN a2enmod rewrite
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# 4. Set Working Directory
WORKDIR /var/www/html

# 5. Copy Application Files
COPY . /var/www/html

# 6. Install PHP Dependencies (Composer)
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-interaction --optimize-autoloader --no-dev

# 7. Install Frontend Dependencies (NPM) & Build Assets
RUN npm install
RUN npm run build

# 8. Set Permissions (Crucial for Laravel Logging/Cache)
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# 9. Expose Port
EXPOSE 80