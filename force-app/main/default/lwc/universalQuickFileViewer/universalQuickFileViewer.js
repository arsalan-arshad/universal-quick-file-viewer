import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import getRecordFiles from '@salesforce/apex/FileViewerController.getRecordFiles';
import getBulkDownloadUrl from '@salesforce/apex/FileViewerController.getBulkDownloadUrl';
import deleteFile from '@salesforce/apex/FileViewerController.deleteFile';
import renameFile from '@salesforce/apex/FileViewerController.renameFile';

export default class UniversalQuickFileViewer extends NavigationMixin(LightningElement) {
    @api recordId;
    @api title = 'Files & Attachments';
    @api cardLayout = 'Grid';
    @api defaultFilter = 'ALL';
    _enableBulkDownload = true;
    @api
    get enableBulkDownload() {
        return this._enableBulkDownload;
    }
    set enableBulkDownload(val) {
        this._enableBulkDownload = val !== 'false' && Boolean(val);
    }

    _enableUploader = true;
    @api
    get enableUploader() {
        return this._enableUploader;
    }
    set enableUploader(val) {
        this._enableUploader = val !== 'false' && Boolean(val);
    }

    @track searchTerm = '';
    @track selectedCategory = 'ALL';
    @track currentViewMode = 'Grid'; // 'Grid' or 'List'
    @track rawFiles = [];
    @track selectedFileIds = new Set();

    isLoading = false;
    wiredFilesResult;

    // Lightbox state
    isLightboxOpen = false;
    activeFileIndex = 0;

    // Modals
    isUploaderModalOpen = false;
    isRenameModalOpen = false;
    fileToRenameId = null;
    newFileTitle = '';

    isDeleteModalOpen = false;
    fileToDeleteId = null;
    fileToDeleteTitle = '';

    // Bound keyboard handler
    boundKeyHandler;

    connectedCallback() {
        if (this.defaultFilter) {
            this.selectedCategory = this.defaultFilter.toUpperCase();
        }
        if (this.cardLayout) {
            this.currentViewMode = this.cardLayout;
        }
        this.boundKeyHandler = this.handleKeyDown.bind(this);
    }

    disconnectedCallback() {
        window.removeEventListener('keydown', this.boundKeyHandler);
    }

    @wire(getRecordFiles, {
        recordId: '$recordId',
        searchTerm: '$searchTerm',
        categoryFilter: '$selectedCategory',
        queryLimit: 100
    })
    wiredFiles(result) {
        this.wiredFilesResult = result;
        const { data, error } = result;
        if (data) {
            this.rawFiles = data;
            // Clean up any selected IDs that no longer exist
            const existingDocIds = new Set(data.map((f) => f.contentDocumentId));
            const updatedSelection = new Set();
            this.selectedFileIds.forEach((id) => {
                if (existingDocIds.has(id)) {
                    updatedSelection.add(id);
                }
            });
            this.selectedFileIds = updatedSelection;
            this.isLoading = false;
        } else if (error) {
            this.rawFiles = [];
            this.isLoading = false;
            this.showToast('Error Loading Files', error.body ? error.body.message : error.message, 'error');
        }
    }

    get componentTitle() {
        return this.title || 'Files & Attachments';
    }

    get fileCountLabel() {
        return `${this.rawFiles.length}`;
    }

    get viewModeIcon() {
        return this.currentViewMode === 'Grid' ? 'utility:list' : 'utility:tile_card';
    }

    get viewModeAlternativeText() {
        return this.currentViewMode === 'Grid' ? 'Switch to List View' : 'Switch to Grid View';
    }

    get isGridLayout() {
        return this.currentViewMode === 'Grid' && this.hasFilteredFiles;
    }

    get isListLayout() {
        return this.currentViewMode === 'List' && this.hasFilteredFiles;
    }

    get hasFilteredFiles() {
        return this.filteredFiles.length > 0;
    }

    get isEmptyState() {
        return !this.isLoading && this.filteredFiles.length === 0;
    }

    get emptyStateTitle() {
        if (this.searchTerm) {
            return 'No matching files found';
        }
        return 'No files attached to this record';
    }

    get emptyStateSubtitle() {
        if (this.searchTerm) {
            return `Try clearing your search term "${this.searchTerm}".`;
        }
        return 'Upload or drop files here to preview them instantly in this gallery.';
    }

    get categoryTabs() {
        const counts = {
            ALL: 0,
            IMAGES: 0,
            PDFS: 0,
            DOCUMENTS: 0,
            SPREADSHEETS: 0
        };

        this.rawFiles.forEach((f) => {
            counts.ALL += 1;
            const ext = (f.fileExtension || '').toLowerCase();
            if (f.isImage) {
                counts.IMAGES += 1;
            } else if (f.isPdf) {
                counts.PDFS += 1;
            } else if (['doc', 'docx', 'odt', 'rtf', 'txt', 'pages'].includes(ext)) {
                counts.DOCUMENTS += 1;
            } else if (['xls', 'xlsx', 'csv', 'ods', 'numbers'].includes(ext)) {
                counts.SPREADSHEETS += 1;
            }
        });

        const tabs = [
            { key: 'ALL', label: 'All', count: counts.ALL },
            { key: 'IMAGES', label: 'Images', count: counts.IMAGES },
            { key: 'PDFS', label: 'PDFs', count: counts.PDFS },
            { key: 'DOCUMENTS', label: 'Docs', count: counts.DOCUMENTS },
            { key: 'SPREADSHEETS', label: 'Sheets', count: counts.SPREADSHEETS }
        ];

        return tabs.map((t) => {
            const isSelected = this.selectedCategory === t.key;
            return {
                ...t,
                buttonClass: `category-pill ${isSelected ? 'active' : ''}`
            };
        });
    }

    get filteredFiles() {
        return this.rawFiles.map((file, index) => {
            const isSelected = this.selectedFileIds.has(file.contentDocumentId);
            const ext = (file.fileExtension || '').toUpperCase();
            let sldsIcon = 'doctype:unknown';

            if (file.isImage) {
                sldsIcon = 'doctype:image';
            } else if (file.isPdf) {
                sldsIcon = 'doctype:pdf';
            } else if (['XLS', 'XLSX', 'CSV'].includes(ext)) {
                sldsIcon = 'doctype:excel';
            } else if (['DOC', 'DOCX', 'TXT'].includes(ext)) {
                sldsIcon = 'doctype:word';
            } else if (['PPT', 'PPTX', 'KEY'].includes(ext)) {
                sldsIcon = 'doctype:ppt';
            } else if (['ZIP', 'TAR', 'GZ', 'RAR'].includes(ext)) {
                sldsIcon = 'doctype:zip';
            }

            const formattedDate = file.createdDate
                ? new Date(file.createdDate).toLocaleDateString(undefined, {
                      month: 'short',
                      day: 'numeric',
                      year: 'numeric'
                  })
                : '';

            return {
                ...file,
                index,
                isSelected,
                displayExtension: ext || 'FILE',
                sldsIcon,
                formattedDate,
                cardClass: `file-card ${isSelected ? 'selected' : ''}`,
                rowClass: isSelected ? 'slds-is-selected' : '',
                filmstripClass: `filmstrip-thumb ${index === this.activeFileIndex ? 'active' : ''}`
            };
        });
    }

    get hasSelectedFiles() {
        return this.selectedFileIds.size > 0;
    }

    get isAllSelected() {
        return this.filteredFiles.length > 0 && this.selectedFileIds.size === this.filteredFiles.length;
    }

    get bulkDownloadButtonLabel() {
        return `Download Selected (${this.selectedFileIds.size})`;
    }

    get activeFile() {
        if (!this.filteredFiles || this.filteredFiles.length === 0) {
            return {};
        }
        const index = Math.max(0, Math.min(this.activeFileIndex, this.filteredFiles.length - 1));
        return this.filteredFiles[index] || {};
    }

    get activeFileIndexHuman() {
        return this.activeFileIndex + 1;
    }

    get totalFilesCount() {
        return this.filteredFiles.length;
    }

    // View & Search Event Handlers
    toggleViewMode() {
        this.currentViewMode = this.currentViewMode === 'Grid' ? 'List' : 'Grid';
    }

    handleSearchChange(event) {
        this.searchTerm = event.target.value;
    }

    handleCategorySelect(event) {
        const cat = event.currentTarget.dataset.key;
        if (cat) {
            this.selectedCategory = cat;
            this.selectedFileIds = new Set();
        }
    }

    handleRefresh() {
        this.isLoading = true;
        refreshApex(this.wiredFilesResult)
            .then(() => {
                this.isLoading = false;
            })
            .catch((err) => {
                this.isLoading = false;
                this.showToast('Refresh Error', err.body ? err.body.message : err.message, 'error');
            });
    }

    // Selection Handlers
    handleFileCheckboxToggle(event) {
        const docId = event.target.dataset.id;
        const newSet = new Set(this.selectedFileIds);
        if (event.target.checked) {
            newSet.add(docId);
        } else {
            newSet.delete(docId);
        }
        this.selectedFileIds = newSet;
    }

    handleSelectAll() {
        const newSet = new Set();
        this.filteredFiles.forEach((f) => newSet.add(f.contentDocumentId));
        this.selectedFileIds = newSet;
    }

    handleClearSelection() {
        this.selectedFileIds = new Set();
    }

    handleMasterCheckboxToggle(event) {
        if (event.target.checked) {
            this.handleSelectAll();
        } else {
            this.handleClearSelection();
        }
    }

    // Lightbox Controls
    handleOpenLightbox(event) {
        const docId = event.currentTarget.dataset.id;
        const foundIndex = this.filteredFiles.findIndex((f) => f.contentDocumentId === docId);
        this.activeFileIndex = foundIndex >= 0 ? foundIndex : 0;
        this.isLightboxOpen = true;
        window.addEventListener('keydown', this.boundKeyHandler);
    }

    handleCloseLightbox() {
        this.isLightboxOpen = false;
        window.removeEventListener('keydown', this.boundKeyHandler);
    }

    handlePrevFile() {
        if (this.activeFileIndex > 0) {
            this.activeFileIndex -= 1;
        } else {
            this.activeFileIndex = this.filteredFiles.length - 1; // loop around
        }
    }

    handleNextFile() {
        if (this.activeFileIndex < this.filteredFiles.length - 1) {
            this.activeFileIndex += 1;
        } else {
            this.activeFileIndex = 0; // loop around
        }
    }

    handleFilmstripSelect(event) {
        const docId = event.currentTarget.dataset.id;
        const foundIndex = this.filteredFiles.findIndex((f) => f.contentDocumentId === docId);
        if (foundIndex >= 0) {
            this.activeFileIndex = foundIndex;
        }
    }

    handleKeyDown(event) {
        if (!this.isLightboxOpen) return;
        if (event.key === 'Escape') {
            this.handleCloseLightbox();
        } else if (event.key === 'ArrowLeft') {
            this.handlePrevFile();
        } else if (event.key === 'ArrowRight') {
            this.handleNextFile();
        }
    }

    handleOpenInSalesforce() {
        const file = this.activeFile;
        if (file && file.contentDocumentId) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: file.contentDocumentId,
                    objectApiName: 'ContentDocument',
                    actionName: 'view'
                }
            });
        }
    }

    // Download Actions
    handleSingleDownload(event) {
        const downloadUrl = event.currentTarget.dataset.url;
        if (downloadUrl) {
            window.open(downloadUrl, '_blank');
        }
    }

    async handleBulkDownload() {
        if (this.selectedFileIds.size === 0) return;

        const selectedVersions = [];
        this.rawFiles.forEach((f) => {
            if (this.selectedFileIds.has(f.contentDocumentId)) {
                selectedVersions.push(f.contentVersionId);
            }
        });

        if (selectedVersions.length === 0) return;

        this.isLoading = true;
        try {
            const bulkUrl = await getBulkDownloadUrl({ versionIds: selectedVersions });
            this.isLoading = false;
            if (bulkUrl) {
                window.open(bulkUrl, '_blank');
                this.showToast(
                    'Bulk Download Started',
                    `Downloading ${selectedVersions.length} file(s) in a ZIP archive.`,
                    'success'
                );
            }
        } catch (error) {
            this.isLoading = false;
            this.showToast('Download Failed', error.body ? error.body.message : error.message, 'error');
        }
    }

    // Upload Handlers
    toggleUploaderModal() {
        this.isUploaderModalOpen = !this.isUploaderModalOpen;
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files || [];
        this.isUploaderModalOpen = false;
        this.showToast(
            'Upload Complete',
            `Successfully uploaded ${uploadedFiles.length} file(s) to this record.`,
            'success'
        );
        this.handleRefresh();
    }

    // Card Menu Actions
    handleCardMenuSelect(event) {
        const action = event.detail.value;
        const docId = event.currentTarget.dataset.id;
        const title = event.currentTarget.dataset.title;

        if (action === 'rename') {
            this.fileToRenameId = docId;
            this.newFileTitle = title;
            this.isRenameModalOpen = true;
        } else if (action === 'delete') {
            this.fileToDeleteId = docId;
            this.fileToDeleteTitle = title;
            this.isDeleteModalOpen = true;
        } else if (action === 'openRecord') {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: docId,
                    objectApiName: 'ContentDocument',
                    actionName: 'view'
                }
            });
        }
    }

    // Rename Modal
    handleNewTitleChange(event) {
        this.newFileTitle = event.target.value;
    }

    handleCloseRenameModal() {
        this.isRenameModalOpen = false;
        this.fileToRenameId = null;
        this.newFileTitle = '';
    }

    async handleSaveFileRename() {
        if (!this.fileToRenameId || !this.newFileTitle.trim()) {
            this.showToast('Validation Error', 'File title cannot be empty.', 'warning');
            return;
        }

        this.isLoading = true;
        try {
            await renameFile({ contentDocumentId: this.fileToRenameId, newTitle: this.newFileTitle.trim() });
            this.isLoading = false;
            this.isRenameModalOpen = false;
            this.showToast('Success', 'File title updated successfully.', 'success');
            this.handleRefresh();
        } catch (error) {
            this.isLoading = false;
            this.showToast('Rename Failed', error.body ? error.body.message : error.message, 'error');
        }
    }

    // Delete Modal
    handleCloseDeleteModal() {
        this.isDeleteModalOpen = false;
        this.fileToDeleteId = null;
        this.fileToDeleteTitle = '';
    }

    async handleConfirmDelete() {
        if (!this.fileToDeleteId) return;

        this.isLoading = true;
        try {
            await deleteFile({ contentDocumentId: this.fileToDeleteId });
            this.isLoading = false;
            this.isDeleteModalOpen = false;
            this.showToast('File Deleted', `Deleted "${this.fileToDeleteTitle}" successfully.`, 'success');
            this.handleRefresh();
        } catch (error) {
            this.isLoading = false;
            this.showToast('Delete Failed', error.body ? error.body.message : error.message, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
