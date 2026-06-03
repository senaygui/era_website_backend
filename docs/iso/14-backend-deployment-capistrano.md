# Backend Deployment Procedure (Capistrano)

## 1. Scope
This runbook describes how to deploy the backend Rails service (`era_website_backend`) using Capistrano.

## 2. Prerequisites
- Local machine has Ruby matching `.ruby-version`.
- Bundler installed.
- SSH access to production server(s) configured in `config/deploy/production.rb`.
- The production server has:
  - `rbenv` installed and Ruby version matching `.ruby-version`.
  - Passenger installed and configured (Capistrano uses `capistrano-passenger`).
  - PostgreSQL connectivity and required credentials.

## 3. Configuration Files
- `Capfile`
  - Enables Capistrano plugins: rbenv, bundler, rails, passenger.
- `config/deploy.rb`
  - Repository URL, linked files/dirs, and global deploy settings.
- `config/deploy/production.rb`
  - Production server roles and `deploy_to`.

## 4. Secrets and Linked Files
- `config/master.key` is configured as a Capistrano linked file.
  - On the server it must exist at:
    - `${deploy_to}/shared/config/master.key`

## 5. First-time Server Setup (one-time)
Run:
- `bundle exec cap production deploy:check`

Then create required shared paths:
- Ensure `${deploy_to}/shared/config/` exists
- Upload `config/master.key` to `${deploy_to}/shared/config/master.key`

## 6. Standard Deployment
1. Ensure local changes are pushed to `main`.
2. Deploy:
   - `bundle exec cap production deploy`

## 7. Post-deploy Verification
- Health check:
  - `GET /up` returns 200
- Smoke test key APIs:
  - `GET /api/v1/news`
  - `GET /api/v1/events`
  - `GET /api/v1/projects`
  - `GET /api/v1/bids`

## 8. Restart Strategy
- Passenger is restarted using the touch restart mechanism (`passenger_restart_with_touch = true`).

## 9. Rollback
- Rollback to previous release:
  - `bundle exec cap production deploy:rollback`

## 10. Records / Evidence (ISO)
- Deployment log (Capistrano output)
- Git commit hash deployed
- Post-deploy verification results
