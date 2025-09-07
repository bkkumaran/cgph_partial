public class OutreachTrackerUnitExt {
    public Outreach_Tracking__c primary {get; set;}
    public HOMETRACKER__Property__c property {get; set;}
    
    public OutreachTrackerUnitExt(ApexPages.StandardController controller) {
    
    property = (HOMETracker__Property__c )controller.getRecord();
    
    List<Outreach_Tracking__c> listPrimary = 
                [
                SELECT id
                FROM Outreach_Tracking__c
                WHERE Property_Unit__r.Id = :property.Id
                ORDER BY Priority_Calc__c ASC
                ];
    
    IF (listPrimary.size() == 0) {
    primary = NULL;
    } ELSE {
    
    primary = [
                SELECT
                id,
                Name,
                Applicant_Name__c,
                Tracker_Status__c,
                Property_Unit__c,
                Property_Address__c,
                Unit__c,
                SF_Priority__c,
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
                WHERE Property_Unit__r.Id = :property.Id
                ORDER BY Priority_Calc__c ASC
                LIMIT 1
              ];
        }          
             

    }

}