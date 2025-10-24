# FoundIt - Columbia's Lost & Found Platform

🔍 **Lost something? We'll find it.** Columbia University's trusted lost & found platform connecting students through smart matching and secure verification.

## Features

- **Smart Matching**: Automatic matching based on item type, location, date, and description
- **Secure Verification**: Question-based authentication prevents false claims
- **Columbia Integration**: .edu email validation and campus-specific locations
- **Reputation System**: Build trust within the community
- **Mobile-Friendly**: Responsive design for on-the-go usage

## Prerequisites

- Ruby 3.3.4
- Rails 8.0.3
- PostgreSQL 12+

## Quick Start

1. **Clone and setup**
   ```bash
   git clone <repository-url>
   cd FoundIt
   ```

2. **Run the installation script**
   ```bash
   ./install.sh
   ```

3. **Start server**
   ```bash
   ./start_server.sh
   ```

4. **Access application**
   Open `http://localhost:3000`

The installation script will automatically:
- Check system requirements
- Install PostgreSQL if needed
- Install Ruby dependencies
- Set up separate development and test databases
- Run migrations and seed data
- Create all test scripts (run_tests.sh, run_rspec_tests.sh, run_cucumber_tests.sh)
- Create server startup script (start_server.sh)
- Configure test coverage reporting

## Database Management

### Cleanup Database
If you need to reset your databases:
```bash
./cleanup_postgres.sh
```

This script provides options to:
- Drop and recreate databases (nuclear option)
- Drop databases only
- Recreate databases only
- Reset development database only

## Usage

### Getting Started
1. **Sign Up**: Create account with Columbia email
2. **Post Lost Item**: Report lost item with verification questions
3. **Post Found Item**: Report found item with photos
4. **View Matches**: Check dashboard for potential matches
5. **Verify Ownership**: Answer verification questions
6. **Coordinate Return**: Arrange safe meetup locations

### User Registration
- **Email**: Must be valid Columbia .edu email
- **UNI**: University Network ID (format: abc1234)
- **Password**: Secure password with confirmation

### Supported Item Types
Phone, Laptop, Textbook, ID, Keys, Wallet, Backpack, Other

### Campus Locations
Butler Library, Lerner Hall, Hamilton Hall, John Jay Hall, and more...

## Testing

FoundIt includes comprehensive test coverage with both unit tests (RSpec) and integration tests (Cucumber). The project provides separate scripts for running each test suite individually or together.

### Quick Test Commands

```bash
# Run all tests with combined coverage (RSpec + Cucumber)
./run_tests.sh

# Run only RSpec unit tests with coverage
./run_rspec_tests.sh

# Run only Cucumber integration tests with coverage
./run_cucumber_tests.sh
```

### RSpec Unit Tests
```bash
# Run all RSpec tests
./run_rspec_tests.sh

# Run specific test files
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/jobs/find_matches_job_spec.rb

# Run with detailed output
bundle exec rspec --format documentation

# Run specific test by line number
bundle exec rspec spec/models/user_spec.rb:25
```

### Cucumber Integration Tests
```bash
# Run all Cucumber tests
./run_cucumber_tests.sh

# Run specific features
bundle exec cucumber features/user_registration.feature
bundle exec cucumber features/smart_matching.feature

# Run with tags
bundle exec cucumber --tags @smoke

# Dry run (check syntax without executing)
bundle exec cucumber --dry-run
```

### Test Coverage

FoundIt uses SimpleCov for comprehensive test coverage analysis with the following features:

#### Coverage Analysis
```bash
# Run all tests with combined coverage
./run_tests.sh

# Run RSpec with coverage
./run_rspec_tests.sh

# Run Cucumber with coverage
./run_cucumber_tests.sh

# View coverage report
open coverage/index.html
```

- **Model Tests**: Validations, associations, business logic
- **Controller Tests**: Request handling and authentication
- **Job Tests**: Background processing and algorithms
- **Integration Tests**: End-to-end workflows

## Development

### Project Structure
```
app/
├── controllers/          # Application controllers
├── models/              # Data models and business logic
├── views/               # User interface templates
├── jobs/                # Background job processing
└── helpers/             # View helpers

spec/
├── models/              # Model unit tests
├── requests/            # Controller integration tests
├── jobs/                # Job processing tests
└── factories/           # Test data factories

features/                # Cucumber integration tests
├── step_definitions/    # Test step implementations
└── *.feature           # User story scenarios
```

### Key Models
- **User**: Columbia students with authentication and reputation
- **LostItem**: Items reported as lost with verification questions
- **FoundItem**: Items reported as found with photos
- **Match**: Algorithm-generated matches with similarity scores

### Background Jobs
- **FindMatchesJob**: Automatically finds potential matches when items are posted

## API Endpoints

### Authentication
- `POST /signup` - User registration
- `POST /login` - User login
- `DELETE /logout` - User logout

### Items
- `GET /lost_items` - List user's lost items
- `POST /lost_items` - Create lost item
- `GET /found_items` - List user's found items
- `POST /found_items` - Create found item

### Matches
- `GET /matches` - List user's matches
- `PATCH /matches/:id/verify` - Verify match ownership

### Dashboard
- `GET /dashboard` - User dashboard with statistics

## Security Features

- **Email Validation**: Only Columbia .edu emails accepted
- **UNI Validation**: Proper University Network ID format required
- **Password Security**: Bcrypt hashing for password storage
- **Session Management**: Secure session handling
- **Privacy Protection**: Contact info only shared after verification
- **Verification System**: Question-based ownership verification

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License.

---

**Built with ❤️ for the Columbia University community**