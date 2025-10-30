# Plathanus Technical Challenge

> **Multi-Exercise Programming Challenge**
> Solutions demonstrating production-grade development practices for mid-level developer evaluation.

## 📋 Challenge Overview

This repository contains solutions to a comprehensive programming challenge consisting of two main exercises:

1. **Algorithm Implementation** - Choose from Roman numeral conversion or number-to-words conversion
2. **Full-Stack Ruby Application** - Property management system with photo handling

---

## 🔢 Exercise 1: Algorithm

Please submit your solution to **at least one** of the 3 programming options below.

### Option 1: Roman Numeral Converter

Write a program to convert a natural number to its Roman number equivalent.

**Reference**: [Roman Numerals - Wikipedia](https://en.wikipedia.org/wiki/Roman_numerals)

**Rules**: Follow the standard rules for constructing Roman numbers using Roman numerals.

**Examples**:
- `1` → `"I"`
- `4` → `"IV"`
- `9` → `"IX"`
- `27` → `"XXVII"`
- `1994` → `"MCMXCIV"`

### Option 2: Number to Words Converter

Write a program that expects an integer as input and outputs the integer in word form.

**Examples**:
- `0` = "zero"
- `1` = "one"
- `21` = "twenty one"
- `105` = "one hundred and five"
- `1317` = "one thousand, three hundred and seventeen"

**Requirements**:
- Handle numbers from 0 to at least 999,999
- Use proper English number formatting
- Include "and" where grammatically appropriate

---

## 🏠 Exercise 2: Ruby Application

Create a Ruby application for property management with photo handling.

### Backend Requirements

- **Property Model**:
  - Required `name` field
  - `has_many :photos` relationship
- **Photo Logic**:
  - Third photo automatically becomes the property cover
  - Photos stored locally
- **Database Seeding**:
  - 50 properties
  - 3-5 photos per property

### Frontend Requirements

- **Property Listings**: Display all properties with their cover photos
- **Layout Style**: Similar to [www.tabas.com](https://www.tabas.com) layout style
- **Responsive Design**: Mobile-friendly interface
- **Photo Display**: Intelligent cover photo selection and fallback

---

## 🎯 What We Are Looking For

### 1. **Craftsmanship & Attention to Detail**
Write code as though you were building a production system that will be maintained by a team.

### 2. **Language Idiom & Advanced Features**
Demonstrate understanding of Ruby/language-specific patterns and advanced features where appropriate.

### 3. **Design Appreciation**
- Clear separation of concerns
- Understanding of abstraction, cohesion, and coupling
- Proper architectural decisions

### 4. **Object-Oriented Programming**
Use OOP principles effectively where they add value to the solution.

### 5. **Maintainable Code**
- Code that communicates intent clearly
- Absence of duplication (DRY principle)
- Easy to understand and modify

### 6. **Correct Solution**
The implementation must solve the problem requirements completely and correctly.

### 7. **Comprehensive Testing**
Include a complete test suite that validates:
- Business logic
- Edge cases
- Error scenarios
- Integration points

### 8. **Professional Version Control**
- Meaningful commit messages
- Logical commit history
- Clear development progression

### 9. **Thoughtful Dependencies**
- Reasonable use of external libraries
- No libraries that provide the core solution
- Justified dependency choices

---

## 📁 Repository Structure

```
├── README.md                    # This file
├── number_to_words/            # Exercise 1: Number to words converter
│   ├── number_to_words.rb
│   └── README.md
├── roman_numerals/             # Exercise 1: Roman numeral converter
│   ├── roman_converter.rb
│   └── README.md
└── ruby_app/                   # Exercise 2: Property management app
    ├── app/
    ├── config/
    ├── db/
    ├── spec/
    └── README.md
```

---

## 🚀 Getting Started

### Prerequisites

- Ruby 3.3.0+
- Rails 8.0+ (for Exercise 2)
- PostgreSQL (for Exercise 2)
- Git

### Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd desafio_plathanus
   ```

2. **Choose your exercise**

   **For Algorithm Exercises**:
   ```bash
   cd number_to_words/     # or cd roman_numerals/
   ruby number_to_words.rb # or ruby roman_converter.rb
   ```

   **For Ruby Application**:
   ```bash
   cd ruby_app/
   bundle install
   rails db:setup
   rails server
   ```

3. **Run tests**
   ```bash
   # In each exercise directory
   bundle exec rspec      # or appropriate test command
   ```
