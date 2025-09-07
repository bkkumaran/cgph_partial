public with sharing class OAext {
    public List<CampaignMember> listCM {get; set;}
    public CampaignMember CampMemb {get; set;}
    public String CMID {get; set;}
    public String EASORT {get; Set;}
    public String CID {get; set;}
    public Integer eaNum {get; set;}

    public OAext(ApexPages.StandardController controller) {
    
    CampMemb = (CampaignMember)controller.getRecord();
    CMID = CampMemb.Id;
    CampMemb = [select Id, EA_Sort__c, CampaignId, Name FROM CampaignMember WHERE Id = :CMID];
    EASORT = CampMemb.EA_Sort__c;
    CID = CampMemb.CampaignId;
    listCM = [SELECT Id
                FROM CampaignMember
                WHERE
                    CampaignId=:CID AND
                    EA_Sort__c <= :EASORT AND
                    CampaignMember.Campaign_Preliminary_Submission__r.Status__c != 'On Hold - Does Not Meet Current Listing Stage Criteria' AND
                    CampaignMember.Campaign_Preliminary_Submission__r.Status__c != 'On Hold - Does Not Meet Local Preference Criteria' AND
                    CampaignMember.Campaign_Preliminary_Submission__r.Status__c != 'Referred to Developer/Homeowner' AND
                    CampaignMember.Campaign_Preliminary_Submission__r.Status__c != 'Referred to Landlord' AND
                    CampaignMember.Campaign_Preliminary_Submission__r.Service_File__r.PHA__Application_Status__c != 'Declined' AND
                    CampaignMember.Campaign_Preliminary_Submission__r.RecordTypeId='012o000000048DLAAY' AND
                    (CampaignMember.Campaign_Preliminary_Submission__r.Outcome__c = 'Full Online Application Submitted' OR
                    CampaignMember.Campaign_Preliminary_Submission__r.Outcome__c = 'Invited to Submit Full Application' OR
                    CampaignMember.Campaign_Preliminary_Submission__r.Outcome__c = 'Pending' OR
                    CampaignMember.Campaign_Preliminary_Submission__r.Outcome__c = 'Unit No Longer Available')
                ORDER BY
                    EA_Sort__c ASC
                    ];
     eaNum =  listCM.size();                    

    }

}