public with sharing class EAPage2Ext {
    public List<CampaignMember> listInvited{get; set;}
    public List<CampaignMember> listNotInvited{get; set;}
    public List<CampaignMember> listBadMP {get; set;}
    public Integer countInvited {get; set;}
    public Integer countNotInvited{get; set;}
    public Integer countBadMP {get; set;}
    public Integer l1{get;set;}
    public Integer l2{get;set;}

    public EAPage2Ext(ApexPages.StandardController controller) {
        l1=0;
        l2=0;

    listInvited = [SELECT Id, Status, Name, Email, Pre_Applicant__c, Pre_Applicant__r.Name, Pre_Applicant__r.Id, EA_Sort__c, EA1__c, EA2__c, Email_Verification__c, Flagged_RTV__c, Campaign_Member_Lottery_Number__c, Campaign_Member_Join_Date__c, Ownership_Eligible__c, Rental_Eligible__c, Muni_Pref__c, Action__c, Invited_Message__c, JB_Test__c
                   FROM CampaignMember WHERE EA1__c=true AND CampaignId=: ApexPages.currentPage().getParameters().get('cId') ORDER BY EA_Sort__c ASC];
    countInvited = listInvited.size();
        IF (countInvited > 900){
            l1=1;
           listInvited = [SELECT Id, Status, Name, Email, Pre_Applicant__c, Pre_Applicant__r.Name, Pre_Applicant__r.Id, EA_Sort__c, EA1__c, EA2__c, Email_Verification__c, Flagged_RTV__c, Campaign_Member_Lottery_Number__c, Campaign_Member_Join_Date__c, Ownership_Eligible__c, Rental_Eligible__c, Muni_Pref__c, Action__c, Invited_Message__c, JB_Test__c
                   FROM CampaignMember WHERE EA1__c=true AND CampaignId=: ApexPages.currentPage().getParameters().get('cId') ORDER BY EA_Sort__c ASC LIMIT 800]; 
        }
    
    listNotInvited = [SELECT Id, Status, Name, Email, Pre_Applicant__c, Pre_Applicant__r.Name, Pre_Applicant__r.Id, EA_Sort__c, EA1__c, EA2__c, Email_Verification__c, Flagged_RTV__c, Campaign_Member_Lottery_Number__c, Campaign_Member_Join_Date__c, Ownership_Eligible__c, Rental_Eligible__c, Muni_Pref__c, Action__c, Invited_Message__c, JB_Test__c
                       FROM CampaignMember WHERE EA2__c=true AND CampaignId=: ApexPages.currentPage().getParameters().get('cId') ORDER BY EA_Sort__c ASC];
    countNotInvited = listNotInvited.size();
                IF (countNotInvited > 900){
                    l2=1;
           listNotInvited = [SELECT Id, Status, Name, Email, Pre_Applicant__c, Pre_Applicant__r.Name, Pre_Applicant__r.Id, EA_Sort__c, EA1__c, EA2__c, Email_Verification__c, Flagged_RTV__c, Campaign_Member_Lottery_Number__c, Campaign_Member_Join_Date__c, Ownership_Eligible__c, Rental_Eligible__c, Muni_Pref__c, Action__c, Invited_Message__c, JB_Test__c
                       FROM CampaignMember WHERE EA2__c=true AND CampaignId=: ApexPages.currentPage().getParameters().get('cId') ORDER BY EA_Sort__c ASC LIMIT 800]; 
        }
    listBadMP = [SELECT Id FROM CampaignMember WHERE Campaign_MP_Muni_Problem__c=true AND EA2__c=true AND CampaignId=: ApexPages.currentPage().getParameters().get('cId') ORDER BY EA_Sort__c ASC];
    countBadMP = listBadMP.size();
    }
 
}