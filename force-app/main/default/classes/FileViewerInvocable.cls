/**
 * @description Invocable Action for Salesforce Flows and Agentforce AI Agents.
 *              Allows autonomous agents and flow orchestrations to inspect record attachments,
 *              retrieve file counts, sizes, names, and bulk download links.
 * @author Arsalan Arshad
 */
public with sharing class FileViewerInvocable {
    public class FileRequest {
        @InvocableVariable(label='Record ID' description='Target Record ID to inspect for files' required=true)
        public Id recordId;

        @InvocableVariable(
            label='Category Filter'
            description='Optional filter: ALL, IMAGES, PDFS, DOCUMENTS, SPREADSHEETS'
        )
        public String categoryFilter;

        @InvocableVariable(label='Search Term' description='Optional search string to filter files by name')
        public String searchTerm;

        @InvocableVariable(label='Max Files' description='Maximum files to return (defaults to 50)')
        public Integer maxFiles;
    }

    public class FileResult {
        @InvocableVariable(label='File Count' description='Number of files attached to the record')
        public Integer fileCount;

        @InvocableVariable(label='Has Files' description='True if record has one or more matching files')
        public Boolean hasFiles;

        @InvocableVariable(label='File Names CSV' description='Comma-separated list of file names')
        public String fileNamesCsv;

        @InvocableVariable(label='File Names' description='List of file titles')
        public List<String> fileNames;

        @InvocableVariable(label='Content Document IDs' description='List of ContentDocument IDs')
        public List<Id> contentDocumentIds;

        @InvocableVariable(label='Latest Version IDs' description='List of ContentVersion IDs')
        public List<Id> latestVersionIds;

        @InvocableVariable(label='Total Size (Bytes)' description='Total aggregate size in bytes')
        public Long totalSizeBytes;

        @InvocableVariable(label='Total Size (Formatted)' description='Human readable total size (e.g. 4.2 MB)')
        public String totalSizeFormatted;

        @InvocableVariable(label='Bulk Download URL' description='Single URL to download all matching files in a ZIP')
        public String bulkDownloadUrl;

        @InvocableVariable(label='AI Summary' description='Natural language summary for Agentforce AI conversations')
        public String summary;

        public FileResult() {
            this.fileCount = 0;
            this.hasFiles = false;
            this.fileNamesCsv = '';
            this.fileNames = new List<String>();
            this.contentDocumentIds = new List<Id>();
            this.latestVersionIds = new List<Id>();
            this.totalSizeBytes = 0;
            this.totalSizeFormatted = '0 B';
            this.bulkDownloadUrl = '';
            this.summary = 'No files found.';
        }
    }

    /**
     * @description Invocable action method for Flows and Agentforce AI.
     * @param requests List of FileRequest objects
     * @return List<FileResult>
     */
    @InvocableMethod(
        label='Get Record Files (Agentforce / Flow)'
        description='Inspects and returns files attached to a record for Agentforce AI and Flows'
        category='File Management'
    )
    public static List<FileResult> getFiles(List<FileRequest> requests) {
        List<FileResult> results = new List<FileResult>();
        if (requests == null || requests.isEmpty()) {
            return results;
        }

        for (FileRequest req : requests) {
            FileResult res = new FileResult();
            if (req == null || req.recordId == null) {
                res.summary = 'Invalid or missing record ID.';
                results.add(res);
                continue;
            }

            Integer safeLimit = (req.maxFiles != null && req.maxFiles > 0) ? req.maxFiles : 50;
            List<FileViewerService.FileItem> items = FileViewerService.getFilesForRecord(
                req.recordId,
                req.searchTerm,
                req.categoryFilter,
                safeLimit
            );

            if (!items.isEmpty()) {
                res.fileCount = items.size();
                res.hasFiles = true;

                List<String> names = new List<String>();
                List<Id> docIds = new List<Id>();
                List<Id> vIds = new List<Id>();
                Long totalBytes = 0;

                for (FileViewerService.FileItem item : items) {
                    names.add(item.title);
                    docIds.add(item.contentDocumentId);
                    vIds.add(item.contentVersionId);
                    if (item.contentSize != null) {
                        totalBytes += item.contentSize;
                    }
                }

                res.fileNames = names;
                res.fileNamesCsv = String.join(names, ', ');
                res.contentDocumentIds = docIds;
                res.latestVersionIds = vIds;
                res.totalSizeBytes = totalBytes;
                res.totalSizeFormatted = FileViewerService.formatBytes(totalBytes);
                res.bulkDownloadUrl = FileViewerService.getBulkDownloadUrl(vIds);

                // Conversational natural language summary for Agentforce
                res.summary =
                    'Found ' +
                    res.fileCount +
                    ' file(s) (' +
                    res.totalSizeFormatted +
                    ' total): ' +
                    (names.size() > 5
                        ? String.join(sliceList(names, 5), ', ') + ' and ' + (names.size() - 5) + ' more'
                        : res.fileNamesCsv) +
                    '.';
            }

            results.add(res);
        }

        return results;
    }

    private static List<String> sliceList(List<String> listItems, Integer count) {
        List<String> sliced = new List<String>();
        for (Integer i = 0; i < Math.min(count, listItems.size()); i++) {
            sliced.add(listItems[i]);
        }
        return sliced;
    }
}
