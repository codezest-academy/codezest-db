# Deployment Scripts & Automation

Collection of scripts for deploying and managing the CodeZest platform.

---

## Table of Contents

1. [Quick Start Scripts](#quick-start-scripts)
2. [Database Management](#database-management)
3. [Kubernetes Deployment](#kubernetes-deployment)
4. [CI/CD Helpers](#cicd-helpers)
5. [Monitoring & Health Checks](#monitoring--health-checks)

---

## Quick Start Scripts

### Local Development Startup

Create `scripts/dev-start.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 Starting CodeZest Local Development Environment..."

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "❌ Docker is required but not installed."; exit 1; }
command -v node >/dev/null 2>&1 || { echo "❌ Node.js is required but not installed."; exit 1; }

# Start infrastructure
echo "📦 Starting infrastructure services..."
docker-compose up -d postgres redis rabbitmq mailhog

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 5

# Check PostgreSQL
until docker-compose exec -T postgres pg_isready -U codezest > /dev/null 2>&1; do
  echo "Waiting for PostgreSQL..."
  sleep 2
done
echo "✅ PostgreSQL is ready"

# Check Redis
until docker-compose exec -T redis redis-cli -a dev_redis_password ping > /dev/null 2>&1; do
  echo "Waiting for Redis..."
  sleep 2
done
echo "✅ Redis is ready"

# Check RabbitMQ
until docker-compose exec -T rabbitmq rabbitmq-diagnostics -q ping > /dev/null 2>&1; do
  echo "Waiting for RabbitMQ..."
  sleep 2
done
echo "✅ RabbitMQ is ready"

# Run database migrations
echo "🗄️  Running database migrations..."
cd codezest-db
npm run db:migrate:dev
cd ..

echo "✅ Development environment is ready!"
echo ""
echo "📋 Next steps:"
echo "  1. Start services: npm run dev (in each service directory)"
echo "  2. Access RabbitMQ UI: http://localhost:15672"
echo "  3. Access MailHog UI: http://localhost:8025"
echo ""
```

Make executable:

```bash
chmod +x scripts/dev-start.sh
./scripts/dev-start.sh
```

### Local Development Cleanup

Create `scripts/dev-cleanup.sh`:

```bash
#!/bin/bash
set -e

echo "🧹 Cleaning up CodeZest development environment..."

# Stop all services
echo "Stopping Docker services..."
docker-compose down

# Optional: Remove volumes (WARNING: This deletes all data)
read -p "Do you want to remove all data volumes? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  docker-compose down -v
  echo "✅ All volumes removed"
fi

# Clean node_modules (optional)
read -p "Do you want to clean node_modules? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  find . -name "node_modules" -type d -prune -exec rm -rf '{}' +
  echo "✅ node_modules cleaned"
fi

echo "✅ Cleanup complete"
```

---

## Database Management

### Migration Script

Create `scripts/db-migrate.sh`:

```bash
#!/bin/bash
set -e

ENVIRONMENT=${1:-development}

echo "🗄️  Running database migrations for: $ENVIRONMENT"

case $ENVIRONMENT in
  development)
    cd codezest-db
    npm run db:migrate:dev
    ;;

  staging)
    echo "⚠️  Migrating STAGING database..."
    read -p "Are you sure? (yes/no) " -r
    if [[ $REPLY == "yes" ]]; then
      cd codezest-db
      DATABASE_URL=$STAGING_DATABASE_URL npm run db:migrate:deploy
    else
      echo "Migration cancelled"
      exit 1
    fi
    ;;

  production)
    echo "🚨 PRODUCTION MIGRATION"
    echo "This will modify the production database!"
    read -p "Type 'MIGRATE PRODUCTION' to continue: " -r
    if [[ $REPLY == "MIGRATE PRODUCTION" ]]; then
      # Create backup first
      echo "Creating backup..."
      ./scripts/db-backup.sh production

      # Run migration
      cd codezest-db
      DATABASE_URL=$PRODUCTION_DATABASE_URL npm run db:migrate:deploy

      echo "✅ Production migration complete"
    else
      echo "Migration cancelled"
      exit 1
    fi
    ;;

  *)
    echo "❌ Invalid environment: $ENVIRONMENT"
    echo "Usage: ./scripts/db-migrate.sh [development|staging|production]"
    exit 1
    ;;
esac
```

### Backup Script

Create `scripts/db-backup.sh`:

```bash
#!/bin/bash
set -e

ENVIRONMENT=${1:-production}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="./backups"

mkdir -p $BACKUP_DIR

echo "💾 Creating database backup for: $ENVIRONMENT"

case $ENVIRONMENT in
  development)
    docker-compose exec -T postgres pg_dump -U codezest codezest_dev > "$BACKUP_DIR/dev_backup_$TIMESTAMP.sql"
    echo "✅ Backup saved to: $BACKUP_DIR/dev_backup_$TIMESTAMP.sql"
    ;;

  staging)
    # RDS snapshot
    aws rds create-db-snapshot \
      --db-instance-identifier codezest-staging \
      --db-snapshot-identifier codezest-staging-$TIMESTAMP
    echo "✅ RDS snapshot created: codezest-staging-$TIMESTAMP"
    ;;

  production)
    # RDS snapshot
    aws rds create-db-snapshot \
      --db-instance-identifier codezest-prod \
      --db-snapshot-identifier codezest-prod-$TIMESTAMP
    echo "✅ RDS snapshot created: codezest-prod-$TIMESTAMP"

    # Also export to S3
    aws rds start-export-task \
      --export-task-identifier export-$TIMESTAMP \
      --source-arn arn:aws:rds:us-east-1:123456789012:snapshot:codezest-prod-$TIMESTAMP \
      --s3-bucket-name codezest-db-backups \
      --iam-role-arn arn:aws:iam::123456789012:role/rds-export-role \
      --kms-key-id arn:aws:kms:us-east-1:123456789012:key/abcd1234
    echo "✅ Export to S3 initiated"
    ;;
esac
```

### Restore Script

Create `scripts/db-restore.sh`:

```bash
#!/bin/bash
set -e

ENVIRONMENT=$1
BACKUP_ID=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$BACKUP_ID" ]; then
  echo "Usage: ./scripts/db-restore.sh [environment] [backup_id]"
  echo "Example: ./scripts/db-restore.sh production codezest-prod-20241123_120000"
  exit 1
fi

echo "🔄 Restoring database from backup: $BACKUP_ID"
echo "Environment: $ENVIRONMENT"
echo ""
echo "⚠️  WARNING: This will REPLACE the current database!"
read -p "Type 'RESTORE' to continue: " -r

if [[ $REPLY != "RESTORE" ]]; then
  echo "Restore cancelled"
  exit 1
fi

case $ENVIRONMENT in
  production)
    # Restore RDS from snapshot
    aws rds restore-db-instance-from-db-snapshot \
      --db-instance-identifier codezest-prod-restored \
      --db-snapshot-identifier $BACKUP_ID \
      --db-instance-class db.t3.medium \
      --multi-az

    echo "✅ Restore initiated. New instance: codezest-prod-restored"
    echo "⏳ Waiting for instance to be available..."

    aws rds wait db-instance-available \
      --db-instance-identifier codezest-prod-restored

    echo "✅ Database restored successfully"
    echo ""
    echo "📋 Next steps:"
    echo "  1. Verify data integrity"
    echo "  2. Update DATABASE_URL in services"
    echo "  3. Switch traffic to new instance"
    echo "  4. Delete old instance after verification"
    ;;

  development)
    if [ -f "$BACKUP_ID" ]; then
      docker-compose exec -T postgres psql -U codezest codezest_dev < "$BACKUP_ID"
      echo "✅ Database restored from file: $BACKUP_ID"
    else
      echo "❌ Backup file not found: $BACKUP_ID"
      exit 1
    fi
    ;;
esac
```

---

## Kubernetes Deployment

### Deploy All Services

Create `scripts/k8s-deploy.sh`:

```bash
#!/bin/bash
set -e

ENVIRONMENT=${1:-staging}
VERSION=${2:-latest}

echo "🚀 Deploying CodeZest to: $ENVIRONMENT"
echo "Version: $VERSION"

# Set kubectl context
case $ENVIRONMENT in
  staging)
    kubectl config use-context codezest-staging
    NAMESPACE="codezest-services"
    ;;
  production)
    kubectl config use-context codezest-prod
    NAMESPACE="codezest-services"

    echo "🚨 PRODUCTION DEPLOYMENT"
    read -p "Type 'DEPLOY PRODUCTION' to continue: " -r
    if [[ $REPLY != "DEPLOY PRODUCTION" ]]; then
      echo "Deployment cancelled"
      exit 1
    fi
    ;;
  *)
    echo "❌ Invalid environment"
    exit 1
    ;;
esac

# Deploy services in order (dependencies first)
SERVICES=("auth" "api" "payments" "notifications" "activity")

for SERVICE in "${SERVICES[@]}"; do
  echo ""
  echo "📦 Deploying codezest-$SERVICE..."

  # Update image tag
  kubectl set image deployment/codezest-$SERVICE \
    $SERVICE=ghcr.io/codezest-academy/codezest-$SERVICE:$VERSION \
    -n $NAMESPACE

  # Wait for rollout
  kubectl rollout status deployment/codezest-$SERVICE -n $NAMESPACE --timeout=5m

  # Check health
  POD=$(kubectl get pod -l app=codezest-$SERVICE -n $NAMESPACE -o jsonpath='{.items[0].metadata.name}')
  kubectl exec $POD -n $NAMESPACE -- wget -q -O- http://localhost:3000/health || {
    echo "❌ Health check failed for $SERVICE"
    echo "Rolling back..."
    kubectl rollout undo deployment/codezest-$SERVICE -n $NAMESPACE
    exit 1
  }

  echo "✅ codezest-$SERVICE deployed successfully"
done

echo ""
echo "✅ All services deployed successfully!"
```

### Rollback Script

Create `scripts/k8s-rollback.sh`:

```bash
#!/bin/bash
set -e

ENVIRONMENT=$1
SERVICE=$2

if [ -z "$ENVIRONMENT" ] || [ -z "$SERVICE" ]; then
  echo "Usage: ./scripts/k8s-rollback.sh [environment] [service]"
  echo "Example: ./scripts/k8s-rollback.sh production auth"
  exit 1
fi

echo "⏪ Rolling back codezest-$SERVICE in $ENVIRONMENT"

case $ENVIRONMENT in
  staging)
    kubectl config use-context codezest-staging
    ;;
  production)
    kubectl config use-context codezest-prod
    echo "🚨 PRODUCTION ROLLBACK"
    read -p "Confirm rollback? (yes/no) " -r
    if [[ $REPLY != "yes" ]]; then
      echo "Rollback cancelled"
      exit 1
    fi
    ;;
esac

# Perform rollback
kubectl rollout undo deployment/codezest-$SERVICE -n codezest-services

# Wait for rollback to complete
kubectl rollout status deployment/codezest-$SERVICE -n codezest-services --timeout=5m

echo "✅ Rollback complete"

# Show revision history
echo ""
echo "📋 Deployment history:"
kubectl rollout history deployment/codezest-$SERVICE -n codezest-services
```

---

## CI/CD Helpers

### Build and Push Docker Image

Create `scripts/docker-build-push.sh`:

```bash
#!/bin/bash
set -e

SERVICE=$1
VERSION=${2:-$(git rev-parse --short HEAD)}
REGISTRY="ghcr.io/codezest-academy"

if [ -z "$SERVICE" ]; then
  echo "Usage: ./scripts/docker-build-push.sh [service] [version]"
  echo "Example: ./scripts/docker-build-push.sh auth v1.2.3"
  exit 1
fi

IMAGE="$REGISTRY/codezest-$SERVICE"

echo "🐳 Building Docker image: $IMAGE:$VERSION"

# Build image
docker build \
  -t $IMAGE:$VERSION \
  -t $IMAGE:latest \
  --build-arg NODE_ENV=production \
  --build-arg VERSION=$VERSION \
  -f Dockerfile \
  .

# Run security scan
echo "🔍 Running security scan..."
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image --severity HIGH,CRITICAL $IMAGE:$VERSION

# Push to registry
echo "📤 Pushing to registry..."
docker push $IMAGE:$VERSION
docker push $IMAGE:latest

echo "✅ Image pushed: $IMAGE:$VERSION"
```

### Run Tests in CI

Create `scripts/ci-test.sh`:

```bash
#!/bin/bash
set -e

echo "🧪 Running CI tests..."

# Lint
echo "📝 Running linter..."
npm run lint

# Type check
echo "🔍 Type checking..."
npm run type-check

# Unit tests
echo "🧪 Running unit tests..."
npm run test:unit -- --coverage

# Integration tests (with Docker services)
echo "🔗 Running integration tests..."
docker-compose -f docker-compose.test.yml up -d
sleep 5

npm run test:integration

docker-compose -f docker-compose.test.yml down

echo "✅ All tests passed!"
```

---

## Monitoring & Health Checks

### Health Check Script

Create `scripts/health-check.sh`:

```bash
#!/bin/bash

ENVIRONMENT=${1:-staging}

case $ENVIRONMENT in
  staging)
    BASE_URL="https://staging.codezest.academy"
    ;;
  production)
    BASE_URL="https://api.codezest.academy"
    ;;
  local)
    BASE_URL="http://localhost"
    ;;
esac

SERVICES=("auth:3001" "api:3002" "payments:3003" "notifications:3004" "activity:3005")

echo "🏥 Health Check for: $ENVIRONMENT"
echo "Base URL: $BASE_URL"
echo ""

ALL_HEALTHY=true

for SERVICE_PORT in "${SERVICES[@]}"; do
  IFS=':' read -r SERVICE PORT <<< "$SERVICE_PORT"

  if [ "$ENVIRONMENT" == "local" ]; then
    URL="$BASE_URL:$PORT/health"
  else
    URL="$BASE_URL/$SERVICE/health"
  fi

  echo -n "Checking $SERVICE... "

  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" $URL)

  if [ "$HTTP_CODE" == "200" ]; then
    echo "✅ Healthy"
  else
    echo "❌ Unhealthy (HTTP $HTTP_CODE)"
    ALL_HEALTHY=false
  fi
done

echo ""
if [ "$ALL_HEALTHY" = true ]; then
  echo "✅ All services are healthy"
  exit 0
else
  echo "❌ Some services are unhealthy"
  exit 1
fi
```

### Smoke Tests

Create `scripts/smoke-test.sh`:

```bash
#!/bin/bash
set -e

ENVIRONMENT=${1:-staging}
BASE_URL=${2:-https://staging.codezest.academy}

echo "🔥 Running smoke tests against: $BASE_URL"

# Test 1: Health endpoints
echo "Test 1: Health endpoints..."
curl -f $BASE_URL/auth/health || exit 1
curl -f $BASE_URL/api/health || exit 1
echo "✅ Health checks passed"

# Test 2: User registration
echo "Test 2: User registration..."
RESPONSE=$(curl -s -X POST $BASE_URL/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "smoke-test-'$(date +%s)'@test.com",
    "password": "TestPassword123!",
    "name": "Smoke Test User"
  }')

if echo $RESPONSE | grep -q "id"; then
  echo "✅ Registration successful"
else
  echo "❌ Registration failed"
  echo $RESPONSE
  exit 1
fi

# Test 3: Login
echo "Test 3: User login..."
LOGIN_RESPONSE=$(curl -s -X POST $BASE_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@codezest.academy",
    "password": "TestPassword123!"
  }')

TOKEN=$(echo $LOGIN_RESPONSE | jq -r '.accessToken')

if [ "$TOKEN" != "null" ] && [ -n "$TOKEN" ]; then
  echo "✅ Login successful"
else
  echo "❌ Login failed"
  exit 1
fi

# Test 4: Authenticated request
echo "Test 4: Authenticated request..."
curl -f -H "Authorization: Bearer $TOKEN" $BASE_URL/api/courses || exit 1
echo "✅ Authenticated request successful"

echo ""
echo "✅ All smoke tests passed!"
```

---

## Usage Examples

### Local Development

```bash
# Start everything
./scripts/dev-start.sh

# Run health checks
./scripts/health-check.sh local

# Clean up
./scripts/dev-cleanup.sh
```

### Database Operations

```bash
# Create backup
./scripts/db-backup.sh production

# Run migrations
./scripts/db-migrate.sh staging

# Restore from backup
./scripts/db-restore.sh production codezest-prod-20241123_120000
```

### Kubernetes Deployments

```bash
# Deploy to staging
./scripts/k8s-deploy.sh staging v1.2.3

# Deploy to production
./scripts/k8s-deploy.sh production v1.2.3

# Rollback
./scripts/k8s-rollback.sh production auth
```

### CI/CD

```bash
# Build and push image
./scripts/docker-build-push.sh auth v1.2.3

# Run tests
./scripts/ci-test.sh

# Smoke tests
./scripts/smoke-test.sh production https://api.codezest.academy
```

---

## Automation with Makefile

Create `Makefile` in project root:

```makefile
.PHONY: help dev-start dev-stop test deploy

help:
	@echo "CodeZest Platform - Available Commands"
	@echo ""
	@echo "Development:"
	@echo "  make dev-start    - Start local development environment"
	@echo "  make dev-stop     - Stop local development environment"
	@echo "  make test         - Run all tests"
	@echo ""
	@echo "Database:"
	@echo "  make db-migrate   - Run database migrations"
	@echo "  make db-backup    - Create database backup"
	@echo ""
	@echo "Deployment:"
	@echo "  make deploy-staging    - Deploy to staging"
	@echo "  make deploy-production - Deploy to production"
	@echo "  make health-check      - Check service health"

dev-start:
	./scripts/dev-start.sh

dev-stop:
	./scripts/dev-cleanup.sh

test:
	./scripts/ci-test.sh

db-migrate:
	./scripts/db-migrate.sh development

db-backup:
	./scripts/db-backup.sh production

deploy-staging:
	./scripts/k8s-deploy.sh staging $(VERSION)

deploy-production:
	./scripts/k8s-deploy.sh production $(VERSION)

health-check:
	./scripts/health-check.sh $(ENV)
```

Usage:

```bash
make dev-start
make test
make deploy-staging VERSION=v1.2.3
make health-check ENV=production
```

---

## Next Steps

1. Copy these scripts to your project root `/scripts` directory
2. Make all scripts executable: `chmod +x scripts/*.sh`
3. Customize environment-specific values (URLs, AWS account IDs, etc.)
4. Test scripts in development environment first
5. Integrate into CI/CD pipelines

For complete deployment guide, see [ENVIRONMENT_SETUP.md](./ENVIRONMENT_SETUP.md)
