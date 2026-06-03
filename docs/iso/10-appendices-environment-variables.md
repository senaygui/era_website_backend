# Appendix: Environment Variables and Secrets Inventory

## 1. Frontend (Vite)
### 1.1 Variables
- `VITE_API_URL`
  - Purpose: Base URL for backend API.
  - Example: `https://prod-era.era.gov.et/api/v1`
  - Source: Vite environment (.env files or deployment platform env settings)

## 2. Backend (Rails)
### 2.1 Runtime
- `RAILS_ENV`
- `RAILS_LOG_LEVEL`
- `RAILS_MASTER_KEY` (secret)

### 2.2 Database (development/test)
- `DB_USERNAME`
- `DB_PASSWORD` (secret)
- `DB_HOST`
- `DB_PORT`

### 2.3 Rails Credentials (production)
Stored in encrypted credentials; accessed with `RAILS_MASTER_KEY`:
- `production.db.username` (secret)
- `production.db.password` (secret)

## 3. Secret Handling Rules (Minimum)
- Secrets are not committed to git.
- Secrets are stored in the deployment platform secret store.
- Access to production secrets is approved and logged.

> Placeholder: attach your organization’s approved secret handling policy if required for audit.
