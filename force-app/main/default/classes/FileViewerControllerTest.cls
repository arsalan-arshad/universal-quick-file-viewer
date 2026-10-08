/**
 * @description Unit tests for FileViewerController.
 * @author Arsalan Arshad
 */
@IsTest
private class FileViewerControllerTest {
    @TestSetup
    static void setupTestData() {
        Account testAcc = new Account(Name = 'Controller Test Account');
        insert testAcc;

        ContentVersion cv = new ContentVersion(
            Title = 'Sample Presentation',
            PathOnClient = 'Deck.pptx',
            VersionData = Blob.valueOf('Deck Content')
        );
        insert cv;

        ContentVersion insertedVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id];

        insert new ContentDocumentLink(
            LinkedEntityId = testAcc.Id,
            ContentDocumentId = insertedVersion.ContentDocumentId,
            ShareType = 'V',
            Visibility = 'AllUsers'
        );
    }

    @IsTest
    static void testGetRecordFiles() {
        Account acc = [SELECT Id FROM Account LIMIT 1];

        Test.startTest();
        List<FileViewerService.FileItem> items = FileViewerController.getRecordFiles(acc.Id, null, 'ALL', 10);
        Test.stopTest();

        Assert.areEqual(1, items.size(), 'Controller should return 1 file');
        Assert.areEqual('Sample Presentation', items[0].title, 'Title should match');
    }

    @IsTest
    static void testGetBulkDownloadUrl() {
        ContentVersion cv = [SELECT Id FROM ContentVersion LIMIT 1];

        Test.startTest();
        String url = FileViewerController.getBulkDownloadUrl(new List<Id>{ cv.Id });
        Test.stopTest();

        Assert.isTrue(url.contains(String.valueOf(cv.Id)), 'Bulk download URL should contain version ID');
    }

    @IsTest
    static void testRenameAndDelete() {
        ContentDocument doc = [SELECT Id FROM ContentDocument LIMIT 1];

        Test.startTest();
        Boolean renamed = FileViewerController.renameFile(doc.Id, 'Renamed Deck');
        Boolean deleted = FileViewerController.deleteFile(doc.Id);
        Test.stopTest();

        Assert.isTrue(renamed, 'File should be renamed');
        Assert.isTrue(deleted, 'File should be deleted');
    }

    @IsTest
    static void testErrorHandling() {
        Boolean renameFailed = false;
        Boolean deleteFailed = false;

        Test.startTest();
        try {
            FileViewerController.renameFile(null, null);
        } catch (AuraHandledException ex) {
            renameFailed = true;
        }

        try {
            FileViewerController.deleteFile(null);
        } catch (AuraHandledException ex) {
            deleteFailed = true;
        }
        Test.stopTest();

        Assert.isTrue(renameFailed, 'Should catch AuraHandledException on rename');
        Assert.isTrue(deleteFailed, 'Should catch AuraHandledException on delete');
    }
}
