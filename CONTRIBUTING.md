# Contributing to Universal Quick File Viewer & Bulk Downloader

Thank you for contributing to the **Universal Quick File Viewer & Bulk Downloader** project! We welcome contributions from developers, architects, admins, and UI/UX designers to help keep this utility robust, fast, and enterprise-grade.

---

## 🛠️ Local Development & Setup

### 1. Prerequisites
- [Salesforce CLI (`sf`)](https://developer.salesforce.com/tools/salesforce-cli) installed.
- [Node.js](https://nodejs.org/) (v20+ recommended).
- A free [Salesforce Developer Edition Org](https://developer.salesforce.com/signup) or Dev Hub.

### 2. Development Workflow
1. Authorize your Dev Hub:
   ```bash
   sf org login web -d -a my-dev-hub
   ```
2. Create a scratch org (or use an authorized developer org):
   ```bash
   sf org create scratch -f config/project-scratch-def.json -a viewer-dev -d 7
   ```
3. Deploy components:
   ```bash
   sf project deploy start
   ```
4. Assign the permission set:
   ```bash
   sf org assign permset -n Universal_Quick_File_Viewer_User
   ```
5. Run tests locally:
   ```bash
   # Run Apex Unit Tests & Check Coverage
   sf apex run test --class-names FileViewerServiceTest FileViewerControllerTest FileViewerInvocableTest --code-coverage --result-format human

   # Run LWC Jest Unit Tests
   npm run test:unit
   ```

---

## 📋 Pull Request (PR) & Coding Guidelines

1. **Keep PRs Focused:** Submit one bug fix, optimization, or feature per PR.
2. **Apex Standards:**
   - Strict `with sharing` enforcement on all classes.
   - Enforce user mode CRUD/FLS (`WITH USER_MODE` / `AccessLevel.USER_MODE`).
   - Bulk-safe architecture (zero SOQL/DML queries inside loops).
   - Target $\ge 85\%$ Apex code coverage with positive, negative, and bulk assert statements.
3. **LWC & UI Standards:**
   - Strict adherence to the Salesforce Lightning Design System (SLDS).
   - Fully keyboard-accessible navigation (Esc, Arrow keys for lightbox).
   - Responsive design across desktop and mobile screens.
   - 100% native platform zero-dependency architecture (Salesforce native Shepherd streaming endpoints for bulk downloads; no external JS dependencies).
4. **Code Quality & Format Verification:**
   Before committing, always run:
   ```bash
   npm run lint
   npm run prettier:check
   npm run test:unit
   ```
5. **Issue Linking:** Reference any related issues or discussions in your PR description.

---

## 🤝 Community & Security
- Please adhere to our [Code of Conduct](.github/CODE_OF_CONDUCT.md) in all discussions and reviews.
- For security vulnerabilities, please refer to our [Security Policy](.github/SECURITY.md) for responsible disclosure.
