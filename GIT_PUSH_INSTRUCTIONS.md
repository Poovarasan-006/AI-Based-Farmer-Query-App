# Git Push Instructions for AI-Based Farmer Query App

## Prerequisites

1. **Git installed** on your system
2. **GitHub account** with access to the repository
3. **SSH key configured** or HTTPS access to the repository
4. **Flutter project** ready in your local directory

## Step-by-Step Instructions

### 1. Initialize Git Repository (if not already initialized)

```bash
# Navigate to your project directory
cd AI-Based-Farmer-Query-App

# Initialize git repository (if not already done)
git init

# Check if git is already initialized
git status
```

### 2. Configure Git (if needed)

```bash
# Set your username (replace with your actual name)
git config user.name "Poovarasan"

# Set your email (replace with your actual email)
git config user.email "your-email@example.com"

# Verify configuration
git config --list
```

### 3. Add Files to Staging Area

```bash
# Add all files to staging area
git add .

# Or add specific files:
# git add lib/
# git add assets/
# git add pubspec.yaml
# git add README.md

# Check status
git status
```

### 4. Create Initial Commit

```bash
# Create commit with descriptive message
git commit -m "Initial commit: Complete AI-Based Farmer Query Support and Advisory System

Features implemented:
- Multi-modal search (Text, Voice, Image)
- RAG system with external dataset integration
- AI-powered advisory system
- Comprehensive agricultural knowledge base
- External API integrations (USDA, FAO, OpenWeather, etc.)
- Complete Flutter UI with responsive design"
```

### 5. Add Remote Repository

```bash
# Add the remote repository (replace with your actual repository URL)
git remote add origin https://github.com/Poovarasan-006/AI-Based-Farmer-Query-App.git

# Verify remote is added
git remote -v
```

### 6. Create and Switch to Main Branch

```bash
# Create and switch to main branch
git branch -M main

# Verify current branch
git branch
```

### 7. Push to GitHub

```bash
# First push to remote repository
git push -u origin main

# If you get authentication errors, you may need to:
# 1. Use SSH instead of HTTPS:
#    git remote set-url origin git@github.com:Poovarasan-006/AI-Based-Farmer-Query-App.git
#    git push -u origin main

# 2. Or use HTTPS with personal access token:
#    git push https://<your-username>:<your-token>@github.com/Poovarasan-006/AI-Based-Farmer-Query-App.git main
```

## Alternative: If Repository Already Exists

If the repository already exists on GitHub with files:

```bash
# Fetch and merge existing files
git pull origin main --allow-unrelated-histories

# Then add your files
git add .
git commit -m "Add complete AI-Based Farmer Query Support system"
git push origin main
```

## Setting Up Authentication

### Option 1: SSH Key (Recommended)

```bash
# Generate SSH key (if you don't have one)
ssh-keygen -t ed25519 -C "your-email@example.com"

# Start SSH agent
eval "$(ssh-agent -s)"

# Add SSH key to agent
ssh-add ~/.ssh/id_ed25519

# Copy SSH key to clipboard
cat ~/.ssh/id_ed25519.pub

# Add the SSH key to your GitHub account:
# 1. Go to GitHub.com
# 2. Settings → SSH and GPG keys → New SSH key
# 3. Paste your public key
```

### Option 2: Personal Access Token

```bash
# Create a personal access token on GitHub:
# 1. Go to GitHub.com → Settings → Developer settings → Personal access tokens
# 2. Generate new token with repo permissions
# 3. Use the token as your password when pushing

# Push with token
git push https://<your-username>:<your-token>@github.com/Poovarasan-006/AI-Based-Farmer-Query-App.git main
```

## Post-Push Setup

### 1. Create .env File for API Keys

Create a `.env` file in your project root:

```bash
# Create .env file
touch .env

# Add your API keys (replace with actual keys)
echo "OPENAI_API_KEY=your_openai_api_key_here" >> .env
echo "USDA_API_KEY=your_usda_api_key_here" >> .env
echo "WEATHER_API_KEY=your_weather_api_key_here" >> .env
```

**Note**: Add `.env` to `.gitignore` to keep API keys secure:

```bash
# Add to .gitignore
echo ".env" >> .gitignore
git add .gitignore
git commit -m "Add .env to gitignore for security"
git push origin main
```

### 2. Create GitHub Secrets (for CI/CD)

If you want to set up CI/CD, add secrets to your GitHub repository:

1. Go to repository → Settings → Secrets and variables → Actions
2. Add repository secrets:
   - `OPENAI_API_KEY`
   - `USDA_API_KEY`
   - `WEATHER_API_KEY`

### 3. Create Development Branch

```bash
# Create development branch
git checkout -b develop
git push -u origin develop

# Switch back to main
git checkout main
```

## Verification

### Check Repository Status

```bash
# Check remote repository
git remote -v

# Check recent commits
git log --oneline -5

# Check current branch
git branch --show-current
```

### Verify on GitHub

1. Visit https://github.com/Poovarasan-006/AI-Based-Farmer-Query-App
2. Verify files are uploaded
3. Check that the README.md displays correctly
4. Confirm all directories and files are present

## Troubleshooting

### Common Issues

1. **Authentication Failed**:
   ```bash
   # Clear cached credentials
   git config --global --unset credential.helper
   # Or use:
   git config --system --unset credential.helper
   ```

2. **Large Files**:
   ```bash
   # Check file sizes
   find . -size +10M -type f
   
   # Use Git LFS for large files if needed
   git lfs install
   git lfs track "*.psd"
   ```

3. **Permission Denied**:
   ```bash
   # Check repository permissions
   # Ensure you have write access to the repository
   ```

4. **Merge Conflicts**:
   ```bash
   # If there are conflicts during pull
   git pull origin main
   # Resolve conflicts manually
   git add .
   git commit -m "Resolve merge conflicts"
   git push origin main
   ```

## Next Steps

1. **Set up CI/CD** (optional):
   - Create `.github/workflows/` directory
   - Add Flutter build and test workflows

2. **Documentation**:
   - Update README.md with deployment instructions
   - Add API documentation

3. **Collaboration**:
   - Add team members as collaborators
   - Set up branch protection rules

4. **Deployment**:
   - Set up Firebase for backend (if needed)
   - Configure app signing for Android/iOS

## Project Structure Verification

Ensure your repository has this structure:

```
AI-Based-Farmer-Query-App/
├── lib/
│   ├── main.dart
│   ├── models/
│   ├── services/
│   ├── ui/
│   └── datasets/
├── assets/
│   ├── fonts/
│   ├── icons/
│   └── images/
├── pubspec.yaml
├── README.md
├── .gitignore
└── GIT_PUSH_INSTRUCTIONS.md
```

## Success Confirmation

After pushing, you should see:
- ✅ All files uploaded to GitHub
- ✅ README.md renders correctly
- ✅ Project structure visible
- ✅ No authentication errors
- ✅ Clean commit history

Your AI-Based Farmer Query Support and Advisory System is now successfully deployed to GitHub! 🚀