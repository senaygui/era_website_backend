# Build, Test, Release, and Deployment

## 1. Backend (Rails)
### 1.1 Local build/run (typical)
- Install Ruby dependencies via Bundler (`bundle install`)
- Configure database connection variables or credentials
- Run migrations (`bin/rails db:migrate`)
- Start server (`bin/rails server`)

### 1.2 Testing
- Test framework: Rails built-in Minitest (`test/`)
- Run tests: `bin/rails test`

### 1.3 Release packaging
- Dockerfile present for production image build.
- Asset precompile occurs during Docker build using `SECRET_KEY_BASE_DUMMY=1`.

### 1.4 Deployment options present in repo
- **Capistrano** (`config/deploy.rb`, `config/deploy/production.rb`)
  - Passenger restart with touch enabled
- **Kamal** (`config/deploy.yml`)
  - Secrets via `.kamal/secrets` and `RAILS_MASTER_KEY`

> Placeholder to confirm:
> - Which deployment method is authoritative (Capistrano vs Kamal)
> - Actual production hostnames, DNS, and TLS termination

## 2. Frontend (Vite/React)
### 2.1 Local run
- Install dependencies: `npm i`
- Start dev server: `npm run dev`

### 2.2 Build
- Production build: `npm run build`

### 2.3 Release
- Output is a static bundle produced by Vite.

> Placeholder to confirm:
> - Where the static files are hosted (Nginx, S3/CloudFront, Lovable publish, etc.)

## 3. Change Control (ISO 9001)
Minimum required steps for production changes:
1. Create change request / ticket.
2. Peer review (PR) and approval.
3. Run automated tests and/or smoke tests.
4. Deploy to staging (if used).
5. Deploy to production.
6. Post-deploy verification (API health, key endpoints).

## 4. Rollback
- Backend: redeploy previous release tag or container image.
- Frontend: redeploy previous static bundle.

## 5. Operational Monitoring
> Placeholder to confirm:
> - Log aggregation (if any)
> - APM/metrics (if any)
> - Alerting channels
