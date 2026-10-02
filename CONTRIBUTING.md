# Contributing to Universal Quick File Viewer

Thank you for contributing to Universal Quick File Viewer!

## Local Development Workflow
1. Authorize your Dev Hub:
   ```bash
   sf org login web -d -a my-dev-hub
   ```
2. Create a scratch org:
   ```bash
   sf org create scratch -f config/project-scratch-def.json -a viewer-dev -d 7
   ```
3. Deploy components:
   ```bash
   sf project deploy start
   ```
4. Run tests:
   ```bash
   sf apex run test -c -r human
   npm run test:unit
   ```

## PR Guidelines
- Ensure thumbnail rendering is lazy and optimized for records with 50+ files.
- Keyboard navigation (arrows, Escape) must be accessible.
- JSZip static resource must be updated cleanly if upgraded.
