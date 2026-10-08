# AppExchange Listing Dossier: Universal Quick File Viewer & Bulk Downloader

This document contains the complete listing metadata, marketing copy, technical disclosures, and Security Review readiness package to list **Universal Quick File Viewer & Bulk Downloader** on the Salesforce AppExchange.

---

## 1. Listing Metadata

| Field | Value | Constraints |
| :--- | :--- | :--- |
| **App Title** | `Universal Quick File Viewer & Bulk Downloader` | 46 / 80 chars |
| **Short Tagline** | `Instant High-Res Thumbnail Gallery, Lightbox Previewer & 1-Click Bulk ZIP Download for Records.` | 96 / 100 chars |
| **Listing Type** | App (Second-Generation Managed Package - 2GP) | Standard AppExchange |
| **Pricing Model** | **Free / 100% Open-Source** (MIT License) | Free |
| **Primary Category** | **Productivity & Document Management** | AppExchange Primary |
| **Secondary Categories** | **Admin Tools**, **Developer Tools**, **Sales & Service Utilities** | AppExchange Secondary |
| **Target Audience** | Salesforce Administrators, Sales Reps, Support Agents, Field Service | All Orgs |
| **Supported Editions** | Essentials, Professional, Enterprise, Unlimited, Developer | All editions with Lightning |
| **Package Version ID** | `04tg7000000WDi5AAG` (`v0.1.0.1`) | Released 2GP Package |
| **Source Repository** | [github.com/arsalan-arshad/universal-quick-file-viewer](https://github.com/arsalan-arshad/universal-quick-file-viewer) | Public MIT |

---

## 2. Marketing & Listing Copy

### 2.1 Short Description (Tile Card View - 250 characters)
> Instantly view high-resolution attachment thumbnails, sequentially flip through files in a full-screen lightbox, and download multiple files in a single compressed ZIP with one click. 100% native and Agentforce AI ready.

### 2.2 Full Description
```markdown
Empower your users with an instant, modern file preview and bulk downloading experience directly on record pages!

Standard Salesforce "Files" related lists on record pages are notoriously sluggish:
- Users must click into each individual attachment, wait for the standard modal to render, close it, and repeat for every file.
- Downloading multiple attachments requires opening files one-by-one or setting up heavy third-party archiving services.
- Standard related lists display generic gray icons without high-resolution thumbnail cards or responsive galleries.
- Autonomous Agentforce AI agents and Flow automations have no native way to inspect attached documents and generate conversational summaries.

Universal Quick File Viewer & Bulk Downloader replaces this with an enterprise-grade, 100% native Lightning Web Component and Apex suite that provides an instant visual gallery, full-screen lightbox previewer, 1-click bulk ZIP downloader, drag-and-drop uploader, and native Agentforce AI readiness.

### 🌟 Key Capabilities

1. 🖼️ Responsive High-Resolution Gallery:
   - Modern card grid displaying clean thumbnails for images, PDFs, Word, Excel, PowerPoint, and CSV files.
   - Badge overlays showing file extension, size in KB/MB, and creation timestamp.
   - Live search filter and category pills (All, Images, PDFs, Docs, Sheets) with dynamic file counts.

2. 🔍 Full-Screen Lightbox & Filmstrip Carousel:
   - Flip through all attachments sequentially without closing and reopening modals.
   - Keyboard navigation shortcuts (`Esc` to close, `←` / `→` arrow keys to flip).
   - Interactive bottom filmstrip thumbnail bar to jump directly to any document.

3. 📦 1-Click Native Bulk ZIP Download:
   - Select multiple files or click "Select All" to download a single compressed ZIP archive.
   - Uses Salesforce's native Shepherd streaming engine (zero heap limit, zero browser freeze).

4. 📂 Direct Drag-and-Drop Uploader:
   - Modern drag-and-drop zone directly within the component that links dropped files to the active record instantly.
   - Includes real-time upload progress indicators and auto-refreshing gallery.

5. 🤖 Native Agentforce AI & Flow Invocable Action:
   - Includes a first-class Invocable Action (`Get Record Files`) allowing autonomous AI agents to query record attachments, inspect file metadata, check file counts, and retrieve content versions conversationally.

### 🔒 Enterprise-Grade & 100% Safe:
- 100% Native Salesforce architecture (No external servers, no third-party APIs).
- Strict `with sharing` enforcement and user mode CRUD/FLS compliance.
- 92% Apex test coverage across positive, negative, and bulk scenarios.
- 100% Lightning Web Security (LWS) compliant.
```

### 2.3 Feature Bullet Points (AppExchange Highlights Tab)
- **Instant High-Res Thumbnails:** View clean image previews and color-coded doctype badges for all record files.
- **Full-Screen Lightbox:** Sequential filmstrip previewer with keyboard arrow navigation (`←` / `→`).
- **1-Click Bulk ZIP Download:** Multi-select files and download a single compressed archive natively.
- **Live Search & Category Filtering:** Instant search input and filter pills (`All`, `Images`, `PDFs`, `Docs`, `Sheets`).
- **Direct Drag-and-Drop Uploader:** Attach new files without navigating away from the record page.
- **Agentforce AI Ready:** Invocable Action provides conversational file summaries and inspection for AI agents.
- **Universal Object Support:** Works seamlessly on Opportunity, Account, Case, Contact, Lead, and any Custom Object.
- **100% Native & Free:** Fully open-source under the MIT License with zero recurring subscription fees.

---

## 3. Visual Assets Matrix

All visual assets have been crafted to exact Salesforce AppExchange specifications:

| Asset | File Name | Dimensions / Aspect Ratio | Purpose |
| :--- | :--- | :--- | :--- |
| **App Icon (Square)** | `assets/app_icon_120.png` | 120 x 120 px (PNG) | AppExchange tile icon & App Launcher |
| **App Banner (Hero)** | `assets/app_banner.jpg` | 16:9 ratio (1280 x 720 px) | Listing header banner & README |
| **Screenshot 1** | `assets/screenshot_1_responsive_grid.png` | 16:9 ratio (1280 x 720 px) | Responsive Thumbnail Grid Gallery |
| **Screenshot 2** | `assets/screenshot_2_fullscreen_lightbox.png` | 16:9 ratio (1280 x 720 px) | Full-screen Lightbox & Filmstrip Carousel |
| **Screenshot 3** | `assets/screenshot_3_bulk_zip_download.png` | 16:9 ratio (1280 x 720 px) | 1-Click Native Bulk ZIP Download Active |
| **Screenshot 4** | `assets/screenshot_4_drag_drop_uploader.png` | 16:9 ratio (1280 x 720 px) | Direct Drag-and-Drop Uploader & Agentforce |

---

## 4. AppExchange Security Review & Technical Assessment

### 4.1 Architecture & Security Attributes
- **External Endpoints & Callouts:** **None (0)**. The application makes zero HTTP callouts to external servers or web services.
- **Third-Party JavaScript Libraries:** **None (0)**. The gallery, lightbox, and bulk downloading use 100% native Salesforce Lightning Web Components and native platform servlets.
- **Lightning Web Security (LWS) Compatibility:** Fully compliant with Lightning Web Security and Locker Service.
- **Content Security Policy (CSP):** Zero CSP modifications required. Does not load external fonts, styles, scripts, or media files.
- **Data Storage & Privacy:** The application does **not** store, log, or transmit any Personally Identifiable Information (PII) or customer data. Standard Salesforce File storage and sharing models apply.
- **Sharing Model:** All Apex classes strictly enforce `with sharing`.
- **Field-Level Security (FLS) & CRUD:** Queries use `WITH USER_MODE` and `AccessLevel.USER_MODE` to strictly adhere to user permissions.

### 4.2 Security Review Questionnaire Answers

| Question | Official Response |
| :--- | :--- |
| **Does the package make outbound callouts to any external services?** | **No.** 100% of execution occurs natively inside the Salesforce Lightning runtime and Apex engine. |
| **Does the package store sensitive user data or credentials?** | **No.** No credentials, tokens, or PII are stored or processed. |
| **Are third-party scripts loaded via static resources or CDN?** | **No.** All components and features are built using native Salesforce platform APIs. |
| **Does the package contain Apex code?** | **Yes.** 3 Apex classes (`FileViewerService`, `FileViewerController`, `FileViewerInvocable`). |
| **What is the Apex code coverage?** | **92.00%** overall across all classes with 24 comprehensive unit tests covering bulk, positive, and negative paths. |
| **Does the package respect User Permissions?** | **Yes.** A dedicated Permission Set (`Universal_Quick_File_Viewer_User`) is included to grant granular access. |

---

## 5. Direct Package Installation Links

| Target Environment | Direct 1-Click Link |
| :--- | :--- |
| **Production / Developer Edition** | [👉 Install in Production / Dev Org (04tg7000000WDi5AAG)](https://login.salesforce.com/packaging/installPackage.apexp?p0=04tg7000000WDi5AAG) |
| **Sandbox Environment** | [👉 Install in Sandbox (04tg7000000WDi5AAG)](https://test.salesforce.com/packaging/installPackage.apexp?p0=04tg7000000WDi5AAG) |
| **Salesforce CLI** | `sf package install --package 04tg7000000WDi5AAG --wait 20 --target-org <YOUR_ORG_ALIAS>` |
