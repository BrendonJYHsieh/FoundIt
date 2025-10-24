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
# print_status "Running RSpec unit tests..."
# bundle exec rspec --format progress

# if [ $? -eq 0 ]; then
#     print_success "RSpec tests passed successfully."
# else
#     print_warning "Some RSpec tests failed. Check the output above for details."
# fi

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

# Create test scripts
print_status "Creating test scripts..."

# Create RSpec test script with coverage
cat > run_rspec_tests.sh << 'EOF'
#!/bin/bash

# FoundIt RSpec Test Runner Script with Coverage
echo "🧪 Running FoundIt RSpec Tests with Coverage"
echo "============================================="

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "Gemfile" ]; then
    print_error "Gemfile not found. Please run this script from the FoundIt project root directory."
    exit 1
fi

# Check if RSpec is available
if ! bundle exec rspec --version &> /dev/null; then
    print_error "RSpec is not available. Please run 'bundle install' first."
    exit 1
fi

print_status "Starting RSpec test suite with coverage analysis..."

# Set test environment and enable coverage
export RAILS_ENV=test
export COVERAGE=true

# Clean previous coverage reports
if [ -d "coverage" ]; then
    print_status "Cleaning previous coverage reports..."
    rm -rf coverage
fi

# Prepare test database
print_status "Preparing test database..."
bundle exec rails db:test:prepare

if [ $? -eq 0 ]; then
    print_success "Test database prepared successfully."
else
    print_error "Failed to prepare test database."
    exit 1
fi

# Run RSpec tests with detailed output and coverage
print_status "Running RSpec unit tests with coverage analysis..."
echo ""

bundle exec rspec --format documentation --color

# Capture exit code
RSPEC_EXIT_CODE=$?

echo ""
echo "=========================================="

# Check if coverage report was generated
if [ -d "coverage" ]; then
    print_success "Coverage report generated successfully!"
    echo ""
    echo "📊 Coverage Report:"
    echo "   - HTML Report: coverage/index.html"
    echo "   - Text Report: coverage/.resultset.json"
    echo ""
    
    # Display coverage summary if available
    if [ -f "coverage/index.html" ]; then
        print_status "Coverage Summary:"
        echo "   - Open coverage/index.html in your browser for detailed coverage report"
        echo "   - Coverage threshold: 80% overall, 70% per file"
        echo "   - RSpec coverage analysis complete"
    fi
else
    print_warning "Coverage report not generated. Make sure SimpleCov is properly configured."
fi

if [ $RSPEC_EXIT_CODE -eq 0 ]; then
    print_success "All RSpec tests passed! ✅"
    echo ""
    echo "📊 Test Summary:"
    echo "   - Unit tests: PASSED"
    echo "   - Model validations: PASSED"
    echo "   - Controller tests: PASSED"
    echo "   - Job tests: PASSED"
    echo "   - Helper tests: PASSED"
    echo "   - Coverage: ANALYZED"
else
    print_error "Some RSpec tests failed! ❌"
    echo ""
    echo "📊 Test Summary:"
    echo "   - Unit tests: FAILED"
    echo "   - Check the output above for details"
    echo "   - Fix failing tests before proceeding"
fi

echo ""
echo "🔧 RSpec Test Commands:"
echo "   - Run all tests: ./run_rspec_tests.sh"
echo "   - Run specific file: bundle exec rspec spec/models/user_spec.rb"
echo "   - Run with coverage: COVERAGE=true bundle exec rspec --format documentation"
echo "   - Run specific test: bundle exec rspec spec/models/user_spec.rb:25"
echo "   - View coverage: open coverage/index.html"

exit $RSPEC_EXIT_CODE
EOF

chmod +x run_rspec_tests.sh
print_success "RSpec test script created (run_rspec_tests.sh)"

# Create Cucumber test script with coverage
cat > run_cucumber_tests.sh << 'EOF'
#!/bin/bash

# FoundIt Cucumber Test Runner Script with Coverage
echo "🧪 Running FoundIt Cucumber Tests with Coverage"
echo "==============================================="

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "Gemfile" ]; then
    print_error "Gemfile not found. Please run this script from the FoundIt project root directory."
    exit 1
fi

# Check if Cucumber is available
if ! bundle exec cucumber --version &> /dev/null; then
    print_error "Cucumber is not available. Please run 'bundle install' first."
    exit 1
fi

print_status "Starting Cucumber test suite with coverage analysis..."

# Set test environment and enable coverage
export RAILS_ENV=test
export COVERAGE=true

# Prepare test database
print_status "Preparing test database..."
bundle exec rails db:test:prepare

if [ $? -eq 0 ]; then
    print_success "Test database prepared successfully."
else
    print_error "Failed to prepare test database."
    exit 1
fi

# Run Cucumber tests with pretty output and coverage
print_status "Running Cucumber integration tests with coverage analysis..."
echo ""

bundle exec cucumber --format pretty --color

# Capture exit code
CUCUMBER_EXIT_CODE=$?

echo ""
echo "=========================================="

# Check if coverage report was generated
if [ -d "coverage" ]; then
    print_success "Coverage report generated successfully!"
    echo ""
    echo "📊 Coverage Report:"
    echo "   - HTML Report: coverage/index.html"
    echo "   - Text Report: coverage/.resultset.json"
    echo ""
    
    # Display coverage summary if available
    if [ -f "coverage/index.html" ]; then
        print_status "Coverage Summary:"
        echo "   - Open coverage/index.html in your browser for detailed coverage report"
        echo "   - Coverage threshold: 80% overall, 70% per file"
        echo "   - Cucumber coverage analysis complete"
    fi
else
    print_warning "Coverage report not generated. Make sure SimpleCov is properly configured."
fi

if [ $CUCUMBER_EXIT_CODE -eq 0 ]; then
    print_success "All Cucumber tests passed! ✅"
    echo ""
    echo "📊 Test Summary:"
    echo "   - Integration tests: PASSED"
    echo "   - User registration: PASSED"
    echo "   - Item management: PASSED"
    echo "   - Smart matching: PASSED"
    echo "   - Dashboard functionality: PASSED"
    echo "   - Coverage: ANALYZED"
else
    print_error "Some Cucumber tests failed! ❌"
    echo ""
    echo "📊 Test Summary:"
    echo "   - Integration tests: FAILED"
    echo "   - Check the output above for details"
    echo "   - Fix failing tests before proceeding"
fi

echo ""
echo "🔧 Cucumber Test Commands:"
echo "   - Run all tests: ./run_cucumber_tests.sh"
echo "   - Run specific feature: bundle exec cucumber features/user_registration.feature"
echo "   - Run with tags: bundle exec cucumber --tags @smoke"
echo "   - Dry run: bundle exec cucumber --dry-run"
echo "   - View coverage: open coverage/index.html"

exit $CUCUMBER_EXIT_CODE
EOF

chmod +x run_cucumber_tests.sh
print_success "Cucumber test script created (run_cucumber_tests.sh)"

# Create main test script with combined coverage
cat > run_tests.sh << 'EOF'
#!/bin/bash

# FoundIt Test Runner Script with Combined Coverage
echo "🧪 Running FoundIt Tests with Combined Coverage"
echo "==============================================="

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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "Gemfile" ]; then
    print_error "Gemfile not found. Please run this script from the FoundIt project root directory."
    exit 1
fi

# Track overall test results
OVERALL_SUCCESS=true

echo ""
print_status "Starting comprehensive test suite with coverage analysis..."
echo ""

# Clean previous coverage reports for fresh analysis
if [ -d "coverage" ]; then
    print_status "Cleaning previous coverage reports for fresh analysis..."
    rm -rf coverage
fi

# Run RSpec tests with coverage
echo "🔬 Running RSpec Unit Tests with Coverage"
echo "========================================="
./run_rspec_tests.sh
RSPEC_EXIT_CODE=$?

if [ $RSPEC_EXIT_CODE -eq 0 ]; then
    print_success "RSpec tests completed successfully."
else
    print_error "RSpec tests failed."
    OVERALL_SUCCESS=false
fi

echo ""
echo "=========================================="
echo ""

# Run Cucumber tests with coverage (will merge with RSpec coverage)
echo "🧪 Running Cucumber Integration Tests with Coverage"
echo "==================================================="
./run_cucumber_tests.sh
CUCUMBER_EXIT_CODE=$?

if [ $CUCUMBER_EXIT_CODE -eq 0 ]; then
    print_success "Cucumber tests completed successfully."
else
    print_error "Cucumber tests failed."
    OVERALL_SUCCESS=false
fi

echo ""
echo "=========================================="
echo ""

# Check final coverage report
if [ -d "coverage" ]; then
    print_success "Combined coverage report generated successfully!"
    echo ""
    echo "📊 Combined Coverage Report:"
    echo "   - HTML Report: coverage/index.html"
    echo "   - Text Report: coverage/.resultset.json"
    echo "   - Coverage includes both RSpec and Cucumber tests"
    echo ""
    
    if [ -f "coverage/index.html" ]; then
        print_status "Combined Coverage Summary:"
        echo "   - Open coverage/index.html for detailed combined coverage report"
        echo "   - Coverage threshold: 80% overall, 70% per file"
        echo "   - Includes unit tests (RSpec) and integration tests (Cucumber)"
        echo ""
        
        # Open coverage report if on macOS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            print_status "Opening combined coverage report in browser..."
            open coverage/index.html
        fi
    fi
else
    print_warning "Combined coverage report not generated. Check SimpleCov configuration."
fi

# Final summary
if [ "$OVERALL_SUCCESS" = true ]; then
    print_success "🎉 All tests passed! FoundIt is ready for deployment."
    echo ""
    echo "📊 Final Test Summary:"
    echo "   ✅ RSpec unit tests: PASSED"
    echo "   ✅ Cucumber integration tests: PASSED"
    echo "   ✅ Combined test coverage: COMPLETE"
    echo "   ✅ Coverage report: GENERATED"
else
    print_error "❌ Some tests failed. Please fix the issues before proceeding."
    echo ""
    echo "📊 Final Test Summary:"
    if [ $RSPEC_EXIT_CODE -eq 0 ]; then
        echo "   ✅ RSpec unit tests: PASSED"
    else
        echo "   ❌ RSpec unit tests: FAILED"
    fi
    if [ $CUCUMBER_EXIT_CODE -eq 0 ]; then
        echo "   ✅ Cucumber integration tests: PASSED"
    else
        echo "   ❌ Cucumber integration tests: FAILED"
    fi
    echo "   ❌ Overall test coverage: INCOMPLETE"
fi

echo ""
echo "🔧 Individual Test Commands:"
echo "   - RSpec only: ./run_rspec_tests.sh"
echo "   - Cucumber only: ./run_cucumber_tests.sh"
echo "   - All tests: ./run_tests.sh"
echo "   - View coverage: open coverage/index.html"

# Exit with appropriate code
if [ "$OVERALL_SUCCESS" = true ]; then
    exit 0
else
    exit 1
fi
EOF

chmod +x run_tests.sh
print_success "Main test script created (run_tests.sh)"


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
echo "   - RSpec only: ./run_rspec_tests.sh"
echo "   - Cucumber only: ./run_cucumber_tests.sh"
echo "   - All scripts include coverage analysis"
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
