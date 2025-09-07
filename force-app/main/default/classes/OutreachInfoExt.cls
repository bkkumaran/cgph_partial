public class OutreachInfoExt {
    public HOMEtracker__Property__c prop {get; set;}
    public Campaign camp {get; set;}
    public List<CampaignMember> fullInvited {get; set;}
    public Integer fullInvitedCount {get; set;}
    
    public List<HOMEtracker__Property__c> groupProps {get; set;}
    public Integer groupPropsCount {get; set;}
    
    Public List<Outreach_Tracking__c> otAll {get; set;}
    Public List<Outreach_Tracking__c> otPrimary {get; set;}
    Public List<Outreach_Tracking__c> otBackup {get; set;}
    Public List<Outreach_Tracking__c> otHidden {get; set;}
    Public List<Outreach_Tracking__c> otFlagged {get; set;}
    Public List<Outreach_Tracking__c> otNone {get; set;}
    
    Public Integer otAllCount {get; set;}
    Public Integer otPrimaryCount {get; set;}
    Public Integer otBackupCount {get; set;}
    Public Integer otHiddenCount {get; set;}
    Public Integer otFlaggedCount {get; set;}
    Public Integer otNoneCount {get; set;}
    
    public OutreachInfoExt(ApexPages.StandardController controller) {
        prop = (HOMETracker__Property__c )controller.getRecord();
    
        String propId = prop.Id;
        
        prop = [SELECT Id, Name,Campaign__r.Id FROM HOMETracker__Property__c WHERE id = :propId LIMIT 1 ];
        
        String campId = prop.Campaign__r.Id;
        
        fullInvited = NULL;
        fullInvitedCount = 0;
        
        IF(prop.Campaign__c == NULL){
            campId='';
                } ELSE {
                    camp = [SELECT Id FROM Campaign WHERE id = :campId LIMIT 1];
                    
                    fullInvited = [
                                        SELECT Id
                                        FROM CampaignMember
                                        WHERE Invited_Date__c > 1900-01-01
                                                AND Campaign_Preliminary_Submission__r.Status__c = 'Invited to Submit a Full Application'
                                                AND Deadline_Date__c < TODAY
                                                AND CampaignId = :campId
                                        ORDER BY EA_Sort__c ASC
                                                ];
                                fullInvitedCount = fullInvited.size();
                }
                
        groupProps = [
            SELECT id
            FROM HOMEtracker__Property__c
            WHERE Group_Property_Parent__r.Id = :propId
                        ];
        groupPropsCount = groupProps.size();
        otAll = [
            SELECT Id, Name, Tracker_Status__c
            FROM Outreach_Tracking__c
            WHERE
                Service_File__r.HOMEtracker__Property__r.Id = :propId
                   ];

        otAllCount = otAll.size();

        otPrimary = [
            SELECT Id, Name, Tracker_Status__c
            FROM Outreach_Tracking__c
            WHERE
                Service_File__r.HOMEtracker__Property__r.Id = :propId AND
                Tracker_Status__c = 'Primary'
                   ];

        otPrimaryCount = otPrimary.size();           

        otBackup = [
            SELECT Id, Name, Tracker_Status__c
            FROM Outreach_Tracking__c
            WHERE
                Service_File__r.HOMEtracker__Property__r.Id = :propId AND
                Tracker_Status__c = 'backup'
                   ];
                   
        otBackupCount = otBackup.size();           

        otHidden = [
            SELECT Id, Name, Tracker_Status__c
            FROM Outreach_Tracking__c
            WHERE
                Service_File__r.HOMEtracker__Property__r.Id = :propId AND
                Tracker_Status__c = 'Hidden'
                   ];
                   
        otHiddenCount = otHidden.size();
                   
        otFlagged = [
            SELECT Id, Name, Tracker_Status__c
            FROM Outreach_Tracking__c
            WHERE
                Service_File__r.HOMEtracker__Property__r.Id = :propId AND
                Tracker_Status__c = 'Flagged'
                   ];
                   
        otFlaggedCount = otFlagged.size();
                   
        otNone = [
            SELECT Id, Name, Tracker_Status__c
            FROM Outreach_Tracking__c
            WHERE
                Service_File__r.HOMEtracker__Property__r.Id = :propId AND
                Tracker_Status__c = ''
                   ];
                   
         otNoneCount = otNone.size();        
                   
    }

}