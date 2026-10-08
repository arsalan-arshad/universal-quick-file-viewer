import { createElement } from 'lwc';
import UniversalQuickFileViewer from 'c/universalQuickFileViewer';
import { registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import getRecordFiles from '@salesforce/apex/FileViewerController.getRecordFiles';
import getBulkDownloadUrl from '@salesforce/apex/FileViewerController.getBulkDownloadUrl';

// Register Apex Wire Adapter
const getRecordFilesWireAdapter = registerApexTestWireAdapter(getRecordFiles);

// Mock getBulkDownloadUrl
jest.mock(
    '@salesforce/apex/FileViewerController.getBulkDownloadUrl',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

// Sample Mock Data
const MOCK_FILES = [
    {
        contentDocumentId: '069000000011111AAA',
        contentVersionId: '068000000011111AAA',
        title: 'Project Proposal',
        fileExtension: 'pdf',
        fileType: 'PDF',
        contentSize: 1048576,
        formattedSize: '1.0 MB',
        createdDate: '2026-10-01T12:00:00.000Z',
        createdByName: 'Test User',
        thumbnailUrl:
            '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=068000000011111AAA',
        downloadUrl: '/sfc/servlet.shepherd/version/download/068000000011111AAA',
        isImage: false,
        isPdf: true
    },
    {
        contentDocumentId: '069000000022222AAA',
        contentVersionId: '068000000022222AAA',
        title: 'Architecture Diagram',
        fileExtension: 'png',
        fileType: 'PNG',
        contentSize: 524288,
        formattedSize: '512.0 KB',
        createdDate: '2026-10-02T14:30:00.000Z',
        createdByName: 'Test User',
        thumbnailUrl: '/sfc/servlet.shepherd/version/download/068000000022222AAA',
        downloadUrl: '/sfc/servlet.shepherd/version/download/068000000022222AAA',
        isImage: true,
        isPdf: false
    }
];

describe('c-universal-quick-file-viewer', () => {
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    async function flushPromises() {
        return Promise.resolve();
    }

    it('renders empty state when no files are returned', async () => {
        const element = createElement('c-universal-quick-file-viewer', {
            is: UniversalQuickFileViewer
        });
        element.recordId = '001000000000000AAA';
        document.body.appendChild(element);

        // Emit empty data from wire
        getRecordFilesWireAdapter.emit([]);
        await flushPromises();

        const emptyHeading = element.shadowRoot.querySelector('h3');
        expect(emptyHeading).not.toBeNull();
        expect(emptyHeading.textContent).toBe('No files attached to this record');
    });

    it('renders grid cards when files are present', async () => {
        const element = createElement('c-universal-quick-file-viewer', {
            is: UniversalQuickFileViewer
        });
        element.recordId = '001000000000000AAA';
        document.body.appendChild(element);

        getRecordFilesWireAdapter.emit(MOCK_FILES);
        await flushPromises();

        const cards = element.shadowRoot.querySelectorAll('.file-card');
        expect(cards.length).toBe(2);

        const titles = element.shadowRoot.querySelectorAll('.file-title');
        expect(titles[0].textContent).toBe('Project Proposal');
        expect(titles[1].textContent).toBe('Architecture Diagram');
    });

    it('toggles view mode between Grid and List view', async () => {
        const element = createElement('c-universal-quick-file-viewer', {
            is: UniversalQuickFileViewer
        });
        element.recordId = '001000000000000AAA';
        document.body.appendChild(element);

        getRecordFilesWireAdapter.emit(MOCK_FILES);
        await flushPromises();

        expect(element.shadowRoot.querySelectorAll('.file-card').length).toBe(2);

        // Click toggle view mode icon
        const toggleBtn = element.shadowRoot.querySelector('lightning-button-icon[title*="List View"]');
        toggleBtn.click();
        await flushPromises();

        // Should now render table
        const table = element.shadowRoot.querySelector('.file-table');
        expect(table).not.toBeNull();
    });

    it('handles file selection and Select All', async () => {
        const element = createElement('c-universal-quick-file-viewer', {
            is: UniversalQuickFileViewer
        });
        element.recordId = '001000000000000AAA';
        document.body.appendChild(element);

        getRecordFilesWireAdapter.emit(MOCK_FILES);
        await flushPromises();

        // Select All button
        const selectAllBtn = element.shadowRoot.querySelector('lightning-button[data-action="select-all"]');
        expect(selectAllBtn).not.toBeNull();
        selectAllBtn.click();
        await flushPromises();

        // Bulk download button should now be rendered
        const bulkBtn = element.shadowRoot.querySelector('lightning-button[data-action="bulk-download"]');
        expect(bulkBtn).not.toBeNull();
        expect(bulkBtn.label).toBe('Download Selected (2)');
    });

    it('triggers bulk download with generated endpoint', async () => {
        window.open = jest.fn();
        getBulkDownloadUrl.mockResolvedValue('/sfc/servlet.shepherd/version/download/068000000011111AAA');

        const element = createElement('c-universal-quick-file-viewer', {
            is: UniversalQuickFileViewer
        });
        element.recordId = '001000000000000AAA';
        document.body.appendChild(element);

        getRecordFilesWireAdapter.emit(MOCK_FILES);
        await flushPromises();

        // Select All
        element.shadowRoot.querySelector('lightning-button[data-action="select-all"]').click();
        await flushPromises();

        // Click bulk download
        const bulkBtn = element.shadowRoot.querySelector('lightning-button[data-action="bulk-download"]');
        bulkBtn.click();
        await flushPromises();

        expect(getBulkDownloadUrl).toHaveBeenCalled();
    });

    it('opens and closes Lightbox modal', async () => {
        const element = createElement('c-universal-quick-file-viewer', {
            is: UniversalQuickFileViewer
        });
        element.recordId = '001000000000000AAA';
        document.body.appendChild(element);

        getRecordFilesWireAdapter.emit(MOCK_FILES);
        await flushPromises();

        // Click thumbnail container to open lightbox
        const thumb = element.shadowRoot.querySelector('.thumbnail-container');
        thumb.click();
        await flushPromises();

        const lightbox = element.shadowRoot.querySelector('.lightbox-modal');
        expect(lightbox).not.toBeNull();

        // Close lightbox
        const closeBtn = element.shadowRoot.querySelector('lightning-button-icon[title*="Close Preview"]');
        closeBtn.click();
        await flushPromises();

        expect(element.shadowRoot.querySelector('.lightbox-modal')).toBeNull();
    });

    it('navigates next and previous files in Lightbox', async () => {
        const element = createElement('c-universal-quick-file-viewer', {
            is: UniversalQuickFileViewer
        });
        element.recordId = '001000000000000AAA';
        document.body.appendChild(element);

        getRecordFilesWireAdapter.emit(MOCK_FILES);
        await flushPromises();

        // Open lightbox on first file
        element.shadowRoot.querySelector('.thumbnail-container').click();
        await flushPromises();

        let titleEl = element.shadowRoot.querySelector('.lightbox-title');
        expect(titleEl.textContent.trim()).toBe('Project Proposal');

        // Click next arrow
        const nextArrow = element.shadowRoot.querySelector('.nav-arrow-right');
        nextArrow.click();
        await flushPromises();

        titleEl = element.shadowRoot.querySelector('.lightbox-title');
        expect(titleEl.textContent.trim()).toBe('Architecture Diagram');
    });
});
