# ISO 9001 (QMS) - Project Procedures

## 1. Scope
This document defines quality management procedures applied to the ERA Website System project.

## 2. Roles and Responsibilities
- **Product owner / requester**: [TO FILL]
- **Project manager**: [TO FILL]
- **Tech lead**: [TO FILL]
- **Developers**: [TO FILL]
- **QA / tester**: [TO FILL]
- **Approver for production release**: [TO FILL]

## 3. Document and Record Control
- Controlled documents are stored in the repository under `docs/iso/`.
- Changes are performed via pull requests.
- Evidence/records retained:
  - Requirements records (tickets/specs)
  - Design notes
  - Test results
  - Deployment logs
  - Incident reports

## 4. Requirements Management
- Requirements captured as:
  - user stories / change requests / tickets
- Each requirement is traced to:
  - implementation (commit/PR)
  - verification (test cases or acceptance checks)

## 5. Design and Development Control
- Architecture decisions recorded in `02-architecture-and-dataflow.md` and ADRs if used.
- Coding standards:
  - Backend: Ruby/Rails conventions
  - Frontend: TypeScript/React conventions and ESLint

## 6. Verification and Validation
- Backend: automated tests (`bin/rails test`)
- Frontend: linting (`npm run lint`) and build verification (`npm run build`)
- Acceptance checks:
  - smoke test key endpoints (news/events/projects/bids/vacancies)
  - verify downloads
  - verify admin login

## 7. Nonconformity and Corrective Action
- Defects are logged as issues/tickets.
- Root cause analysis performed for production defects when severity warrants.
- Corrective actions verified and closed.

## 8. Release Management
- Release notes maintained per deployment.
- Approval gates:
  - code review approval
  - test pass
  - production deploy approval

## 9. Continual Improvement
- Periodic review of incidents, defects, and user feedback.
- Maintain action items backlog.
