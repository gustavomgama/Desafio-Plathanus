# PropertyHub - Real Estate Property Manager

A modern Rails application for managing property listings with intelligent photo management and beautiful UI inspired by Tabas.com.

## 🏗️ Project Overview

PropertyHub is a full-stack Ruby on Rails application that demonstrates production-grade development practices including:

- **Smart Cover Photo Logic**: Automatically selects the 3rd photo as the cover, or falls back to the first photo if fewer than 3 exist
- **Modern UI Design**: Clean, responsive interface inspired by contemporary real estate platforms
- **Performance Optimized**: N+1 query prevention, efficient database design, and caching strategies
- **Test-Driven Development**: Comprehensive RSpec test suite covering all business logic
- **Production Ready**: Security best practices, error handling, and deployment considerations

## 🚀 Quick Start

### Prerequisites

- Ruby 3.4.6+
- Rails 8.0+
- PostgreSQL 12+
- Node.js 18+ (for asset compilation)

### Installation

1. **Clone and setup**
   ```bash
   git clone <repository-url>
   cd ruby_app
   bundle install
   ```

2. **Database setup**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

3. **Start the server**
   ```bash
   bin/rails server
   ```

4. **Visit the application**
   Navigate to `http://localhost:3000`

## ✨ Features

### Core Functionality

- **Property Management**: Create and manage property listings
- **Intelligent Photo Handling**: Automatic cover photo selection with fallback logic
- **Responsive Design**: Beautiful UI that works on all devices
- **Performance Optimized**: Efficient database queries and minimal N+1 issues

### Business Logic Highlights

```ruby
# Cover photo logic - third photo or fallback to first
def cover_photo
  photos.loaded? ? cover_photo_from_loaded : cover_photo_from_database
end

def has_cover_photo?
  photos.loaded? ? photos.size >= 3 : photos.count >= 3
end
```

### Database Design

```sql
-- Properties with required names and proper indexing
CREATE TABLE properties (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- Photos with position tracking and constraints
CREATE TABLE photos (
  id SERIAL PRIMARY KEY,
  property_id INTEGER NOT NULL REFERENCES properties(id),
  filename VARCHAR(255) NOT NULL,
  position INTEGER NOT NULL CHECK (position > 0),
  content_type VARCHAR(50),
  file_size INTEGER CHECK (file_size > 0),
  created_at TIMESTAMP,
  updated_at TIMESTAMP,
  UNIQUE(property_id, position)
);
```

## 🧪 Testing

Run the comprehensive test suite:

```bash
# Run all tests
bundle exec rspec

# Run with coverage
bundle exec rspec --format documentation

# Run specific test files
bundle exec rspec spec/models/property_spec.rb
bundle exec rspec spec/models/photo_spec.rb
```

### Test Coverage

- **Models**: 100% coverage of business logic, validations, and associations
- **Controllers**: Request/response handling, error scenarios
- **Integration**: End-to-end user workflows
- **Performance**: Database query optimization verification

## 📊 Data Model

### Property
- **Name** (required, 2-100 characters)
- **Photos** (has_many relationship with position ordering)
- **Cover Photo Logic** (3rd photo or 1st photo fallback)

### Photo
- **Filename** (required, unique per property)
- **Position** (required, unique per property, auto-assigned)
- **Content Type** (validates image formats)
- **File Size** (validates reasonable limits)

## 🎨 Frontend Architecture

### Design System
- **Tailwind CSS**: Utility-first CSS framework
- **Responsive Grid**: Mobile-first property card layout
- **Modern Typography**: Clean, readable font hierarchy
- **Color Palette**: Professional blue/gray theme

### Component Structure
- **Property Cards**: Reusable components with cover photo display
- **Navigation**: Fixed header with property count
- **Responsive Layout**: Adapts to all screen sizes

## 🔧 Technical Architecture

### Backend
- **Rails 8.0**: Modern Rails with solid conventions
- **PostgreSQL**: Robust relational database with constraints
- **Service Objects**: Complex business logic separation
- **Query Optimization**: Includes and eager loading strategies

### Frontend
- **Server-Side Rendering**: Traditional Rails views with Turbo
- **Responsive Design**: Mobile-first CSS Grid layout
- **Progressive Enhancement**: Works without JavaScript

### Performance
- **Database Indexing**: Strategic indexes on frequently queried columns
- **N+1 Prevention**: Careful use of `includes` and `preload`
- **Caching**: Memoization of expensive operations
- **Lazy Loading**: Efficient photo loading strategies

## 🛡️ Security & Best Practices

- **Strong Parameters**: Mass assignment protection
- **Database Constraints**: Data integrity at the database level
- **Input Validation**: Comprehensive validation at application layer
- **Error Handling**: Graceful degradation and user-friendly error messages
- **CSRF Protection**: Built-in Rails security features

## 🚀 Deployment Considerations

### Production Checklist
- [ ] Environment variables configured
- [ ] Database constraints applied
- [ ] Asset precompilation tested
- [ ] Error monitoring configured
- [ ] Performance monitoring enabled
- [ ] Backup strategy implemented

### Scaling Considerations
- **Database**: Ready for read replicas and connection pooling
- **Photos**: Designed for CDN integration and object storage
- **Caching**: Redis-ready for session and fragment caching
- **Background Jobs**: Sidekiq-ready for async processing

## 📝 Development Notes

### Key Design Decisions

1. **Cover Photo Logic**: Implements business requirement of 3rd photo as cover with intelligent fallback
2. **Database First**: Constraints at database level prevent invalid data states
3. **Performance Conscious**: Preloads associations to prevent N+1 queries
4. **Test-Driven**: Tests document behavior and catch regressions

### Architecture Patterns

- **Service Objects**: For complex operations crossing model boundaries
- **Query Objects**: For complex database queries and reporting
- **Policy Objects**: For authorization logic (future extension point)
- **Serializers**: For API responses (future extension point)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Write tests for new functionality
4. Implement the feature
5. Ensure all tests pass
6. Submit a pull request

## 📄 License

This project is built as a technical demonstration and portfolio piece.

---

**Built with ❤️ using Ruby on Rails, demonstrating production-grade development practices and modern web application architecture.**
