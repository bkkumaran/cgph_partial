public class InterestFormPreviewExt {
    Public String pURL {get; set;}
    Public String pW {get; set;}

    public InterestFormPreviewExt(ApexPages.StandardController controller) {
        String propID= controller.getId();
        
        Property_Image__c getImage = [SELECT Id, Image_url__c FROM Property_Image__c WHERE Property__r.Id=:propID ORDER BY Sorting_Sequence_Number__c ASC LIMIT 1];
        
        pURL = getImage.Image_url__c ;
        
        pW = System.currentPageReference().getParameters().get('w');
    }

}