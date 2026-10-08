/**
 * @description Unit tests for FileViewerInvocable action (Agentforce / Flows).
 * @author Arsalan Arshad
 */
@IsTest
private class FileViewerInvocableTest {
    @TestSetup
    static void setupTestData() {
        Opportunity opp = new Opportunity(
            Name = 'Invocable Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );
        insert opp;

        List<ContentVersion> versions = new List<ContentVersion>{
            new ContentVersion(
                Title = 'Proposal Document',
                PathOnClient = 'Proposal.pdf',
                VersionData = Blob.valueOf('Proposal Details')
            ),
            new ContentVersion(
                Title = 'Pricing Sheet',
                PathOnClient = 'Pricing.xlsx',
                VersionData = Blob.valueOf('Pricing Table')
            )
        };
        insert versions;

        List<ContentVersion> insertedVersions = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :versions
        ];

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentVersion cv : insertedVersions) {
            links.add(
                new ContentDocumentLink(
                    LinkedEntityId = opp.Id,
                    ContentDocumentId = cv.ContentDocumentId,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                )
            );
        }
        insert links;
    }

    @IsTest
    static void testGetFilesInvocablePositive() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        FileViewerInvocable.FileRequest req = new FileViewerInvocable.FileRequest();
        req.recordId = opp.Id;
        req.categoryFilter = 'ALL';
        req.maxFiles = 10;

        Test.startTest();
        List<FileViewerInvocable.FileResult> results = FileViewerInvocable.getFiles(
            new List<FileViewerInvocable.FileRequest>{ req }
        );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return 1 result');
        FileViewerInvocable.FileResult res = results[0];
        Assert.isTrue(res.hasFiles, 'Opportunity should have files');
        Assert.areEqual(2, res.fileCount, 'File count should be 2');
        Assert.areEqual(2, res.fileNames.size(), 'Should contain 2 file names');
        Assert.isTrue(res.summary.contains('Found 2 file(s)'), 'Summary should mention file count');
        Assert.isNotNull(res.bulkDownloadUrl, 'Bulk download URL should be populated');
    }

    @IsTest
    static void testGetFilesInvocableFiltering() {
        Opportunity opp = [SELECT Id FROM Opportunity LIMIT 1];

        FileViewerInvocable.FileRequest req = new FileViewerInvocable.FileRequest();
        req.recordId = opp.Id;
        req.searchTerm = 'Proposal';
        req.categoryFilter = 'PDFS';

        Test.startTest();
        List<FileViewerInvocable.FileResult> results = FileViewerInvocable.getFiles(
            new List<FileViewerInvocable.FileRequest>{ req }
        );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return 1 result');
        Assert.areEqual(1, results[0].fileCount, 'Should filter to 1 PDF');
        Assert.isTrue(results[0].fileNames[0].contains('Proposal'), 'File title should match');
    }

    @IsTest
    static void testGetFilesInvocableNullAndEmpty() {
        Test.startTest();
        List<FileViewerInvocable.FileResult> emptyResults = FileViewerInvocable.getFiles(
            new List<FileViewerInvocable.FileRequest>()
        );

        FileViewerInvocable.FileRequest nullReq = new FileViewerInvocable.FileRequest();
        nullReq.recordId = null;

        List<FileViewerInvocable.FileResult> nullResults = FileViewerInvocable.getFiles(
            new List<FileViewerInvocable.FileRequest>{ nullReq }
        );
        Test.stopTest();

        Assert.areEqual(0, emptyResults.size(), 'Empty list should return empty results');
        Assert.areEqual(1, nullResults.size(), 'Null recordId should return 1 safe error result');
        Assert.isFalse(nullResults[0].hasFiles, 'hasFiles should be false');
        Assert.isTrue(nullResults[0].summary.contains('Invalid'), 'Summary should note invalid record ID');
    }

    @IsTest
    static void testMoreThanFiveFilesSummarySlice() {
        Opportunity opp = new Opportunity(
            Name = 'Bulk Files Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(15)
        );
        insert opp;

        List<ContentVersion> cvList = new List<ContentVersion>();
        for (Integer i = 1; i <= 6; i++) {
            cvList.add(
                new ContentVersion(
                    Title = 'Bulk Document ' + i,
                    PathOnClient = 'Doc' + i + '.pdf',
                    VersionData = Blob.valueOf('Content ' + i)
                )
            );
        }
        insert cvList;

        List<ContentVersion> insertedList = [
            SELECT Id, ContentDocumentId
            FROM ContentVersion
            WHERE Id IN :cvList
        ];

        List<ContentDocumentLink> links = new List<ContentDocumentLink>();
        for (ContentVersion cv : insertedList) {
            links.add(
                new ContentDocumentLink(
                    LinkedEntityId = opp.Id,
                    ContentDocumentId = cv.ContentDocumentId,
                    ShareType = 'V',
                    Visibility = 'AllUsers'
                )
            );
        }
        insert links;

        FileViewerInvocable.FileRequest req = new FileViewerInvocable.FileRequest();
        req.recordId = opp.Id;
        req.maxFiles = 10;

        Test.startTest();
        List<FileViewerInvocable.FileResult> results = FileViewerInvocable.getFiles(
            new List<FileViewerInvocable.FileRequest>{ req }
        );
        Test.stopTest();

        Assert.areEqual(1, results.size(), 'Should return 1 result');
        Assert.areEqual(6, results[0].fileCount, 'Should have 6 files');
        Assert.isTrue(results[0].summary.contains('and 1 more'), 'Summary should slice names and add "and 1 more"');
    }
}
