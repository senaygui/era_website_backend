# Environments and Configuration

## 1. Environments
- **Development**: local developer machines
- **Test**: automated tests (`test/` folder present; `rails test`)
- **Staging**: optional (Capistrano stages include `staging`)
- **Production**: live environment

## 2. Backend Configuration (Rails)
### 2.1 Runtime configuration
- `RAILS_ENV`
- `RAILS_LOG_LEVEL` (production reads from env; app defaults log level to debug in `config/application.rb`)
- `RAILS_MASTER_KEY` (required for credentials)

### 2.2 Database configuration
- PostgreSQL
- Development/test use environment variables:
  - `DB_USERNAME`, `DB_PASSWORD`, `DB_HOST`, `DB_PORT`
- Production uses Rails credentials:
  - `credentials.dig(:production, :db, :username)`
  - `credentials.dig(:production, :db, :password)`

### 2.3 Secrets management
- Rails encrypted credentials; access controlled by `RAILS_MASTER_KEY`

### 2.4 CORS configuration
- Configured via Rack::Cors initializer: `config/initializers/cors.rb`

## 3. Frontend Configuration (Vite)
### 3.1 Environment variables
- `VITE_API_URL` (preferred)

### 3.2 Default API URL fallback
If `VITE_API_URL` is not set, the frontend falls back based on `window.location.hostname`:
- On localhost: `http://localhost:3000/api/v1`
- Otherwise: `https://prod-era.era.gov.et:8081/api/v1`

> Note: In production, prefer setting `VITE_API_URL` explicitly to avoid coupling to hostname assumptions.

### 3.3 Dev server proxy
`vite.config.ts` proxies `/api` to `https://prod-era.era.gov.et:8081/`.

## 4. Configuration Control (ISO 9001 / 12207)
- All configuration is version-controlled except secrets.
- Secrets are managed via Rails credentials and environment variables.

## 5. Required Records / Evidence
- Environment variable inventory (fill in Appendix)
- Credentials access list (who has `RAILS_MASTER_KEY`)
- Change records for production configuration changes
