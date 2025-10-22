#!/bin/bash

# FoundIt PostgreSQL Cleanup Script
# This script provides options to clean up PostgreSQL databases

set -e  # Exit on any error

echo "🧹 FoundIt PostgreSQL Cleanup"
echo "=============================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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

# Check if we're in the right directory
if [ ! -f "Gemfile" ]; then
    print_error "Gemfile not found. Please run this script from the FoundIt project root directory."
    exit 1
fi

# Check if PostgreSQL is running
if ! pg_isready -q; then
    print_error "PostgreSQL is not running. Please start PostgreSQL first."
    echo ""
    echo "For macOS (using Homebrew):"
    echo "  brew services start postgresql"
    echo ""
    echo "For Ubuntu/Debian:"
    echo "  sudo systemctl start postgresql"
    echo ""
    exit 1
fi

print_success "PostgreSQL is running"

# Show current databases
print_status "Current FoundIt databases:"
psql -lqt | grep foundit || echo "No FoundIt databases found"

echo ""
echo "Choose cleanup option:"
echo "1. Drop and recreate databases (NUCLEAR OPTION - loses all data)"
echo "2. Drop databases only"
echo "3. Recreate databases only"
echo "4. Reset development database only"
echo "5. Cancel"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        print_warning "NUCLEAR OPTION: This will delete ALL data!"
        read -p "Are you sure? Type 'yes' to confirm: " confirm
        if [ "$confirm" = "yes" ]; then
            print_status "Dropping databases..."
            dropdb foundit_development 2>/dev/null || print_warning "Development DB not found"
            dropdb foundit_test 2>/dev/null || print_warning "Test DB not found"
            
            print_status "Recreating databases..."
            createdb foundit_development
            createdb foundit_test
            
            print_status "Running migrations..."
            rails db:migrate
            
            print_status "Seeding database..."
            rails db:seed
            
            print_success "Complete reset completed!"
        else
            print_status "Operation cancelled"
        fi
        ;;
    2)
        print_warning "This will delete the databases but not recreate them"
        read -p "Are you sure? Type 'yes' to confirm: " confirm
        if [ "$confirm" = "yes" ]; then
            print_status "Dropping databases..."
            dropdb foundit_development 2>/dev/null || print_warning "Development DB not found"
            dropdb foundit_test 2>/dev/null || print_warning "Test DB not found"
            print_success "Databases dropped!"
        else
            print_status "Operation cancelled"
        fi
        ;;
    3)
        print_status "Recreating databases..."
        dropdb foundit_development 2>/dev/null || print_warning "Development DB not found"
        dropdb foundit_test 2>/dev/null || print_warning "Test DB not found"
        
        createdb foundit_development
        createdb foundit_test
        
        print_status "Running migrations..."
        rails db:migrate
        
        print_status "Seeding database..."
        rails db:seed
        
        print_success "Databases recreated!"
        ;;
    4)
        print_warning "This will reset only the development database"
        read -p "Are you sure? Type 'yes' to confirm: " confirm
        if [ "$confirm" = "yes" ]; then
            print_status "Resetting development database only..."
            
            # Drop only development database
            dropdb foundit_development 2>/dev/null || print_warning "Development DB not found"
            
            # Recreate only development database
            createdb foundit_development
            
            # Run migrations for development only
            RAILS_ENV=development rails db:migrate
            
            # Seed development database
            RAILS_ENV=development rails db:seed
            
            print_success "Development database reset! (Test database untouched)"
        else
            print_status "Operation cancelled"
        fi
        ;;
    5)
        print_status "Operation cancelled"
        exit 0
        ;;
    *)
        print_error "Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
print_success "Cleanup completed!"
echo ""
echo "Next steps:"
echo "1. Start the server: ./start_server.sh"
echo "2. Or run tests: ./run_tests.sh"
echo ""
