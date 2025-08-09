# I Manage Risk (IMR)

A comprehensive insurance management system built with Flutter and Supabase.

## 🚀 Quick Start

### Prerequisites

- Flutter SDK (^3.8.1)
- Dart SDK
- Supabase project (already created)
- Git

### Environment Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd imanagerisk
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Supabase keys**

   You have several options to configure your Supabase keys:

   #### Option A: Using PowerShell Script (Recommended)
   ```powershell
   .\scripts\setup_env.ps1 -SupabaseUrl "https://your-project.supabase.co" -SupabaseAnonKey "your-anon-key"
   ```

   #### Option B: Manual Configuration
   - Copy `.env.example` to `.env`
   - Fill in your Supabase credentials:
     ```env
     SUPABASE_URL=https://your-project-ref.supabase.co
     SUPABASE_ANON_KEY=your-anon-key-here
     SUPABASE_SERVICE_KEY=your-service-key-here
     ```

   #### Option C: Using --dart-define
   ```bash
   flutter run --dart-define=SUPABASE_URL=https://your-project.supabase.co \
               --dart-define=SUPABASE_ANON_KEY=your-anon-key
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── core/
│   ├── env/           # Environment configuration
│   └── services/      # Core services (Supabase, etc.)
├── shared/
│   └── constants/     # App constants
└── main.dart          # App entry point
```

## 🔧 Configuration

### Environment Variables

The application uses the following environment variables:

- `SUPABASE_URL`: Your Supabase project URL
- `SUPABASE_ANON_KEY`: Your Supabase anonymous key
- `SUPABASE_SERVICE_KEY`: Your Supabase service key (optional for client)

### Supabase Setup

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Select your project
3. Go to **Settings** > **API**
4. Copy the Project URL and anon/public key

## 🗄️ Database Schema

The complete database schema is defined in `supabase/schema.sql`. This includes:

- 20 tables for all business entities
- Row Level Security (RLS) policies
- Proper indexes and constraints
- Sample data

## 🎨 Design System

The application uses a modern Material 3 design with:
- Glassmorphism effects
- Brand colors (Orange, Grey, Deep Grey)
- Responsive design
- Accessibility support

## 🔐 Security

- Row Level Security (RLS) enabled on all tables
- Role-based access control (RBAC)
- Secure environment variable management
- Input validation and sanitization

## 📚 Documentation

- [Environment Setup Guide](ENVIRONMENT_SETUP.md)
- [Database Schema](docs/DATA_SCHEMA.md)
- [Project Requirements](docs/PRD.md)
- [Development Rules](docs/DEV_RULES.md)
- [Implementation Checklist](docs/CHECKLIST.md)

## 🚧 Development Status

### ✅ Completed
- Supabase project setup
- Database schema implementation
- Environment configuration
- Basic app structure
- Authentication service

### 🚧 In Progress
- Design system implementation
- Core components
- Feature modules

### 📋 Next Steps
1. Implement design system and theming
2. Build core components and navigation
3. Develop feature modules (Sales, Admin, Claims, etc.)
4. Add comprehensive testing
5. Deploy to production

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is proprietary software for I Manage Risk.

## 🆘 Support

For support and questions:
1. Check the [documentation](docs/)
2. Review the [environment setup guide](ENVIRONMENT_SETUP.md)
3. Check the [Supabase documentation](https://supabase.com/docs)
