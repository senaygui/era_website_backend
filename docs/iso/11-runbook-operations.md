# Operations Runbook (Project-Level)

## 1. Service Health
- Health endpoint: `GET /up`
  - Expected: HTTP 200 when app is healthy

## 2. Common Operational Tasks
### 2.1 Restart backend service
- Method depends on deployment:
  - Capistrano/Passenger: restart via deploy restart mechanism (touch restart file)
  - Docker/Kamal: restart container/service

### 2.2 View logs
- Backend logs: STDOUT from Rails process
- Proxy logs: [TO FILL]

### 2.3 Database migrations
- Run migrations as part of deploy.
- Verify schema changes and data migrations.

### 2.4 Backup and restore
- PostgreSQL backup: [TO FILL]
- File storage backup (Active Storage): [TO FILL]

## 3. Incident Handling
- Detect (monitoring/alerting): [TO FILL]
- Triage and assign owner
- Mitigation / rollback if needed
- Post-incident review and corrective actions

## 4. Access Management
- Admin user provisioning: [TO FILL]
- Offboarding: disable admin account, rotate secrets if needed

## 5. CORS Troubleshooting
- Confirm allowed origins in `config/initializers/cors.rb`
- Confirm deployment includes updated initializer
- Restart backend service
- Ensure proxy is not intercepting OPTIONS preflight requests
