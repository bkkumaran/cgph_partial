public class OutreachTrackerRemovedController {
    Public HOMETracker__Property__c dev {get; set;}
    Public List<Outreach_Tracking__c> listRemoved {get; set;}
    Public String devID {get; set;}
    
    public OutreachTrackerRemovedController(){
        
        devID= apexpages.currentpage().getparameters().get('d');
        
        dev= [SELECT
              id,
              Name,
              Google_Tracker_Link__c,
              Primary_Case_manager__c,
              Primary_Case_manager__r.FirstName,
              Primary_Case_manager__r.LastName,
              Primary_Case_manager__r.Email,
              Publish_Outreach_Tracker__c,
              Publish_Property_Inventory__c,
              Outreach_Contact__r.FirstName,
              Outreach_Contact__r.LastName,
              Outreach_Contact__r.email
              FROM HOMEtracker__Property__c WHERE id=:devID];
        
        listRemoved =[ SELECT Id,
                      Name,
             Property_Id__c,
             Property_Address__c,
             Unit__c,
             Property_Unit__c,
             Property_Unit__r.Unit_Number__c,
             Property_Unit__r.Name,
             Property_Rent_or_List_Price__c,
             SF_Priority__c,
             Priority_Calc__c,
             Applicant_Name__c,
             Applicant_Email__c,
             Applicant_Phone__c,
             Household_Size__c,
             Date_CGPH_Added_Name__c,
             Date_Marked_Primary__c,
             Date_Eligibility_Review_Began__c,
             Date_Ready_for_Eligibility_Review__c,
             CGPH_Determination__c,
             CGPH_Approval_Denial_Date__c,
             Marked_as_Removed_Date__c,
             Landlord_Developer_Tour__c,
             Landlord_Developer_Notes__c,
             Landlord_Developer_Determination_Date__c,
             Landlord_Developer_Determination__c,
             Landlord_Developer_Deadline__c,
             Landlord_Developer_App_Sent__c,
             Tracker_Status__c,
             Service_File__r.Priority__c,
             Service_File__r.HOMEtracker__Property__r.Group_Property__c,
             Service_File__r.HOMEtracker__Property__r.Development_address__r.Id
                     FROM Outreach_Tracking__c
                     WHERE Service_File__r.HOMETracker__Property__r.Development_address__r.Id = :devID 
                        AND Tracker_Status__c = 'Removed'
                        AND Move_to_Removed_Report__c = true
                     ORDER BY Service_File__r.HOMETracker__Property__c ASC, Unit__c ASC, Priority_Calc__c ASC
                     ];
        Integer listRemovedSize = listRemoved.size();
        
        IF(listRemovedSize == 0)
        {
        listRemoved=Null;    
        }
    }
}