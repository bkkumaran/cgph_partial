public with sharing class EAPage2nExtV2 {
    public List<CampaignMember> listNotInvited{get; set;}
    public List<CampaignMember> listBadMP {get; set;}
    public Integer countNotInvited{get; set;}
    public Integer countBadMP {get; set;}
    public Integer l2{get;set;}

    public EAPage2nExtV2(ApexPages.StandardController controller) {
        l2=0;
    
    listNotInvited = [SELECT Id, Status, Name, Email, Exclude_from_Batch_Email__c, Pre_Applicant__c, Pre_Applicant__r.Flagged_for_Outreach__c, Pre_Applicant__r.Flagged_for_Outreach_Notes__c, Pre_Applicant__r.Name, Pre_Applicant__r.Id, EA_Sort__c, EA1__c, EA2__c, Email_Verification__c, Flagged_RTV__c, Campaign_Member_Lottery_Number__c, Campaign_Member_Join_Date__c, Ownership_Eligible__c, Rental_Eligible__c, Muni_Pref__c, Action__c, Invited_Message__c, JB_Test__c
                       FROM CampaignMember WHERE Status = 'Not Invited' AND Base_Eligibility_Check__c = true AND Special_Preference_Eligible__c = true AND (Rental_Eligible__c = true OR Ownership_Eligible__c = true) AND CampaignId=: ApexPages.currentPage().getParameters().get('cId') ORDER BY EA_Sort__c ASC];
    countNotInvited = listNotInvited.size();
                IF (countNotInvited > 900){
                    l2=1;
           listNotInvited = [SELECT Id, Status, Name, Email, Exclude_from_Batch_Email__c, Pre_Applicant__c, Pre_Applicant__r.Flagged_for_Outreach__c, Pre_Applicant__r.Flagged_for_Outreach_Notes__c, Pre_Applicant__r.Name, Pre_Applicant__r.Id, EA_Sort__c, EA1__c, EA2__c, Email_Verification__c, Flagged_RTV__c, Campaign_Member_Lottery_Number__c, Campaign_Member_Join_Date__c, Ownership_Eligible__c, Rental_Eligible__c, Muni_Pref__c, Action__c, Invited_Message__c, JB_Test__c
                       FROM CampaignMember WHERE Status = 'Not Invited' AND Base_Eligibility_Check__c = true AND Special_Preference_Eligible__c = true AND (Rental_Eligible__c = true OR Ownership_Eligible__c = true) AND CampaignId=: ApexPages.currentPage().getParameters().get('cId') ORDER BY EA_Sort__c ASC LIMIT 800]; 
        }
    listBadMP = [SELECT Id FROM CampaignMember WHERE Campaign_MP_Muni_Problem__c=true AND Status = 'Not Invited' AND Base_Eligibility_Check__c = true AND Special_Preference_Eligible__c = true AND (Rental_Eligible__c = true OR Ownership_Eligible__c = true) AND CampaignId=: ApexPages.currentPage().getParameters().get('cId') ORDER BY EA_Sort__c ASC];
    countBadMP = listBadMP.size();
    }
 
}