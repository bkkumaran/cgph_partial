public with sharing class MTFRext {
    Public List<Trust_Fund_Item__c> listTFH {get; set;}
    Public List<Trust_Fund_Item__c> listTFA {get; set;}
    Public String MTFRID {get; set;}

    public MTFRext(ApexPages.StandardController controller) {
    
    MTFRID = apexpages.currentpage().getparameters().get('id');
    
    listTFH = [SELECT name, Id, MTFI_Amount__c FROM Trust_Fund_Item__c WHERE Trust_Fund_Report__r.Id = :MTFRID AND MTFI_Type__c = 'Housing Activity' ORDER BY Name];
    ListTFA = [SELECT name, Id, MTFI_Amount__c FROM Trust_Fund_Item__c WHERE Trust_Fund_Report__r.Id = :MTFRID AND MTFI_Type__c = 'Affordability Assistance' ORDER BY Name];
    
    }

}