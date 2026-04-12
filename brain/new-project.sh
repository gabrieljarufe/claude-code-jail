#!/bin/bash
# Usage: new-project.sh <project-name>
set -e

NAME="${1:?Usage: new-project.sh <project-name>}"
TARGET="/workspace/$NAME"

[ -d "$TARGET" ] && echo "Error: $TARGET already exists" && exit 1

mkdir -p "$TARGET"
cd "$TARGET"

git init

cat > .gitignore << 'EOF'
.env
.env.*
secrets/
credentials/
*.log
.DS_Store
EOF

cat > CLAUDE.md << EOF
# $NAME

## Project Context

- **Purpose:** [describe what this project does]
- **Stack:** [language, frameworks, infra]

## Project-specific Rules

[Add any constraints or conventions specific to this project]
EOF

mkdir -p .claude/{plans,tasks,specs,skills,references}

# Ensure git identity is set before committing
GIT_NAME=$(git config --global user.name 2>/dev/null || true)
GIT_EMAIL=$(git config --global user.email 2>/dev/null || true)

if [ -z "$GIT_NAME" ] || [ -z "$GIT_EMAIL" ]; then
    echo ""
    echo "Git identity not configured. Enter your details (saved globally):"
    if [ -z "$GIT_NAME" ]; then
        read -rp "  Name:  " GIT_NAME
        git config --global user.name "$GIT_NAME"
    fi
    if [ -z "$GIT_EMAIL" ]; then
        read -rp "  Email: " GIT_EMAIL
        git config --global user.email "$GIT_EMAIL"
    fi
    echo ""
fi

git add CLAUDE.md .gitignore .claude
git commit -m "chore: initialize project structure"

echo ""
echo "Project '$NAME' ready at $TARGET"
echo "Edit $TARGET/CLAUDE.md to add project context."
