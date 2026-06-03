# Appendix: API Inventory (Backend)

## 1. Base Path
- `/api/v1`

## 2. Public API Resources (from `config/routes.rb`)
### 2.1 News
- `GET /api/v1/news`
- `GET /api/v1/news/:slug`

### 2.2 Events
- `GET /api/v1/events`
- `GET /api/v1/events/:id`
- `GET /api/v1/events/featured`
- `GET /api/v1/events/upcoming`

### 2.3 Projects
- `GET /api/v1/projects`
- `GET /api/v1/projects/:id`
- `GET /api/v1/projects/completed`
- `GET /api/v1/projects/ongoing`

### 2.4 Bids
- `GET /api/v1/bids`
- `GET /api/v1/bids/:id`
- `GET /api/v1/bids/active`
- `GET /api/v1/bids/closed`

### 2.5 Vacancies
- `GET /api/v1/vacancies`
- `GET /api/v1/vacancies/:id`
- `GET /api/v1/vacancies/active`
- `GET /api/v1/vacancies/expired`

### 2.6 Districts
- `GET /api/v1/districts`
- `GET /api/v1/districts/:id`
- `GET /api/v1/districts/published`

### 2.7 About
- `GET /api/v1/about`

### 2.8 Publications
- `GET /api/v1/publications`
- `GET /api/v1/publications/:id`
- `GET /api/v1/publications/:id/download`

### 2.9 Road Assets
- `GET /api/v1/road_assets`
- `GET /api/v1/road_assets/:id`
- `GET /api/v1/road_assets/:id/download`

### 2.10 Road Research Centers
- `GET /api/v1/road_research_centers`
- `GET /api/v1/road_research_centers/:id`
- `GET /api/v1/road_research_centers/:id/download`

### 2.11 Performance Reports / Rates
- `GET /api/v1/performance_reports`
- `GET /api/v1/performance_reports/:id`
- `GET /api/v1/performance_reports/:id/download`
- `GET /api/v1/performance_rates`
- `GET /api/v1/performance_rates/:id`
- `GET /api/v1/performance_rates/:id/download`

### 2.12 Applicants
- `GET/POST/PUT/PATCH/DELETE /api/v1/applicants` (full REST as declared)

## 3. Admin Interface
- Root: `/admin`
- Authentication: `devise_for :admin_users`

## 4. Notes
- Exact request/response schemas should be captured via:
  - OpenAPI/Swagger (recommended), or
  - sample requests/responses retained as evidence.
