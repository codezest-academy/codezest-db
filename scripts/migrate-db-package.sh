#!/bin/bash
# migrate-db-package.sh
# Script to migrate all services from @codezest-academy/db to @codezest-academy/codezest-db

set -e

SERVICES=("codezest-auth" "codezest-api" "codezest-payments" "codezest-notifications" "codezest-activity")
BASE_DIR="/Volumes/CVS Sandisk 1TB SkyBlue/Quiz"
OLD_PACKAGE="@codezest-academy/db"
NEW_PACKAGE="@codezest-academy/codezest-db"

echo "🔄 Starting package migration..."
echo ""

for service in "${SERVICES[@]}"; do
  SERVICE_PATH="$BASE_DIR/$service"
  
  if [ ! -d "$SERVICE_PATH" ]; then
    echo "⏭️  Skipping $service (directory not found)"
    continue
  fi
  
  if [ ! -f "$SERVICE_PATH/package.json" ]; then
    echo "⏭️  Skipping $service (no package.json)"
    continue
  fi
  
  # Check if service uses the old package
  if ! grep -q "$OLD_PACKAGE" "$SERVICE_PATH/package.json"; then
    echo "⏭️  Skipping $service (not using old package)"
    continue
  fi
  
  echo "📦 Updating $service..."
  cd "$SERVICE_PATH"
  
  # Uninstall old package
  npm uninstall "$OLD_PACKAGE" 2>/dev/null || true
  
  # Install new package
  npm install "$NEW_PACKAGE"
  
  # Commit changes
  git add package.json package-lock.json
  git commit -m "chore: migrate from $OLD_PACKAGE to $NEW_PACKAGE

- Updated package dependency
- No code changes required (imports remain the same)
- See PACKAGE_MIGRATION_GUIDE.md for details"
  
  echo "✅ $service updated successfully"
  echo ""
done

echo "🎉 Migration complete!"
echo ""
echo "Next steps:"
echo "1. Test each service to ensure it works correctly"
echo "2. Push changes: cd <service> && git push origin main"
echo "3. Update CI/CD pipelines if needed"
