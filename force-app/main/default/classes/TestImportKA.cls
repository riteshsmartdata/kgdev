@IsTest
private class TestImportKA {
    
    @testSetup
    static void setupTestData() {
        // Create mock KAToImportResult records
        // We won't insert real KA, just store fake Ids
        List<ImportKA.KAToImportResult> mockData = new List<ImportKA.KAToImportResult>();
        
        ImportKA.KAToImportResult masterRec = new ImportKA.KAToImportResult();
        masterRec.knowledgeArticleId = 'ka0XXXX000000001AAA'; // Fake Id
        masterRec.isMaster = true;
        masterRec.language = 'en_US';
        mockData.add(masterRec);
        
        ImportKA.KAToImportResult translationRec = new ImportKA.KAToImportResult();
        translationRec.knowledgeArticleId = 'ka0XXXX000000002AAA'; // Fake Id
        translationRec.isMaster = false;
        translationRec.language = 'fr';
        mockData.add(translationRec);
        
        // Store in a custom setting-like static variable for retrieval
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
    }
    
    @IsTest
    static void testCreateDraftFromArchive_Success() {
        List<ImportKA.KAToImportResult> inputList = new List<ImportKA.KAToImportResult>();
        ImportKA.KAToImportResult rec = new ImportKA.KAToImportResult();
        rec.knowledgeArticleId = 'ka0FakeId001';
        inputList.add(rec);
        
        Test.startTest();
        List<ImportKA.KAToImportResult> result = ImportKA.createDraftFromArchive(inputList);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
    }
    
    @IsTest
    static void testCreateDraftFromArchive_Exception() {
        List<ImportKA.KAToImportResult> inputList = new List<ImportKA.KAToImportResult>();
        ImportKA.KAToImportResult rec = new ImportKA.KAToImportResult();
        rec.knowledgeArticleId = null; // Will cause exception
        inputList.add(rec);
        
        Test.startTest();
        List<ImportKA.KAToImportResult> result = ImportKA.createDraftFromArchive(inputList);
        Test.stopTest();
        
        System.assertEquals('', result[0].knowledgeArticleId);
        System.assertNotEquals('', result[0].error);
    }
    
    @IsTest
    static void testPublishAndArchiveArticles() {
        List<ImportKA.KAToImportResult> inputList = new List<ImportKA.KAToImportResult>();
        ImportKA.KAToImportResult rec = new ImportKA.KAToImportResult();
        rec.knowledgeArticleId = 'ka0FakeId002';
        inputList.add(rec);
        
        Test.startTest();
        List<ImportKA.KAToImportResult> result = ImportKA.publishAndArchiveArticles(inputList);
        Test.stopTest();
        
        System.assertEquals(1, result.size());
    }
    
    @IsTest
    static void testUnpublishOnlineArticle_MasterAndTranslation() {
        // Master record
        ImportKA.KAToImportResult masterRec = new ImportKA.KAToImportResult();
        masterRec.knowledgeArticleId = 'ka0FakeId003';
        masterRec.isMaster = true;
        masterRec.language = 'en_US';
        
        // Translation record
        ImportKA.KAToImportResult translationRec = new ImportKA.KAToImportResult();
        translationRec.knowledgeArticleId = 'ka0FakeId004';
        translationRec.isMaster = false;
        translationRec.language = 'fr';
        
        List<ImportKA.KAToImportResult> inputList = new List<ImportKA.KAToImportResult>{ masterRec, translationRec };
        
        Test.startTest();
        List<ImportKA.KAToImportResult> result = ImportKA.unpublishOnlineArticle(inputList);
        Test.stopTest();
        
        System.assertEquals(2, result.size());
    }
    
    @IsTest
    static void testPublishDraft_MasterAndTranslation() {
        ImportKA.KAToImportResult masterRec = new ImportKA.KAToImportResult();
        masterRec.knowledgeArticleId = 'ka0FakeId005';
        masterRec.isMaster = true;
        
        ImportKA.KAToImportResult translationRec = new ImportKA.KAToImportResult();
        translationRec.id = 'ka0FakeId006';
        translationRec.knowledgeArticleId = 'ka0FakeId006';
        translationRec.isMaster = false;
        
        List<ImportKA.KAToImportResult> inputList = new List<ImportKA.KAToImportResult>{ masterRec, translationRec };
        
        Test.startTest();
        List<ImportKA.KAToImportResult> result = ImportKA.publishDraft(inputList);
        Test.stopTest();
        
        System.assertEquals(2, result.size());
    }
}