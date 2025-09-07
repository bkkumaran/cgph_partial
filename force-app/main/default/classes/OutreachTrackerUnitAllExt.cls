public class OutreachTrackerUnitAllExt {
    public List<Outreach_Tracking__c> applicantsUnit {get; set;}
    public List<Outreach_Tracking__c> applicantsGroup {get; set;}
    public HOMETRACKER__Property__c property {get; set;}
    
    public OutreachTrackerUnitAllExt(ApexPages.StandardController controller) {
    
    property = (HOMETracker__Property__c )controller.getRecord();
    
    applicantsUnit = [
                    SELECT
                        id,
                        Name,
                        Applicant_Name__c,
                        Tracker_Status__c,
                        Property_Unit__c,
                        Property_Unit__r.Unit_Number__c,
                        Property_Address__c,    
                        Unit__c,
                        SF_Priority__c,
                        Include_On_Tracker__c,
                        Date_CGPH_Added_Name__c,
                        Date_Marked_Primary__c,
                        Landlord_Developer_Determination__c,
                        Landlord_Developer_Determination_Date__c,
                        Landlord_Developer_Notes__c,
                        Date_Ready_for_Eligibility_Review__c,
                        Date_Eligibility_Review_Began__c,
                        CGPH_Determination__c,
                        CGPH_Approval_Denial_Date__c         
                FROM Outreach_Tracking__c
                WHERE Property_Unit__r.Id = :property.Id AND Include_On_Tracker__c = true
                ORDER BY Priority_Calc__c ASC
              ];
 
    IF (applicantsUnit.size() == 0) {
    applicantsUnit = NULL;
    } ELSE {
       }  
        
    applicantsGroup = [
                    SELECT
                        id,
                        Name,
                        Applicant_Name__c,
                        Tracker_Status__c,
                        Property_Unit__c,
                        Property_Address__c,    
                        Unit__c,
                        Property_Unit__r.Unit_Number__c,
                        SF_Priority__c,
                        Include_On_Tracker__c,
                        Date_CGPH_Added_Name__c,
                        Date_Marked_Primary__c,
                        Landlord_Developer_Determination__c,
                        Landlord_Developer_Determination_Date__c,
                        Landlord_Developer_Notes__c,
                        Date_Ready_for_Eligibility_Review__c,
                        Date_Eligibility_Review_Began__c,
                        CGPH_Determination__c,
                        CGPH_Approval_Denial_Date__c         
                FROM Outreach_Tracking__c
                WHERE Service_File__r.HOMEtracker__Property__r.Id = :property.Id AND Include_On_Tracker__c = true
                ORDER BY Priority_Calc__c ASC
              ];
 
    IF (applicantsGroup.size() == 0) {
    applicantsGroup = NULL;
    } ELSE {
       } 
        
    }
    public pageReference saveU(){
        IF(applicantsUnit==NULL){
        } ELSE {
            update applicantsUnit;
        }
        PageReference pg = new PageReference('/'+property.Id);
        pg.setRedirect(true);
        return pg;
    }
    public pageReference saveG(){
        IF(applicantsGroup==NULL){
        } ELSE {
            update applicantsGroup;
        }
        PageReference pg = new PageReference('/'+property.Id);
        pg.setRedirect(true);
        return pg;
    }
}