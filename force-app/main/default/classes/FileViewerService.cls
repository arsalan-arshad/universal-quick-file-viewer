/**
 * @description Enterprise Service Layer for Universal Quick File Viewer & Bulk Downloader.
 *              Handles ContentDocumentLink, ContentVersion, and ContentDocument querying,
 *              sanitization, formatting, and deletion with strict security enforcement.
 * @author Arsalan Arshad
 */
public with sharing class FileViewerService {
    /**
     * @description Data Transfer Object (DTO) representing a file item for Lightning Web Components.
     */
    public class FileItem {
        @AuraEnabled
        public Id contentDocumentId { get; set; }
        @AuraEnabled
        public Id contentVersionId { get; set; }
        @AuraEnabled
        public String title { get; set; }
        @AuraEnabled
        public String fileExtension { get; set; }
        @AuraEnabled
        public String fileType { get; set; }
        @AuraEnabled
        public Long contentSize { get; set; }
        @AuraEnabled
        public String formattedSize { get; set; }
        @AuraEnabled
        public Datetime createdDate { get; set; }
        @AuraEnabled
        public String createdByName { get; set; }
        @AuraEnabled
        public String thumbnailUrl { get; set; }
        @AuraEnabled
        public String downloadUrl { get; set; }
        @AuraEnabled
        public Boolean isImage { get; set; }
        @AuraEnabled
        public Boolean isPdf { get; set; }

        public FileItem() {
            this.isImage = false;
            this.isPdf = false;
        }
    }

    private static final Set<String> IMAGE_EXTENSIONS = new Set<String>{
        'jpg',
        'jpeg',
        'png',
        'gif',
        'svg',
        'webp',
        'bmp'
    };

    private static final Set<String> DOCUMENT_EXTENSIONS = new Set<String>{
        'doc',
        'docx',
        'odt',
        'rtf',
        'txt',
        'pages'
    };

    private static final Set<String> SPREADSHEET_EXTENSIONS = new Set<String>{ 'xls', 'xlsx', 'csv', 'ods', 'numbers' };

    private static final Set<String> PRESENTATION_EXTENSIONS = new Set<String>{ 'ppt', 'pptx', 'key', 'odp' };

    /**
     * @description Retrieves files attached to a specific record with optional search and category filters.
     * @param recordId The target record ID (Account, Case, Opportunity, Custom Object, etc.)
     * @param searchTerm Optional search string to filter files by title
     * @param categoryFilter Category pill filter: 'ALL', 'IMAGES', 'PDFS', 'DOCUMENTS', 'SPREADSHEETS'
     * @param queryLimit Maximum number of files to return (defaults to 100, max 200)
     * @return List<FileItem> Formatted DTO items
     */
    public static List<FileItem> getFilesForRecord(
        Id recordId,
        String searchTerm,
        String categoryFilter,
        Integer queryLimit
    ) {
        if (recordId == null) {
            return new List<FileItem>();
        }

        Integer safeLimit = (queryLimit == null || queryLimit <= 0 || queryLimit > 200) ? 100 : queryLimit;

        // 1. Fetch ContentDocumentLinks for the record
        List<ContentDocumentLink> links = [
            SELECT ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :recordId
            WITH USER_MODE
            LIMIT 500
        ];

        if (links.isEmpty()) {
            return new List<FileItem>();
        }

        Set<Id> docIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            if (link.ContentDocumentId != null) {
                docIds.add(link.ContentDocumentId);
            }
        }

        if (docIds.isEmpty()) {
            return new List<FileItem>();
        }

        // 2. Fetch Latest ContentVersions for the document IDs
        String query =
            'SELECT Id, ContentDocumentId, Title, FileExtension, FileType, ContentSize, ' +
            'CreatedDate, CreatedBy.Name ' +
            'FROM ContentVersion ' +
            'WHERE ContentDocumentId IN :docIds AND IsLatest = true ';

        if (String.isNotBlank(searchTerm)) {
            String sanitizedTerm = '%' + String.escapeSingleQuotes(searchTerm.trim()) + '%';
            query += 'AND Title LIKE :sanitizedTerm ';
        }

        query += 'ORDER BY CreatedDate DESC LIMIT :safeLimit';

        List<ContentVersion> versions = Database.query(query, AccessLevel.USER_MODE);
        List<FileItem> fileItems = new List<FileItem>();

        String normCategory = String.isBlank(categoryFilter) ? 'ALL' : categoryFilter.trim().toUpperCase();

        for (ContentVersion cv : versions) {
            String ext = String.isNotBlank(cv.FileExtension) ? cv.FileExtension.toLowerCase() : '';
            Boolean isImg = IMAGE_EXTENSIONS.contains(ext);
            Boolean isPdf = (ext == 'pdf');
            Boolean isDoc = DOCUMENT_EXTENSIONS.contains(ext);
            Boolean isSheet = SPREADSHEET_EXTENSIONS.contains(ext);

            // Filter category if specified
            if (normCategory == 'IMAGES' && !isImg) {
                continue;
            } else if (normCategory == 'PDFS' && !isPdf) {
                continue;
            } else if (normCategory == 'DOCUMENTS' && !isDoc) {
                continue;
            } else if (normCategory == 'SPREADSHEETS' && !isSheet) {
                continue;
            }

            FileItem item = new FileItem();
            item.contentDocumentId = cv.ContentDocumentId;
            item.contentVersionId = cv.Id;
            item.title = cv.Title;
            item.fileExtension = ext;
            item.fileType = cv.FileType;
            item.contentSize = cv.ContentSize;
            item.formattedSize = formatBytes(cv.ContentSize);
            item.createdDate = cv.CreatedDate;
            item.createdByName = cv.CreatedBy != null ? cv.CreatedBy.Name : '';
            item.isImage = isImg;
            item.isPdf = isPdf;

            // Thumbnail and download endpoints
            item.downloadUrl = '/sfc/servlet.shepherd/version/download/' + cv.Id;
            if (isImg) {
                // High-resolution rendition or direct download image URL
                item.thumbnailUrl = '/sfc/servlet.shepherd/version/download/' + cv.Id;
            } else {
                item.thumbnailUrl =
                    '/sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=' + cv.Id;
            }

            fileItems.add(item);
        }

        return fileItems;
    }

    /**
     * @description Generates a single bulk zip download URL for a list of ContentVersion IDs.
     *              Salesforce Shepherd servlet natively packages multiple version IDs into a ZIP file!
     * @param versionIds List of ContentVersion IDs to package
     * @return String URL endpoint to trigger the native ZIP download
     */
    public static String getBulkDownloadUrl(List<Id> versionIds) {
        if (versionIds == null || versionIds.isEmpty()) {
            return '';
        }
        String path = '/sfc/servlet.shepherd/version/download/';
        List<String> idStrings = new List<String>();
        for (Id vid : versionIds) {
            if (vid != null) {
                idStrings.add(String.valueOf(vid));
            }
        }
        if (idStrings.isEmpty()) {
            return '';
        }
        return path + String.join(idStrings, '/');
    }

    /**
     * @description Deletes a ContentDocument attachment.
     * @param contentDocumentId The ContentDocument ID to delete
     * @return Boolean True if deletion succeeded
     */
    public static Boolean deleteFile(Id contentDocumentId) {
        if (contentDocumentId == null) {
            throw new IllegalArgumentException('ContentDocumentId cannot be null');
        }

        List<ContentDocument> docs = [
            SELECT Id
            FROM ContentDocument
            WHERE Id = :contentDocumentId
            WITH USER_MODE
            LIMIT 1
        ];

        if (docs.isEmpty()) {
            throw new AuraHandledException('File not found or insufficient access permissions.');
        }

        try {
            Database.delete(docs, AccessLevel.USER_MODE);
            return true;
        } catch (Exception ex) {
            throw new AuraHandledException('Failed to delete file: ' + ex.getMessage());
        }
    }

    /**
     * @description Renames a file title.
     * @param contentDocumentId The ContentDocument ID to rename
     * @param newTitle The new file title
     * @return Boolean True if update succeeded
     */
    public static Boolean renameFile(Id contentDocumentId, String newTitle) {
        if (contentDocumentId == null || String.isBlank(newTitle)) {
            throw new IllegalArgumentException('Valid ContentDocumentId and new title are required.');
        }

        List<ContentDocument> docs = [
            SELECT Id, Title
            FROM ContentDocument
            WHERE Id = :contentDocumentId
            WITH USER_MODE
            LIMIT 1
        ];

        if (docs.isEmpty()) {
            throw new AuraHandledException('File not found or insufficient permissions.');
        }

        docs[0].Title = newTitle.trim();
        try {
            Database.update(docs, AccessLevel.USER_MODE);
            return true;
        } catch (Exception ex) {
            throw new AuraHandledException('Failed to rename file: ' + ex.getMessage());
        }
    }

    /**
     * @description Formats byte count into human-readable string (B, KB, MB, GB).
     * @param bytes File size in bytes
     * @return String Formatted file size string
     */
    public static String formatBytes(Long bytes) {
        if (bytes == null || bytes <= 0) {
            return '0 B';
        }
        if (bytes < 1024) {
            return bytes + ' B';
        }
        Decimal kb = Decimal.valueOf(bytes).divide(1024, 1, System.RoundingMode.HALF_UP);
        if (kb < 1024) {
            return kb.stripTrailingZeros().toPlainString() + ' KB';
        }
        Decimal mb = Decimal.valueOf(bytes).divide(1024 * 1024, 1, System.RoundingMode.HALF_UP);
        if (mb < 1024) {
            return mb.stripTrailingZeros().toPlainString() + ' MB';
        }
        Decimal gb = Decimal.valueOf(bytes).divide(1024L * 1024L * 1024L, 1, System.RoundingMode.HALF_UP);
        return gb.stripTrailingZeros().toPlainString() + ' GB';
    }
}
