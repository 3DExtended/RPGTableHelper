# Navigate to the project directory
cd /mnt/user/projects/RPGTableHelper || exit

# Fetch latest changes
git fetch origin main

# Check if there are new changes
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
    echo "Changes detected, pulling new updates..."
    git pull origin main

    # Restart Docker Compose
    docker-compose -f docker-compose.yml -f docker-compose.override.yml up -d --build

else
    echo "No changes detected."
fi
