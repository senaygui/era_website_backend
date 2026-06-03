# System Overview (Frontend + Backend)

## 1. System Name
ERA Website System

## 2. System Purpose
Provide public-facing web access to ERA information and publications, and provide an administrative interface to manage content.

## 3. System Components
### 3.1 Backend (API + Admin)
- **Service name**: `era_website_backend`
- **Framework**: Ruby on Rails (`~> 8.0.2`)
- **Mode**: `config.api_only = true` (API-focused), with additional middleware enabled for cookies/sessions
- **Key modules**:
  - ActiveAdmin (admin UI)
  - Devise (authentication for `admin_users`)
  - PostgreSQL (primary datastore)
  - Active Storage (file/document storage; configured as local in production config)
- **Primary responsibility**:
  - Serve REST API endpoints under `/api/v1/*`
  - Serve admin interface under `/admin/*`

### 3.2 Frontend (Public Web Gateway)
- **App folder**: `era-web-gateway-main`
- **Framework/tooling**: Vite + React + TypeScript
- **UI**: Tailwind CSS + shadcn-ui (Radix UI)
- **Data fetching**:
  - Axios instance configured in `src/lib/axios.ts`
  - Base URL from `VITE_API_URL` or defaults

## 4. Users & Roles (System-Level)
- **Public user**: anonymous visitors consuming public content via frontend and public API endpoints.
- **Admin user**: authenticated staff using the ActiveAdmin interface to create/update content.

> Placeholders to confirm:
> - Admin role model (single admin role vs multiple permission levels)
> - Content approval workflow (draft/review/publish) if applicable

## 5. High-Level Business Functions
- Content publishing (news, events, projects)
- Procurement information (bids)
- Job postings (vacancies) and applicant intake
- Publications and downloads (documents / reports)

## 6. System Boundary (for ISO/IEC 27001)
Included:
- Frontend SPA
- Backend Rails application
- Databases used by Rails (PostgreSQL)
- File storage used by Active Storage
- Deployment tooling (Capistrano and/or Kamal) as part of operational process

Excluded unless explicitly added:
- External DNS/CDN/WAF providers
- Organization email systems (unless used for system email notifications)

## 7. Key External Interfaces
- HTTP(S) API between frontend and backend
- Admin authentication via Devise/ActiveAdmin

## 8. References
- Backend routes: `config/routes.rb`
- Backend config: `config/application.rb`
- Frontend config: `era-web-gateway-main/vite.config.ts`
- Frontend API client: `era-web-gateway-main/src/lib/axios.ts`
