# Architecture and Data Flow

## 1. Architecture Style
- **Frontend**: Single Page Application (SPA) built with Vite + React.
- **Backend**: Rails-based REST API under `/api/v1` and an admin UI using ActiveAdmin.

## 2. Logical Architecture
### 2.1 Frontend (Public Gateway)
- Presentation layer (React pages/components)
- Data access layer (Axios client + React Query where used)
- Configuration via Vite environment variables (`VITE_API_URL`)

### 2.2 Backend (Rails)
- Controllers under `Api::V1::*` for public endpoints
- ActiveAdmin controllers/resources for admin operations
- Models backed by PostgreSQL
- Active Storage for downloadable artifacts

## 3. Runtime Data Flow (Typical)
### 3.1 Public content viewing
1. User loads SPA.
2. SPA requests data from backend API (e.g., `GET /api/v1/news`).
3. Backend returns JSON.
4. SPA renders content.

### 3.2 Document download
1. SPA requests a document download endpoint (e.g., `GET /api/v1/publications/:id/download`).
2. Backend authorizes (if public, no auth required) and streams file via Active Storage.

### 3.3 Admin content management
1. Admin authenticates via Devise (`admin_users`).
2. Admin uses ActiveAdmin to manage resources.
3. Backend persists changes to PostgreSQL and optionally stores uploads via Active Storage.

## 4. Deployment Architecture (Conceptual)
- Reverse proxy / web server terminates TLS and forwards to Rails.
- Rails runs behind Puma/Passenger (Capistrano config indicates Passenger restart strategy is used).
- Database is PostgreSQL (configured via credentials in production).

> Placeholder to confirm:
> - Exact web server / reverse proxy (Nginx/Apache/Traefik)
> - Hosting topology (single VM vs multiple nodes)
> - Where PostgreSQL runs (same host vs managed service)

## 5. Security-Relevant Data Flows (ISO/IEC 27001)
- Admin login requests and session cookie handling
- API requests from browser origin(s) (CORS controlled)
- File uploads/downloads via Active Storage

## 6. Interfaces / Endpoints (High Level)
Backend route namespaces:
- `/api/v1/*` public API
- `/admin/*` admin UI

A detailed endpoint inventory is in `09-appendices-api-inventory.md`.
