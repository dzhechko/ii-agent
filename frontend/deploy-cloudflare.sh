#!/bin/bash

# II-Agent Cloudflare Pages Deployment Script
# Usage: ./deploy-cloudflare.sh [production|preview]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Default environment
ENVIRONMENT=${1:-preview}
PROJECT_NAME="ii-agent-frontend"

print_status "Starting deployment to Cloudflare Pages..."
print_status "Environment: $ENVIRONMENT"
print_status "Project: $PROJECT_NAME"

# Check if wrangler is installed
if ! command -v npx wrangler &> /dev/null; then
    print_error "Wrangler CLI not found. Please install it: npm install -D wrangler"
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "package.json" ]; then
    print_error "package.json not found. Please run this script from the frontend directory."
    exit 1
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    print_status "Installing dependencies..."
    npm install
fi

# Build the project
print_status "Building Next.js application..."
if [ "$ENVIRONMENT" = "production" ]; then
    NODE_ENV=production npm run build
else
    npm run build
fi

# Check if build was successful
if [ ! -d ".next" ]; then
    print_error "Build failed. .next directory not found."
    exit 1
fi

print_success "Build completed successfully!"

# Deploy to Cloudflare Pages
print_status "Deploying to Cloudflare Pages..."

if [ "$ENVIRONMENT" = "production" ]; then
    print_status "Deploying to production..."
    npx wrangler pages deploy .next --project-name "$PROJECT_NAME" --env production
else
    print_status "Deploying to preview..."
    npx wrangler pages deploy .next --project-name "$PROJECT_NAME" --env preview
fi

print_success "Deployment completed!"
print_status "Your application should be available at:"

if [ "$ENVIRONMENT" = "production" ]; then
    echo -e "  ${GREEN}Production:${NC} https://$PROJECT_NAME.pages.dev"
else
    echo -e "  ${YELLOW}Preview:${NC} https://$(git rev-parse --short HEAD).$PROJECT_NAME.pages.dev"
fi

print_status "You can also view your deployments in the Cloudflare dashboard:"
echo -e "  https://dash.cloudflare.com/pages"

print_warning "Don't forget to:"
echo "  1. Set environment variables in Cloudflare dashboard"
echo "  2. Update backend URLs in .env.production"  
echo "  3. Configure custom domain if needed"