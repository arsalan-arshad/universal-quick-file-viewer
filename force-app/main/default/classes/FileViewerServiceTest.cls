/**
 * @description Comprehensive unit tests for FileViewerService.
 *              Validates querying, filtering, formatting, renaming, and deleting files.
 * @author Arsalan Arshad
 */
@IsTest
private class FileViewerServiceTest {
    @TestSetup
    static void setupTestData() {
        Account testAcc = new Account(Name = 'File Viewer Test Account');
        insert testAcc;

        // Create ContentVersions
        List<ContentVersion> versions = new List<ContentVersion>{
            new ContentVersion(
                Title = 'Contract Agreement',
                PathOnClient = 'Contract.pdf',
                VersionData = Blob.valueOf('Sample PDF Content')
            ),
            new ContentVersion(
                Title = 'Company Logo',
                PathOnClient = 'Logo.png',
                VersionData = Blob.valueOf('Sample PNG Content')
            ),
            new ContentVersion(
                Title = 'Financial Model',
                PathOnClient = 'Financials.xlsx',
                VersionData = Blob.valueOf('Sample XLSX Content')
            ),
            new ContentVersion(
                Title = 'Meeting Notes',
                PathOnClient = 'Notes.docx',
                VersionData = Blob.valueOf('Sample DOCX Content')
            )
        };
        insert versions;

        // Query ContentDocumentId for each version and link to Account
        List<ContentVersion> insertedVersions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :versions
        ];

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentVersion cv : insertedVersions) {
            links.add(
                new ContentDocumentLink(
                    LinkedEntityId = testAcc.Id,
                    ContentDocumentId = cv.ContentDocumentId,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                )
            );
        }
        insert links;
    }

    @IsTest
    static void testGetFilesForRecordAll() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<FileViewerService.FileItem> items = FileViewerService.getFilesForRecord(acc.Id, null, 'ALL', 50);
        Test.stopTest();

        Assert.areEqual(4, items.size(), 'Should return all 4 attached files');
        Assert.isNotNull(items[0].thumbnailUrl, 'Thumbnail URL must be populated');
        Assert.isNotNull(items[0].downloadUrl, 'Download URL must be populated');
    }

    @IsTest
    static void testGetFilesWithSearchTerm() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<FileViewerService.FileItem> items = FileViewerService.getFilesForRecord(acc.Id, 'Contract', 'ALL', 50);
        Test.stopTest();

        Assert.areEqual(1, items.size(), 'Should find exactly 1 file matching Contract');
        Assert.areEqual('Contract Agreement', items[0].title, 'Title should match');
        Assert.isTrue(items[0].isPdf, 'File should be identified as PDF');
    }

    @IsTest
    static void testGetFilesCategoryFiltering() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<FileViewerService.FileItem> images = FileViewerService.getFilesForRecord(acc.Id, null, 'IMAGES', 50);
        List<FileViewerService.FileItem> pdfs = FileViewerService.getFilesForRecord(acc.Id, null, 'PDFS', 50);
        List<FileViewerService.FileItem> docs = FileViewerService.getFilesForRecord(acc.Id, null, 'DOCUMENTS', 50);
        List<FileViewerService.FileItem> sheets = FileViewerService.getFilesForRecord(acc.Id, null, 'SPREADSHEETS', 50);
        Test.stopTest();

        Assert.areEqual(1, images.size(), 'Should find 1 image');
        Assert.isTrue(images[0].isImage, 'Should be flagged as image');
        Assert.areEqual(1, pdfs.size(), 'Should find 1 PDF');
        Assert.areEqual(1, docs.size(), 'Should find 1 Document');
        Assert.areEqual(1, sheets.size(), 'Should find 1 Spreadsheet');
    }

    @IsTest
    static void testGetFilesNullRecordId() {
        Test.startTest();
        List<FileViewerService.FileItem> items = FileViewerService.getFilesForRecord(null, null, 'ALL', 10);
        Test.stopTest();

        Assert.areEqual(0, items.size(), 'Null recordId should return empty list');
    }

    @IsTest
    static void testGetFilesNoAttachments() {
        Account emptyAcc = new Account(Name = 'Empty Account');
        insert emptyAcc;

        Test.startTest();
        List<FileViewerService.FileItem> items = FileViewerService.getFilesForRecord(emptyAcc.Id, null, 'ALL', 10);
        Test.stopTest();

        Assert.areEqual(0, items.size(), 'Record without files should return empty list');
    }

    @IsTest
    static void testFormatBytes() {
        Test.startTest();
        String zero = FileViewerService.formatBytes(0);
        String small = FileViewerService.formatBytes(512);
        String kb = FileViewerService.formatBytes(2048);
        String fractionalKb = FileViewerService.formatBytes(2560);
        String mb = FileViewerService.formatBytes(5242880);
        String gb = FileViewerService.formatBytes(2147483648L);
        String nullBytes = FileViewerService.formatBytes(null);
        Test.stopTest();

        Assert.areEqual('0 B', zero, '0 bytes formatted');
        Assert.areEqual('512 B', small, '512 bytes formatted');
        Assert.areEqual('2 KB', kb, '2048 bytes formatted as KB');
        Assert.areEqual('2.5 KB', fractionalKb, '2560 bytes formatted as fractional KB');
        Assert.areEqual('5 MB', mb, '5242880 bytes formatted as MB');
        Assert.areEqual('2 GB', gb, 'GB formatted');
        Assert.areEqual('0 B', nullBytes, 'Null bytes formatted as 0 B');
    }

    @IsTest
    static void testBulkDownloadUrl() {
        List<ContentVersion> versions = [SELECT Id FROM ContentVersion LIMIT 2];
        List<Id> vIds = new List<Id>{ versions[0].Id, versions[1].Id };

        Test.startTest();
        String url = FileViewerService.getBulkDownloadUrl(vIds);
        String emptyUrl = FileViewerService.getBulkDownloadUrl(new List<Id>());
        String nullUrl = FileViewerService.getBulkDownloadUrl(null);
        Test.stopTest();

        Assert.isTrue(
            url.startsWith('/sfc/servlet.shepherd/version/download/'),
            'URL should start with servlet endpoint'
        );
        Assert.isTrue(url.contains(String.valueOf(versions[0].Id)), 'URL should contain first version Id');
        Assert.areEqual('', emptyUrl, 'Empty list should return empty string');
        Assert.areEqual('', nullUrl, 'Null list should return empty string');
    }

    @IsTest
    static void testRenameFile() {
        ContentDocument doc = [SELECT Id, Title FROM ContentDocument LIMIT 1];

        Test.startTest();
        Boolean success = FileViewerService.renameFile(doc.Id, 'Renamed Contract');
        Test.stopTest();

        Assert.isTrue(success, 'Rename should succeed');
        ContentDocument updatedDoc = [SELECT Title FROM ContentDocument WHERE Id = :doc.Id];
        Assert.areEqual('Renamed Contract', updatedDoc.Title, 'Title should be updated');
    }

    @IsTest
    static void testRenameFileValidation() {
        Boolean caught = false;
        try {
            FileViewerService.renameFile(null, '');
        } catch (IllegalArgumentException ex) {
            caught = true;
        }
        Assert.isTrue(caught, 'Should throw IllegalArgumentException on null id');
    }

    @IsTest
    static void testDeleteFile() {
        ContentDocument doc = [SELECT Id FROM ContentDocument LIMIT 1];

        Test.startTest();
        Boolean deleted = FileViewerService.deleteFile(doc.Id);
        Test.stopTest();

        Assert.isTrue(deleted, 'Delete should succeed');
        List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Id = :doc.Id];
        Assert.areEqual(0, docs.size(), 'Document should be deleted');
    }

    @IsTest
    static void testDeleteFileValidation() {
        Boolean caught = false;
        try {
            FileViewerService.deleteFile(null);
        } catch (IllegalArgumentException ex) {
            caught = true;
        }
        Assert.isTrue(caught, 'Should throw IllegalArgumentException on null id');
    }

    @IsTest
    static void testDeleteNonExistentFile() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Boolean caught = false;
        try {
            // Using Account ID where a ContentDocument ID is expected triggers docs.isEmpty() AuraHandledException
            FileViewerService.deleteFile(acc.Id);
        } catch (AuraHandledException ex) {
            caught = true;
        }
        Assert.isTrue(caught, 'Should throw AuraHandledException when file is not found');
    }

    @IsTest
    static void testRenameNonExistentFile() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Boolean caught = false;
        try {
            // Using Account ID where a ContentDocument ID is expected triggers docs.isEmpty() AuraHandledException
            FileViewerService.renameFile(acc.Id, 'New Title');
        } catch (AuraHandledException ex) {
            caught = true;
        }
        Assert.isTrue(caught, 'Should throw AuraHandledException when file is not found');
    }
}
