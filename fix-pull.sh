#!/bin/bash
# Script to fix git pull conflicts

cd ~/plat-edu-bad-data-mvp

echo "Stashing local changes to server-diagnose.sh..."
git stash push -m "Local changes to server-diagnose.sh before pull"

echo "Pulling latest changes..."
git pull origin main

echo "Done! If you had important local changes, you can restore them with:"
echo "  git stash pop"

