@isTest
public class RatingController_Test {
    @isTest
    public static void RatingTest() {
        test.startTest();
        
        ApexPages.currentPage().getParameters().put('feedback','Poor');
        RatingController obj = new RatingController();
        obj.createRecordFromURLRating();
        test.stopTest();
        
    }
}