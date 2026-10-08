# Universal Quick File Viewer & Bulk Downloader

> **Open-Source (MIT)** | Built for the Trailblazer & Salesforce Developer Community | Part of the Salesforce Open-Source Ecosystem Portfolio

---

## 1. Overview & Vision
Standard Salesforce "Files" related lists on record pages are sluggish and inefficient:
- Users must click into every individual file, wait for the standard modal to render, close it, and repeat for each attachment.
- Downloading multiple files requires opening each file one by one or constructing complex custom zip flows.
- Standard file previews don't show high-resolution thumbnails in a modern responsive gallery.

**Universal Quick File Viewer** is an open-source LWC component that can be dropped onto any standard or custom Record Page (Account, Case, Opportunity, Work Order, Custom Object) to provide an instant gallery, full-screen lightbox previewer, and 1-click bulk download.

---

## 2. Killer Differentiators & Features
- 🖼️ **Instant Visual Gallery / Grid:**
  - Modern responsive card layout displaying clean thumbnails (PDFs, PNG, JPG, Word, Excel, CSV).
  - Badge overlays showing file extension, version size, and creation timestamp.
- 🔍 **Full-Screen Lightbox / Filmstrip Modal:**
  - Flip through all attachments sequentially without closing and reopening modals.
  - Keyboard navigation shortcuts (`Esc` to close, `←` / `→` arrow keys to flip).
- 📦 **1-Click Bulk Zip & Download:**
  - Multi-select checkboxes $\rightarrow$ downloads all selected files as a single clean `.zip` archive via client-side JSZip.
- 📂 **Direct Drag-and-Drop Uploader:**
  - Native upload zone within the component that automatically links dropped files to the active record.
- 🤖 **Agentforce & Flow AI Ready:**
  - Invocable action enabling autonomous AI agents to query record attachments, inspect file metadata, and retrieve content versions conversationally.

---

## 3. Standardized 4-Phase Delivery Roadmap

### 📋 Phase 1: Local Development & Differentiators
- [ ] Apex Service Layer (`FileViewerController.cls`) querying `ContentDocumentLink`, `ContentVersion`, and `ContentDocument` with `Security.stripInaccessible`.
- [ ] LWC Component Suite (`universalQuickFileViewer`, `fileCard`, `fileLightbox`, `fileUploader`).
- [ ] Client-side JSZip static resource integration for instant multi-file zipping.
- [ ] $\ge 85\%$ Apex unit test coverage (`FileViewerControllerTest.cls`) and Jest test suite.

### 📋 Phase 2: GitHub & Open-Source Engineering
- [ ] Git repository initialized: `github.com/arsalan-arshad/universal-quick-file-viewer`.
- [ ] Automated GitHub Actions CI workflow (`.github/workflows/ci.yml`) for linting, PMD, and automated testing.
- [ ] Automated CD workflow (`.github/workflows/cd.yml`) for continuous deployment on merge.
- [ ] Protected `main` branch ruleset requiring passing checks.

### 📋 Phase 3: 2GP Packaging & Distribution
- [ ] Second-Generation (2GP) Unlocked Package created: `UniversalQuickFileViewer`.
- [ ] Package version built and validated against code coverage requirements.
- [ ] Promoted to **`Released`** status.
- [ ] Direct 1-Click Install URLs generated for Production and Sandbox.

### 📋 Phase 4: Branding & AppExchange Readiness
- [ ] 7 Visual Assets: App Icon (120x120), Hero Banner (16:9), and 4 UI walkthrough screenshots.
- [ ] Production-grade `README.md` with demo carousels and Trailblazer setup instructions.
- [ ] Complete `APPEXCHANGE_LISTING.md` submission dossier (titles, taglines, security questionnaire).
