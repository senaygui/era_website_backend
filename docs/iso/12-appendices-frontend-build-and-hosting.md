# Appendix: Frontend Build and Hosting

## 1. Build
- Install: `npm i`
- Lint: `npm run lint`
- Build: `npm run build`
- Preview: `npm run preview`

## 2. Runtime Configuration
- Default: `/api/v1` on the website origin. Route `/api/` and `/rails/active_storage/` to Rails before the SPA fallback.
- Set `VITE_API_URL` at build time only for a separate, reachable HTTPS API. Remove the old port `8081` override and rebuild.
- Deploy the frontend directory as well as the backend: `era-web-gateway-main` is a separate Git checkout.
- Restart Rails after deploying CORS changes. If `CORS_ALLOWED_ORIGINS` is already set, include `https://www.era.gov.et` and `https://era.gov.et` explicitly.

## 3. Hosting (Placeholder)
Specify the hosting approach used:
- Static hosting platform: [TO FILL]
- Domain(s): [TO FILL]
- TLS certificate management: [TO FILL]

## 4. Deployment Checklist (Recommended)
- Confirm correct `VITE_API_URL` for environment
- Build succeeds
- Smoke test key pages:
  - Home
  - News
  - Events
  - Projects
  - Bids
  - Vacancies
  - Publications downloads
