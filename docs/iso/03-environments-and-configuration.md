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
- Configured via Rack::Cors initializer: `config/initializers/cors.rb`. Production defaults allow `https://www.era.gov.et`, `https://era.gov.et`, and `https://prod-era.era.gov.et`.
- `CORS_ALLOWED_ORIGINS` overrides these defaults with a comma-separated list of exact origins. Existing deployments with this variable set must include the live website origins. Restart Rails after changing it.

### 2.5 Document previews
- `DOCUMENT_FRAME_ALLOWED_ORIGINS`: comma-separated frontend origins allowed to embed PDF responses from Active Storage. Defaults to `https://prod-era.era.gov.et` in production and `http://localhost:8080,http://127.0.0.1:8080` elsewhere. Use exact origins (scheme, host, and optional port), without paths or trailing slashes.
- Restart Rails after changing this setting. The document middleware replaces `frame-ancestors` and removes `X-Frame-Options` only on successful PDF file responses; admin pages retain their existing frame protection.
- If the reverse proxy adds its own `X-Frame-Options` or CSP headers, configure it to preserve the application policy on these file responses. Check the final `/rails/active_storage/disk/...` response after redirects, including partial-content (206) responses.
- The frontend embeds PDFs and provides an open/download link. Word and Excel files use the open/download link because native browser iframe rendering does not provide an Office document viewer.
- Deploy both the Rails change and the frontend build. Cloud storage would need its own response-header configuration; this application currently uses the local disk service.

## 3. Frontend Configuration (Vite)
### 3.1 Environment variables
- `VITE_API_URL` (preferred)

### 3.2 Default API URL fallback
All API clients share `src/config/api.ts`. Without `VITE_API_URL`, requests use `/api/v1` on the website origin. Uploaded files use the same origin as the configured API.

Production hosting must route `/api/` and `/rails/active_storage/` to Rails before the frontend SPA fallback. The live `https://www.era.gov.et/api/v1/news` route returned JSON with HTTP 200 during the 2026-10-12 check; the old public port `8081` timed out.

If the API is hosted separately, set `VITE_API_URL` to its publicly reachable HTTPS URL ending in `/api/v1`, and include the frontend origin in Rails CORS. Vite reads this setting at build time: changing it requires rebuilding and deploying the frontend. Remove any old `https://era.gov.et:8081/api/v1` override.

### 3.3 Dev server proxy
`vite.config.ts` proxies `/api` and `/rails/active_storage` to `http://127.0.0.1:3000`, or `VITE_PROXY_TARGET` when provided. Run Rails on that target while using the Vite development server.

## 4. Configuration Control (ISO 9001 / 12207)
- All configuration is version-controlled except secrets.
- Secrets are managed via Rails credentials and environment variables.

## 5. Required Records / Evidence
- Environment variable inventory (fill in Appendix)
- Credentials access list (who has `RAILS_MASTER_KEY`)
- Change records for production configuration changes
