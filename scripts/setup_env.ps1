# IMR Environment Setup Script
# This script helps you set up environment variables for the IMR project

param(
    [string]$SupabaseUrl = "",
    [string]$SupabaseAnonKey = "",
    [string]$SupabaseServiceKey = ""
)

Write-Host "🚀 IMR Environment Setup Script" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Check if parameters were provided
if ([string]::IsNullOrEmpty($SupabaseUrl) -or [string]::IsNullOrEmpty($SupabaseAnonKey)) {
    Write-Host "❌ Please provide Supabase URL and Anon Key as parameters" -ForegroundColor Red
    Write-Host "Usage: .\setup_env.ps1 -SupabaseUrl 'https://your-project.supabase.co' -SupabaseAnonKey 'your-anon-key'" -ForegroundColor Yellow
    exit 1
}

# Validate Supabase URL
if (-not $SupabaseUrl.StartsWith("https://")) {
    Write-Host "❌ Supabase URL must start with 'https://'" -ForegroundColor Red
    exit 1
}

# Validate Anon Key (should start with 'eyJ')
if (-not $SupabaseAnonKey.StartsWith("eyJ")) {
    Write-Host "❌ Supabase Anon Key should start with 'eyJ'" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Validating environment variables..." -ForegroundColor Green

# Create .env file
$envContent = @"
# IMR Environment Configuration
# Generated on $(Get-Date)

# Supabase Configuration
SUPABASE_URL=$SupabaseUrl
SUPABASE_ANON_KEY=$SupabaseAnonKey
"@

if (-not [string]::IsNullOrEmpty($SupabaseServiceKey)) {
    $envContent += "`nSUPABASE_SERVICE_KEY=$SupabaseServiceKey"
}

# Write to .env file
$envContent | Out-File -FilePath ".env" -Encoding UTF8

Write-Host "✅ Environment file created: .env" -ForegroundColor Green

# Create .env.example if it doesn't exist
if (-not (Test-Path ".env.example")) {
    $exampleContent = @"
# IMR Environment Configuration
# Copy this file to .env and fill in your actual values

# Supabase Configuration
SUPABASE_URL=https://your-project-ref.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
SUPABASE_SERVICE_KEY=your-service-key-here

# App Configuration
APP_NAME=I Manage Risk
APP_VERSION=1.0.0
ENVIRONMENT=development
"@
    
    $exampleContent | Out-File -FilePath ".env.example" -Encoding UTF8
    Write-Host "✅ Example environment file created: .env.example" -ForegroundColor Green
}

# Check if .gitignore contains .env
$gitignoreContent = Get-Content ".gitignore" -ErrorAction SilentlyContinue
if ($gitignoreContent -notcontains ".env") {
    Add-Content ".gitignore" "`n# Environment variables`n.env"
    Write-Host "✅ Added .env to .gitignore" -ForegroundColor Green
}

Write-Host "`n🎯 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Verify your Supabase project is set up correctly" -ForegroundColor White
Write-Host "2. Run 'flutter pub get' to install dependencies" -ForegroundColor White
Write-Host "3. Test the connection with 'flutter run'" -ForegroundColor White
Write-Host "4. Check the console for any error messages" -ForegroundColor White

Write-Host "`n📝 Environment Variables Summary:" -ForegroundColor Cyan
Write-Host "SUPABASE_URL: $SupabaseUrl" -ForegroundColor White
Write-Host "SUPABASE_ANON_KEY: $($SupabaseAnonKey.Substring(0, 10))..." -ForegroundColor White
if (-not [string]::IsNullOrEmpty($SupabaseServiceKey)) {
    Write-Host "SUPABASE_SERVICE_KEY: $($SupabaseServiceKey.Substring(0, 10))..." -ForegroundColor White
}

Write-Host "`n✅ Environment setup completed successfully!" -ForegroundColor Green
