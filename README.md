# FoundIt - Columbia's Lost & Found Platform

🔍 **Lost something? We'll find it.** FoundIt is Columbia University's trusted lost & found platform that connects students who have lost items with those who have found them through smart matching and secure verification.

## Features

- **Smart Matching Algorithm**: Automatically finds potential matches based on item type, location, date, and description
- **Secure Verification**: Question-based authentication prevents false claims and protects privacy
- **Columbia Integration**: .edu email validation and campus-specific locations
- **Reputation System**: Build your reputation as a trustworthy community member
- **Mobile-Friendly**: Responsive design for on-the-go usage
- **Real-time Notifications**: Instant alerts when potential matches are found

## Prerequisites

- Ruby 3.3.4
- Rails 8.0.3
- SQLite3
- Node.js (for asset compilation)

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd FoundIt
   ```

2. **Install Ruby dependencies**
   ```bash
   bundle install
   ```

3. **Set up the database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Start the Rails server**
   ```bash
   rails server
   ```

5. **Visit the application**
   Open your browser and go to `http://localhost:3000`

## Usage

### Getting Started

1. **Sign Up**: Create an account with your Columbia email address
2. **Post Lost Item**: Report a lost item with detailed description and verification questions
3. **Post Found Item**: Report a found item with photos and location details
4. **View Matches**: Check your dashboard for potential matches
5. **Verify Ownership**: Answer verification questions to prove ownership
6. **Coordinate Return**: Arrange safe meetup locations for item returns

### User Registration

- **Email**: Must be a valid Columbia .edu email address
- **UNI**: University Network ID (format: abc1234)
- **Password**: Secure password with confirmation

### Item Types Supported

- Phone
- Laptop
- Textbook
- ID
- Keys
- Wallet
- Backpack
- Other

### Campus Locations

The platform recognizes Columbia-specific locations such as:
- Butler Library
- Lerner Hall
- Hamilton Hall
- John Jay Hall
- And many more...

## Testing

### Running RSpec Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/models/lost_item_spec.rb
bundle exec rspec spec/jobs/find_matches_job_spec.rb

# Run with detailed output
bundle exec rspec --format documentation

# Run tests with coverage
bundle exec rspec --format progress
```

### Running Cucumber Tests

```bash
# Run all Cucumber features
bundle exec cucumber

# Run specific feature files
bundle exec cucumber features/user_registration.feature
bundle exec cucumber features/lost_item_management.feature
bundle exec cucumber features/smart_matching.feature

# Run with dry-run to see scenarios
bundle exec cucumber --dry-run

# Run with detailed output
bundle exec cucumber --format pretty
```

### Test Coverage

The application includes comprehensive test coverage:

- **Model Tests**: Validations, associations, scopes, and business logic
- **Controller Tests**: Request handling and authentication
- **Job Tests**: Background job processing and algorithms
- **Integration Tests**: End-to-end user workflows
- **Feature Tests**: Complete user scenarios with Cucumber

### Test Data

Tests use FactoryBot for realistic test data generation:
- Unique Columbia email addresses
- Valid UNI formats
- Realistic item descriptions
- Campus-specific locations

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

### Database Schema

The application uses SQLite3 with the following main tables:
- `users` - Student accounts and profiles
- `lost_items` - Lost item reports
- `found_items` - Found item reports  
- `matches` - Algorithm-generated matches

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

## Performance Features

- **Smart Matching**: Efficient algorithm with similarity scoring
- **Background Jobs**: Asynchronous processing for better performance
- **Database Optimization**: Proper indexing and query optimization
- **Caching**: Strategic caching for improved response times

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation in `/docs`

## Acknowledgments

- Columbia University for providing the campus context
- Rails community for excellent framework and gems
- Open source contributors for various dependencies

---

**Built with ❤️ for the Columbia University community**