# ISO/IEC 27001 (ISMS) - System Controls (Project-Level)

## 1. System Description (ISMS context)
The system includes a public frontend and a backend service providing public APIs and an authenticated admin interface.

## 2. Asset Inventory (high level)
- **Source code**: repository contents
- **Production database**: PostgreSQL databases (primary + cache/queue/cable where configured)
- **Credentials/secrets**: Rails encrypted credentials; environment variables
- **Logs**: application logs emitted to STDOUT
- **Uploaded files**: Active Storage data (local service per current config)

## 3. Data Classification (to confirm)
- Public content: news/events/projects/bids/vacancies/publications metadata
- Potentially sensitive:
  - Admin user accounts
  - Applicant submissions (PII likely)

> Placeholder: define classification labels used by your organization (Public/Internal/Confidential) and map each dataset.

## 4. Access Control
- Admin access via Devise (`admin_users`) + ActiveAdmin.
- Principle: least privilege (confirm whether multiple roles exist).

Required evidence:
- Admin user list and access approval records
- Offboarding checklist (account deactivation)

## 5. Cryptography and Secrets
- Secrets stored in Rails credentials; unlocked via `RAILS_MASTER_KEY`.
- TLS is expected at the proxy boundary.

> Placeholder: confirm TLS termination and certificate management.

## 6. Logging and Monitoring
- Rails logs configured and emitted to STDOUT.

> Placeholder:
> - log retention policy
> - access logs (proxy)
> - monitoring/alerting solution

## 7. Vulnerability Management
- Dependency management:
  - Backend gems via Bundler
  - Frontend packages via npm

Recommended minimum controls:
- Regular dependency updates
- Periodic vulnerability scans
- Review security advisories for Rails/Node dependencies

## 8. Backup and Recovery
> Placeholder: document actual backup process for:
> - PostgreSQL
> - Active Storage files
> - Secrets/credentials escrow

## 9. Incident Management
> Placeholder: define severity levels, response SLAs, escalation contacts, and post-incident review requirements.

## 10. Supplier / Third-Party Management
- Hosting provider: [TO FILL]
- Domain/DNS provider: [TO FILL]
- CDN/WAF (if any): [TO FILL]

## 11. Annex A Control Mapping (Lightweight)
This project pack supports evidence for selected controls such as:
- Access control (admin authentication)
- Cryptography (TLS boundary, secrets handling)
- Logging/monitoring
- Change management (PR-based)
- Backup/DR

> Note: Final Annex A mapping should be completed against your organization’s Statement of Applicability (SoA).
