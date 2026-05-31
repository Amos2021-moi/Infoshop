#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "🚀 Running deployment optimizations..."

# Cache configuration and routes for production performance
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo "🗄️ Running database migrations..."
# --force is required to run migrations in production mode
php artisan migrate --force

echo "🎬 Starting Apache Web Server..."
exec apache2-foreground