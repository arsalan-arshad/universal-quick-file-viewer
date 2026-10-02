# Universal Quick File Viewer & Bulk Downloader

> **Open-Source (MIT)** | Built for the Trailblazer & Salesforce Developer Community | Open for PRs & Discussions

## 1. Overview & Vision
Standard Salesforce "Files" related lists on record pages are sluggish and inefficient:
- Users have to click into a file, wait for the preview modal to render, close it, and repeat for every single attachment.
- Downloading multiple files requires opening each file individually or building complex zip logic.
- File previews don't show high-resolution thumbnails in a modern grid or filmstrip.

**Universal Quick File Viewer** is an open-source LWC component that can be dropped onto any Record Page (Account, Case, Opportunity, Custom Object) to provide an instant gallery, full-screen lightbox previewer, and 1-click bulk download.

## 2. Core Features (MVP)
- **Instant Visual Gallery / Grid:**
  - Responsive grid layout displaying clear file thumbnails (PDFs, PNG, JPG, Word, Excel).
  - Badge overlays showing file extension and file size.
- **Lightbox / Filmstrip Modal:**
  - Arrow navigation to flip through all record attachments without closing and reopening modals.
  - Keyboard shortcuts (`Esc` to close, `Left`/`Right` arrow keys to navigate).
- **1-Click Bulk Zip / Download:**
  - Checkboxes to select multiple files $\rightarrow$ downloads all selected files in one action.
- **Drag-and-Drop Uploader:**
  - Modern drag-and-drop zone directly inside the component that links files to the current record instantly.

## 3. Architecture & Tech Stack
- **Frontend:** Lightning Web Components (LWC), JSZip library (static resource for client-side zipping).
- **Backend:** Apex (`FileViewerController.cls`) querying `ContentDocumentLink`, `ContentVersion`, and `ContentDocument`.
- **Packaging:** Unlocked / Managed 2GP Package with App Builder configuration options (customizable title, columns, allowed extensions).

## 4. AppExchange & Community Strategy
- **Audience:** Customer Support (Cases), Sales reps (Proposals/NDAs), Field Service, Real Estate / Legal Salesforce users.
- **Value Proposition:** Replaces 5+ clicks with 1 hover/click. Massive daily time saver.

## 5. Open-Source Roadmap & Good First Issues for PRs
- [ ] Multi-page PDF inline flipper directly in the thumbnail card.
- [ ] Tagging and categorizing files by custom tags.
- [ ] Video/Audio media playback inside the lightbox.
- [ ] Bulk file renaming utility modal.
