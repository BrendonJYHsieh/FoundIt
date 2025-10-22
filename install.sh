#!/bin/bash

# FoundIt Installation Script
# This script automates the complete setup of the FoundIt application

set -e  # Exit on any error

echo "🔍 FoundIt - Columbia's Lost & Found Platform"
echo "=============================================="
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

print_status "Starting FoundIt installation..."

# Check system requirements
print_status "Checking system requirements..."

# Check if Ruby is installed
if ! command -v ruby &> /dev/null; then
    print_error "Ruby is not installed. Please install Ruby 3.3.4 or later."
    print_status "Visit: https://www.ruby-lang.org/en/downloads/"
    exit 1
fi

# Check Ruby version
RUBY_VERSION=$(ruby -v | cut -d' ' -f2 | cut -d'p' -f1)
REQUIRED_VERSION="3.3.4"
if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$RUBY_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    print_warning "Ruby version $RUBY_VERSION detected. Recommended: $REQUIRED_VERSION or later."
fi

# Check if Bundler is installed
if ! command -v bundle &> /dev/null; then
    print_status "Installing Bundler..."
    gem install bundler
fi

# Check if Node.js is installed (for asset compilation)
if ! command -v node &> /dev/null; then
    print_warning "Node.js is not installed. Some features may not work properly."
    print_status "Visit: https://nodejs.org/ to install Node.js"
fi

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    print_error "PostgreSQL is not installed. Please install PostgreSQL first:"
    echo ""
    echo "For macOS (using Homebrew):"
    echo "  brew install postgresql"
    echo "  brew services start postgresql"
    echo ""
    echo "For Ubuntu/Debian:"
    echo "  sudo apt update"
    echo "  sudo apt install postgresql postgresql-contrib"
    echo "  sudo systemctl start postgresql"
    echo "  sudo systemctl enable postgresql"
    echo ""
    echo "For Windows:"
    echo "  Download from https://www.postgresql.org/download/windows/"
    echo ""
    exit 1
fi

# Check if PostgreSQL service is running
if ! pg_isready -q; then
    print_warning "PostgreSQL service is not running. Starting it..."

    # Try to start PostgreSQL service
    if command -v brew &> /dev/null; then
        # macOS with Homebrew
        brew services start postgresql
    elif command -v systemctl &> /dev/null; then
        # Linux with systemd
        sudo systemctl start postgresql
    else
        print_error "Could not start PostgreSQL automatically. Please start it manually."
        exit 1
    fi

    # Wait a moment for the service to start
    sleep 3

    if ! pg_isready -q; then
        print_error "PostgreSQL service failed to start. Please start it manually."
        exit 1
    fi
fi

print_success "System requirements check completed."

# Install dependencies
print_status "Installing Ruby dependencies..."
bundle install

if [ $? -eq 0 ]; then
    print_success "Ruby dependencies installed successfully."
else
    print_error "Failed to install Ruby dependencies."
    exit 1
fi

# Set up database
print_status "Setting up PostgreSQL databases..."

# Create development database if it doesn't exist
print_status "Creating development database 'foundit_development' if it doesn't exist..."
if psql -lqt | cut -d \| -f 1 | grep -qw foundit_development; then
    print_success "Database 'foundit_development' already exists"
else
    createdb foundit_development
    if [ $? -eq 0 ]; then
        print_success "Database 'foundit_development' created successfully"
    else
        print_error "Failed to create development database. You may need to run: createdb foundit_development"
        exit 1
    fi
fi

# Create test database if it doesn't exist
print_status "Creating test database 'foundit_test' if it doesn't exist..."
if psql -lqt | cut -d \| -f 1 | grep -qw foundit_test; then
    print_success "Database 'foundit_test' already exists"
else
    createdb foundit_test
    if [ $? -eq 0 ]; then
        print_success "Database 'foundit_test' created successfully"
    else
        print_error "Failed to create test database. You may need to run: createdb foundit_test"
        exit 1
    fi
fi

# Run migrations
print_status "Running database migrations..."
rails db:migrate

if [ $? -eq 0 ]; then
    print_success "Database migrations completed successfully."
else
    print_error "Failed to run database migrations."
    exit 1
fi

# Seed database (optional)
print_status "Seeding database with sample data..."
rails db:seed

if [ $? -eq 0 ]; then
    print_success "Database seeded successfully."
else
    print_warning "Database seeding failed or no seed data available."
fi

# Run tests to verify installation
print_status "Running tests to verify installation..."

# Run RSpec tests
print_status "Running RSpec unit tests..."
bundle exec rspec --format progress

if [ $? -eq 0 ]; then
    print_success "RSpec tests passed successfully."
else
    print_warning "Some RSpec tests failed. Check the output above for details."
fi

# Run Cucumber tests (dry run)
print_status "Running Cucumber tests (dry run)..."
bundle exec cucumber --dry-run

if [ $? -eq 0 ]; then
    print_success "Cucumber tests are properly configured."
else
    print_warning "Cucumber tests may have issues. Check the output above for details."
fi

# Test authentication functionality
print_status "Testing authentication functionality..."
if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/signup | grep -q "200"; then
    print_success "Signup page is accessible."
else
    print_warning "Signup page may have issues."
fi

if curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/login | grep -q "200"; then
    print_success "Login page is accessible."
else
    print_warning "Login page may have issues."
fi

# Create sample environment file
print_status "Creating environment configuration..."
if [ ! -f ".env" ]; then
    cat > .env << EOF
# FoundIt Environment Configuration
# Copy this file to .env.local and customize as needed

# Rails Environment
RAILS_ENV=development

# Database Configuration
DATABASE_URL=postgresql://postgres@localhost:5432/foundit_development

# Security
SECRET_KEY_BASE=$(rails secret)

# Email Configuration (for production)
# SMTP_HOST=smtp.gmail.com
# SMTP_PORT=587
# SMTP_USERNAME=your-email@gmail.com
# SMTP_PASSWORD=your-app-password

# Application Settings
APP_NAME=FoundIt
APP_HOST=localhost
APP_PORT=3000
EOF
    print_success "Environment file created (.env)"
else
    print_status "Environment file already exists (.env)"
fi

# Create startup script
print_status "Creating startup script..."
cat > start_server.sh << 'EOF'
#!/bin/bash

# FoundIt Server Startup Script
echo "🔍 Starting FoundIt server..."
echo "=============================="

# Check if server is already running
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Server is already running on port 3000"
    echo "   Visit: http://localhost:3000"
    echo "   To stop: kill \$(lsof -t -i:3000)"
    exit 1
fi

# Start the server
echo "🚀 Starting Rails server on port 3000..."
echo "   Visit: http://localhost:3000"
echo "   Press Ctrl+C to stop"
echo ""

rails server -p 3000
EOF

chmod +x start_server.sh
print_success "Startup script created (start_server.sh)"

# Create test script
print_status "Creating test script..."
cat > run_tests.sh << 'EOF'
#!/bin/bash

# FoundIt Test Runner Script
echo "🧪 Running FoundIt Tests"
echo "========================"

echo ""
echo "📋 Running RSpec unit tests..."
bundle exec rspec --format documentation

echo ""
echo "📋 Running Cucumber integration tests..."
bundle exec cucumber --format pretty

echo ""
echo "✅ All tests completed!"
EOF

chmod +x run_tests.sh
print_success "Test script created (run_tests.sh)"

# Installation summary
echo ""
echo "🎉 Installation Complete!"
echo "========================"
echo ""
print_success "FoundIt has been successfully installed and configured."
echo ""
echo "📁 Project Structure:"
echo "   ├── app/          # Application code"
echo "   ├── spec/         # RSpec unit tests"
echo "   ├── features/     # Cucumber integration tests"
echo "   ├── db/           # Database files"
echo "   └── config/      # Configuration files"
echo ""
echo "🚀 Quick Start:"
echo "   1. Start the server: ./start_server.sh"
echo "   2. Open browser: http://localhost:3000"
echo "   3. Sign up with a Columbia email"
echo "   4. Start posting lost/found items!"
echo ""
echo "🧪 Testing:"
echo "   - Run all tests: ./run_tests.sh"
echo "   - RSpec only: bundle exec rspec"
echo "   - Cucumber only: bundle exec cucumber"
echo ""
echo "📚 Documentation:"
echo "   - README.md: Complete usage guide"
echo "   - MVP_Implementation_Summary.md: Technical details"
echo "   - Proposal.md: Original project proposal"
echo ""
echo "🔧 Development:"
echo "   - Database console: rails dbconsole"
echo "   - Rails console: rails console"
echo "   - Generate models: rails generate model ModelName"
echo "   - Run migrations: rails db:migrate"
echo ""
echo "🆘 Support:"
echo "   - Check logs: tail -f log/development.log"
echo "   - Restart server: Ctrl+C then ./start_server.sh"
echo "   - Reset database: rails db:reset"
echo ""

# Check if server can start
print_status "Testing server startup..."
timeout 10s rails server -p 3000 -d > /dev/null 2>&1

if [ $? -eq 0 ]; then
    print_success "Server test successful! FoundIt is ready to use."
    echo ""
    echo "🌐 Your FoundIt application is now running at:"
    echo "   http://localhost:3000"
    echo ""
    echo "   To stop the server: kill \$(lsof -t -i:3000)"
    echo "   To restart: ./start_server.sh"
else
    print_warning "Server test failed. You may need to start manually with: ./start_server.sh"
fi

echo ""
print_success "Installation completed successfully! 🎉"
echo ""
echo "Next steps:"
echo "1. Visit http://localhost:3000 to see your application"
echo "2. Sign up with a Columbia email address"
echo "3. Start posting lost and found items"
echo "4. Run tests with ./run_tests.sh"
echo ""
echo "Happy coding! 🔍✨"
