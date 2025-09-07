public class InventoryTimelineExt {
    Public HOMETracker__Property__c dev {get; set;}
    Public String devID {get; set;}
    Public List<HOMETracker__Property__c> unitList {get; set;}
    Public String getGroupShow {get; set;}


    public InventoryTimelineExt(ApexPages.StandardController controller) {
        devID= controller.getId();
        
        dev= [SELECT id, Name, Rental_or_Sale_Development__c FROM HOMEtracker__Property__c WHERE id=:devID LIMIT 1];
        
         unitList = [
            SELECT
                Id,
                Name,
                HOMEtracker__Status__c,
                Google_Tracker_Link__c,
                Group_Property__c,
                Group_Property_Parent__c,
                Group_Property_Parent__r.Id,
                Group_Property_Parent__r.Name,
                Rental_or_Sale_Development__c,
                Outreach_Stage__c,
                Listing_Stage__c,
                Unit_Number__c,
                Current_Outreach_Timeline__r.Id,
                Current_Outreach_Timeline__r.Name,
                Current_Outreach_Timeline__r.Outreach_Start_Date__c,
                Current_Outreach_Timeline__r.Target_Outreach_Start_Date__c,
                Current_Outreach_Timeline__r.Outreach_Start_Date_Status__c,
                Current_Outreach_Timeline__r.Full_Apps_Sent_Date__c,
                Current_Outreach_Timeline__r.Target_Full_Apps_Sent_Date__c,
                Current_Outreach_Timeline__r.Full_Apps_Sent_Date_Status__c,
                Current_Outreach_Timeline__r.Applicants_to_Tracker_Date__c,
                Current_Outreach_Timeline__r.Target_Applicants_to_Tracker_Date__c,
                Current_Outreach_Timeline__r.Applicants_to_Tracker_Date_Status__c,
                Current_Outreach_Timeline__r.LL_Dev_Approval_Date__c,
                Current_Outreach_Timeline__r.Target_LL_Dev_Approval_Date__c,
                Current_Outreach_Timeline__r.LL_Dev_Approval_Date_Status__c,
                Current_Outreach_Timeline__r.Certification_Date__c,
                Current_Outreach_Timeline__r.Certification_Date_Status__c,
                Current_Outreach_Timeline__r.Target_Outreach_Date__c,
                Current_Outreach_Timeline__r.Target_Outreach_Status__c
            FROM
                HOMEtracker__Property__c
            WHERE
                Development_address__r.Id = :devId
            ORDER BY
                Name ASC
            ];
    }
    public pageReference save(){
        update unitList;
        PageReference pg = new PageReference('/apex/OTtimelines?id='+DevID);
        pg.setRedirect(true);
        return pg;
        
    }   
}