public class GroupTimelineExt {
    Public HOMETracker__Property__c dev {get; set;}
    Public String devID {get; set;}
    Public List<HOMETracker__Property__c> unitList {get; set;}
    Public List<HOMETracker__Property__c> listOut {get; set;}
    Public List<HOMETracker__Property__c> listApp {get; set;}
    Public String getGroupShow {get; set;}
    Public Integer countOut     {get; set;}
    public Integer countApp     {get; set;}


    public GroupTimelineExt(ApexPages.StandardController controller) {
        devID= controller.getId();
        
        dev= [SELECT id, Name, Google_Tracker_Link__c, Rental_or_Sale_Development__c FROM HOMEtracker__Property__c WHERE id=:devID LIMIT 1];
        
         unitList = [
            SELECT
                Id,
                Name,
                HOMEtracker__Status__c,
                Rental_or_Sale_Development__c,
                Outreach_Stage__c,
                Listing_Stage__c,
                Unit_Number__c,
                Current_Outreach_Timeline__r.Id,
                Current_Outreach_Timeline__r.Name,
                Current_Outreach_Timeline__r.Next_Step_Date__c,
                Current_Outreach_Timeline__r.Next_Step__c,
                Current_Outreach_Timeline__r.Group_Property_Link__c,
                Current_Outreach_Timeline__r.Cert_Warning__c,
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
                Current_Outreach_Timeline__r.Target_Outreach_Status__c,
                Current_Outreach_Timeline__r.Group_Sort_Order__c

            FROM
                HOMEtracker__Property__c
            WHERE
                Group_Property_Parent__r.Id = :devId
            ORDER BY
                Current_Outreach_Timeline__r.Group_Sort_Order__c ASC, Name ASC
            ];
        
    listOut = [
        SELECT id 
        FROM HOMEtracker__Property__c
        WHERE Group_Property_Parent__r.Id = :devId AND
                  Date_Outreach_Began__c = NULL
                ];
        
    countOut = listOut.size();
        
    listApp = [
        SELECT id 
        FROM HOMEtracker__Property__c
        WHERE Group_Property_Parent__r.Id = :devId AND
                  First_Full_App_Invites_Sent__c = NULL
                ];
        
    countApp = listApp.size();
        
        
        
    }
    public pageReference save(){
        update unitList;
        PageReference pg = new PageReference('/apex/GroupTimeline?id='+DevID);
        pg.setRedirect(true);
        return pg;
        
    }   
}