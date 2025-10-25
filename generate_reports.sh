#!/bin/bash

# FoundIt Test Report Generator
# Generates comprehensive test reports including Cucumber, RSpec, and Coverage reports

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPORTS_DIR="reports"
COVERAGE_DIR="coverage"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Function to print colored output
print_status() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

print_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

print_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

print_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to create directories
create_directories() {
    print_status "Creating report directories..."
    mkdir -p "$REPORTS_DIR"
    mkdir -p "$COVERAGE_DIR"
    print_success "Directories created"
}

# Function to clean old reports
clean_reports() {
    print_status "Cleaning old reports..."
    rm -rf "$REPORTS_DIR"/*
    rm -rf "$COVERAGE_DIR"/*
    print_success "Old reports cleaned"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command_exists bundle; then
        print_error "Bundler not found. Please install bundler first."
        exit 1
    fi
    
    if ! command_exists rails; then
        print_error "Rails not found. Please ensure Rails is installed."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to run database setup
setup_database() {
    print_status "Setting up test database..."
    bundle exec rails db:test:prepare
    print_success "Test database ready"
}

# Function to generate RSpec reports
generate_rspec_reports() {
    print_status "Generating RSpec reports..."
    
    # Run RSpec with different formats
    bundle exec rspec \
        --format documentation \
        --format html --out "$REPORTS_DIR/rspec_report.html" \
        --format json --out "$REPORTS_DIR/rspec_report.json" \
        --format progress
    
    print_success "RSpec reports generated"
}

# Function to generate Cucumber reports
generate_cucumber_reports() {
    print_status "Generating Cucumber reports..."
    
    # Run Cucumber with different formats
    bundle exec cucumber \
        --format html --out "$REPORTS_DIR/cucumber_report.html" \
        --format json --out "$REPORTS_DIR/cucumber_report.json" \
        --format progress
    
    print_success "Cucumber reports generated"
}

# Function to generate combined coverage report
generate_coverage_report() {
    print_status "Generating coverage report..."
    
    # Clear old coverage
    rm -rf "$COVERAGE_DIR"/*
    
    # Run tests with coverage
    COVERAGE=true bundle exec rspec --format progress
    COVERAGE=true bundle exec cucumber --format progress
    
    print_success "Coverage report generated"
}

# Function to generate summary report
generate_summary_report() {
    print_status "Generating summary report..."
    
    local summary_file="$REPORTS_DIR/test_summary_$TIMESTAMP.txt"
    
    cat > "$summary_file" << EOF
# FoundIt Test Report Summary
Generated: $(date)
Timestamp: $TIMESTAMP

## Test Results Summary

### RSpec Results
$(if [ -f "$REPORTS_DIR/rspec_report.json" ]; then
    echo "RSpec tests completed"
else
    echo "RSpec tests not run"
fi)

### Cucumber Results
$(if [ -f "$REPORTS_DIR/cucumber_report.json" ]; then
    echo "Cucumber tests completed"
else
    echo "Cucumber tests not run"
fi)

### Coverage Results
$(if [ -f "$COVERAGE_DIR/index.html" ]; then
    echo "Coverage report available at: $COVERAGE_DIR/index.html"
else
    echo "Coverage report not generated"
fi)

## Report Files Generated

### HTML Reports
- RSpec: $REPORTS_DIR/rspec_report.html
- Cucumber: $REPORTS_DIR/cucumber_report.html
- Coverage: $COVERAGE_DIR/index.html

### JSON Reports
- RSpec: $REPORTS_DIR/rspec_report.json
- Cucumber: $REPORTS_DIR/cucumber_report.json

## Quick Access Commands
- Open HTML coverage report: open $COVERAGE_DIR/index.html
- Open RSpec HTML report: open $REPORTS_DIR/rspec_report.html
- Open Cucumber HTML report: open $REPORTS_DIR/cucumber_report.html

EOF

    print_success "Summary report generated: $summary_file"
}

# Function to open reports
open_reports() {
    print_status "Opening reports in browser..."
    
    if command_exists open; then
        if [ -f "$COVERAGE_DIR/index.html" ]; then
            open "$COVERAGE_DIR/index.html"
        fi
        if [ -f "$REPORTS_DIR/rspec_report.html" ]; then
            open "$REPORTS_DIR/rspec_report.html"
        fi
        if [ -f "$REPORTS_DIR/cucumber_report.html" ]; then
            open "$REPORTS_DIR/cucumber_report.html"
        fi
        print_success "Reports opened in browser"
    else
        print_warning "Cannot open browser automatically. Please open reports manually."
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

OPTIONS:
    -h, --help          Show this help message
    -c, --clean         Clean old reports before generating new ones
    -r, --rspec-only    Generate only RSpec reports
    -u, --cucumber-only Generate only Cucumber reports
    -o, --coverage-only Generate only coverage report
    -a, --all           Generate all reports (default)
    -s, --skip-open     Skip opening reports in browser
    --no-clean          Don't clean old reports

EXAMPLES:
    $0                  # Generate all reports
    $0 -c               # Clean and generate all reports
    $0 -r               # Generate only RSpec reports
    $0 -u               # Generate only Cucumber reports
    $0 -o               # Generate only coverage report
    $0 -a -s            # Generate all reports but don't open browser

EOF
}

# Main function
main() {
    local clean_reports=false
    local rspec_only=false
    local cucumber_only=false
    local coverage_only=false
    local generate_all=true
    local skip_open=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -c|--clean)
                clean_reports=true
                shift
                ;;
            -r|--rspec-only)
                rspec_only=true
                generate_all=false
                shift
                ;;
            -u|--cucumber-only)
                cucumber_only=true
                generate_all=false
                shift
                ;;
            -o|--coverage-only)
                coverage_only=true
                generate_all=false
                shift
                ;;
            -a|--all)
                generate_all=true
                shift
                ;;
            -s|--skip-open)
                skip_open=true
                shift
                ;;
            --no-clean)
                clean_reports=false
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Start report generation
    printf "${BLUE}🔍 FoundIt Test Report Generator${NC}\n"
    echo "=============================================="
    
    # Check prerequisites
    check_prerequisites
    
    # Create directories
    create_directories
    
    # Clean reports if requested
    if [ "$clean_reports" = true ]; then
        clean_reports
    fi
    
    # Setup database
    setup_database
    
    # Generate reports based on options
    if [ "$generate_all" = true ]; then
        generate_rspec_reports
        generate_cucumber_reports
        generate_coverage_report
    elif [ "$rspec_only" = true ]; then
        generate_rspec_reports
    elif [ "$cucumber_only" = true ]; then
        generate_cucumber_reports
    elif [ "$coverage_only" = true ]; then
        generate_coverage_report
    fi
    
    # Generate summary
    generate_summary_report
    
    # Open reports unless skipped
    if [ "$skip_open" = false ]; then
        open_reports
    fi
    
    # Final success message
    echo ""
    printf "${GREEN}✅ Report generation completed successfully!${NC}\n"
    echo ""
    echo "📊 Reports available at:"
    echo "   - Coverage: $COVERAGE_DIR/index.html"
    echo "   - RSpec: $REPORTS_DIR/rspec_report.html"
    echo "   - Cucumber: $REPORTS_DIR/cucumber_report.html"
    echo ""
    echo "📋 Quick commands:"
    echo "   - View coverage: open $COVERAGE_DIR/index.html"
    echo "   - View RSpec: open $REPORTS_DIR/rspec_report.html"
    echo "   - View Cucumber: open $REPORTS_DIR/cucumber_report.html"
}

# Run main function with all arguments
main "$@"
