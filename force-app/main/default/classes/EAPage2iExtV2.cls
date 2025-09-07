public class EAPage2iExtV2 {
    public List<CampaignMember> listInvited{get; set;}
    public List<CampaignMember> listNotInterested {get; set;}
    public Integer countInvited {get; set;}
    public Integer countBadMP {get; set;}
    public Integer countNotInterested {get; set;}
    public Integer l1{get;set;}

    public EAPage2iExtV2(ApexPages.StandardController controller) {
        l1=0;

    listInvited = [SELECT Id, Status, Name, Email, Exclude_from_Batch_Email__c, Pre_Applicant__c, Pre_Applicant__r.Flagged_for_Outreach__c, Pre_Applicant__r.Flagged_for_Outreach_Notes__c, Pre_Applicant__r.Name, Pre_Applicant__r.Id, EA_Sort__c, EA1__c, EA2__c, Email_Verification__c, Flagged_RTV__c, Campaign_Member_Lottery_Number__c, Campaign_Member_Join_Date__c, Ownership_Eligible__c, Rental_Eligible__c, Muni_Pref__c, Action__c, Invited_Message__c, JB_Test__c
                   FROM CampaignMember WHERE Invited_Date__c>1900-01-01 AND Status != 'Not Invited' AND Status != 'Ineligible' AND CampaignId=: ApexPages.currentPage().getParameters().get('cId') ORDER BY EA_Sort__c ASC];
    countInvited = listInvited.size();
        IF (countInvited > 900){
            l1=1;
           listInvited = [SELECT Id, Status, Name, Email, Exclude_from_Batch_Email__c, Pre_Applicant__c, Pre_Applicant__r.Flagged_for_Outreach__c, Pre_Applicant__r.Flagged_for_Outreach_Notes__c, Pre_Applicant__r.Name, Pre_Applicant__r.Id, EA_Sort__c, EA1__c, EA2__c, Email_Verification__c, Flagged_RTV__c, Campaign_Member_Lottery_Number__c, Campaign_Member_Join_Date__c, Ownership_Eligible__c, Rental_Eligible__c, Muni_Pref__c, Action__c, Invited_Message__c, JB_Test__c
                   FROM CampaignMember WHERE Invited_Date__c>1900-01-01 AND Status != 'Not Invited' AND Status != 'Ineligible' AND CampaignId=: ApexPages.currentPage().getParameters().get('cId') ORDER BY EA_Sort__c ASC LIMIT 800]; 
        }
    listNotInterested = [SELECT Id, Status FROM CampaignMember WHERE Invited_Date__c>1900-01-01 AND Status = 'Not Interested in Unit' AND CampaignId=: ApexPages.currentPage().getParameters().get('cId') ORDER BY EA_Sort__c ASC];
    countNotInterested = listNotInterested.size();
    }
}