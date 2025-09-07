public class AppDeadlinesExt {
    public HOMEtracker__Property__c dProp {get; set;}
    public Campaign dCamp {get; set;}
    public Date ifLastDeadlineDate {get; set;}
    public Date ifNextDeadlineDate {get; set;}
    public Date faLastDeadlineDate {get; set;}
    public Date faNextDeadlineDate {get; set;}
    
    public AppDeadlinesExt(ApexPages.StandardController controller) {
        
    dProp = (HOMETracker__Property__c )controller.getRecord();
    
    String dPropId = dProp.Id;
    
//    dCamp = [SELECT Id FROM Campaign WHERE Campaign_Property__r.Id = :dPropId LIMIT 1];
//    String dCampId = dCamp.Id;
    
        String dCampId = '';
        IF(dCamp == NULL) {
            dCampId = '';
        } ELSE {
        dCamp = [SELECT Id FROM Campaign WHERE Campaign_Property__r.Id = :dPropId LIMIT 1];
            dCampId = dCamp.Id;
        }
    
        
    //Interest Form: most recent IF Deadline Date Today or in past   
    List<CampaignMember> ifDeadlinesPast = 
        [
            SELECT Id, Deadline_Date__c
            FROM CampaignMember
            WHERE Invited_Date__c>1900-01-01
                AND Status != 'Not Invited'
                AND Status != 'Ineligible'
                AND CampaignId= :dCampId
                AND Deadline_Date__c < TODAY
            ORDER BY Deadline_Date__c DESC
            LIMIT 1
        ];
    if(ifDeadlinesPast.isEmpty()) {
            ifLastDeadlineDate = NULL;
        } else {
            ifLastDeadlineDate = ifDeadlinesPast[0].Deadline_Date__c;
        }


    //Interest Form: closest deadline after today   
    List<CampaignMember> ifDeadlinesNext = 
        [
            SELECT Id, Deadline_Date__c
            FROM CampaignMember
            WHERE Invited_Date__c>1900-01-01
                AND Status != 'Not Invited'
                AND Status != 'Ineligible'
                AND CampaignId= :dCampId
                AND Deadline_Date__c >= TODAY
            ORDER BY Deadline_Date__c ASC
            LIMIT 1 
        ];

    if(ifDeadlinesNext.isEmpty()) {
            ifNextDeadlineDate = NULL;
        } else {
            ifNextDeadlineDate = ifDeadlinesNext[0].Deadline_Date__c;
        }

    //Full Application First Submission:  most recent IF Deadline Date Today or in past  
    List<Application__c> faDeadlinesLast = 
        [
            SELECT Id, Application_Due__c
            FROM Application__c
            WHERE
                Property__r.Campaign__r.Id= :dCampId
                AND Application_Due__c < TODAY
            ORDER BY Application_Due__c DESC
            LIMIT 1 
        ];

    if(faDeadlinesLast.isEmpty()) {
            faLastDeadlineDate= NULL;
        } else {
            faLastDeadlineDate= faDeadlinesLast[0].Application_Due__c;
        } 
        
    //Full Application First Submission: closest deadline after today   
    List<Application__c> faDeadlinesNext = 
        [
            SELECT Id, Application_Due__c
            FROM Application__c
            WHERE
                Property__r.Campaign__r.Id= :dCampId
                AND Application_Due__c >= TODAY
            ORDER BY Application_Due__c ASC
            LIMIT 1 
        ];

    if(faDeadlinesNext.isEmpty()) {
            faNextDeadlineDate = NULL;
        } else {
            faNextDeadlineDate = faDeadlinesNext[0].Application_Due__c;
        }        
        
        
        
 
        
    }

}