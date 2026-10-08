/**
 * @description Lightning Web Component Controller for Universal Quick File Viewer & Bulk Downloader.
 *              Exposes AuraEnabled endpoints for wire adapters and imperative UI actions.
 * @author Arsalan Arshad
 */
public with sharing class FileViewerController {
    /**
     * @description Fetches all files attached to a record for display in the LWC gallery.
     * @param recordId The target record ID
     * @param searchTerm Optional search term to filter by file title
     * @param categoryFilter Category pill filter ('ALL', 'IMAGES', 'PDFS', 'DOCUMENTS', 'SPREADSHEETS')
     * @param queryLimit Maximum number of files to return
     * @return List<FileViewerService.FileItem>
     */
    @AuraEnabled(cacheable=true)
    public static List<FileViewerService.FileItem> getRecordFiles(
        Id recordId,
        String searchTerm,
        String categoryFilter,
        Integer queryLimit
    ) {
        try {
            return FileViewerService.getFilesForRecord(recordId, searchTerm, categoryFilter, queryLimit);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Generates the native bulk ZIP download URL for selected ContentVersion IDs.
     * @param versionIds List of ContentVersion IDs
     * @return String URL for downloading the packaged ZIP
     */
    @AuraEnabled(cacheable=true)
    public static String getBulkDownloadUrl(List<Id> versionIds) {
        try {
            return FileViewerService.getBulkDownloadUrl(versionIds);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Deletes an attachment by ContentDocument ID.
     * @param contentDocumentId The ContentDocument ID to delete
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean deleteFile(Id contentDocumentId) {
        try {
            return FileViewerService.deleteFile(contentDocumentId);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Renames an attachment by ContentDocument ID.
     * @param contentDocumentId The ContentDocument ID
     * @param newTitle The new file title
     * @return Boolean
     */
    @AuraEnabled
    public static Boolean renameFile(Id contentDocumentId, String newTitle) {
        try {
            return FileViewerService.renameFile(contentDocumentId, newTitle);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
}
