public with sharing class InviteStepOneExt {
    public List<HOMEtracker__Service_File__c> ListSF {get; set;}
    public Application__c PreSub {get; set;}
    public String PreSubId {get; set;}
    public String PreAppId {get; set;}
    public String PreSubType {get; set;}

    public InviteStepOneExt(ApexPages.StandardController controller) {
    
    PreSub= (Application__c)controller.getRecord();
    PreSubId = PreSub.Id;
    PreSub = [select id, Pre_Applicant__r.Id, Property_Type__c from Application__c WHERE id = :PreSubId];
    PreAppId = PreSub.Pre_Applicant__r.Id;
    PreSubType = PreSub.Property_Type__c;
    String TypeNeeded = '';
    
        IF(PreSubType == 'Rental_Unit'){
            TypeNeeded = 'Rental';
        }
        IF(PreSubType == 'Homeownership'){
            TypeNeeded = 'Homeownership';
        }
   
    
    ListSF = [SELECT
                Id,
                Name,
                PHA__Application_Status__c,
                Application_Workflow_Status__c,
                HOMEtracker__Status__c,
                PHA__Application_Due_Date__c,
                Cases_Check__c,
                Application_URL_Internal__c,
                PHA__Portal_Visits__c,
                Date_Certification_Expires__c,
                PHA__Total_Required_Documents__c,
                RecordType.Name,
                Eligibility_Date__c
              FROM HOMEtracker__Service_File__c
              WHERE Pre_Applicant__r.Id = :PreAppId AND RecordType.Name = :TypeNeeded
              ORDER BY HOMEtracker__Status__c ASC];

    }

}