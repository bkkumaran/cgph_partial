public class PreScreenExt {
    public HOMEtracker__Property__c psProp {get; set;}
    // public List<Application__c> PreScreenListFinal {get; set;}
    public List<CampaignMember> PreScreenListFinal {get; set;}
    public integer psListCount {get; set;}
    public String lastEAsort {get; set;}

    public PreScreenExt(ApexPages.StandardController controller) {
    psProp = (HOMETracker__Property__c )controller.getRecord();
    String psPropId = psProp.Id;
    
   

    //get the highest EA SORT value of the person with the highest APPLICATION DUE date that is earlier than today  
    List<CampaignMember> PreScreenListStart = [
        SELECT Id, EA_Sort__c
        FROM CampaignMember
        WHERE
            Campaign_Preliminary_Submission__r.RecordTypeId = '012o000000048DLAAY'
            AND Campaign_Preliminary_Submission__r.Application_Due__c < TODAY
            AND (Campaign_Preliminary_Submission__r.Outcome__c = 'Full Online Application Submitted'
                OR Campaign_Preliminary_Submission__r.Outcome__c = 'Invited to Submit Full Application'
                OR Campaign_Preliminary_Submission__r.Outcome__c = 'Unit No Longer Available')
            AND Campaign_Preliminary_Submission__r.Service_File__r.PHA__Application_Status__c != 'Declined'
            AND Campaign_Preliminary_Submission__r.Status__c != 'On Hold - Does Not Meet Local Preference Criteria'
            AND Campaign_Preliminary_Submission__r.Status__c !='Referred to Landlord'
            AND Campaign_Preliminary_Submission__r.Status__c !='Referred to Developer/Homeowner'
            AND Campaign.Campaign_Property__r.id = :psPropId
        ORDER BY
            EA_Sort__c DESC
        LIMIT 1
            ];

    if(PreScreenListStart.isEmpty()) {
            lastEAsort= '';
        } else {
            lastEAsort = PreScreenListStart[0].EA_Sort__c;
        }
    
    PreScreenListFinal = [
        SELECT Id,
            EA_Sort__c,
            Campaign_Preliminary_Submission__r.Name,
            Deadline_Date__c, Outreach_Applicant_Process__c,
            Campaign_Preliminary_Submission__r.Application_Due__c,
            Campaign_Preliminary_Submission__r.Status__c,
            Campaign_Preliminary_Submission__r.Service_File__r.HOMEtracker__Status__c,
            Campaign_Preliminary_Submission__r.Service_File__r.PHA__Application_Status__c,
            Outreach_Notes__c
        FROM CampaignMember
        WHERE Campaign_Preliminary_Submission__r.RecordTypeId = '012o000000048DLAAY'
            AND (Campaign_Preliminary_Submission__r.Outcome__c = 'Full Online Application Submitted'
                OR Campaign_Preliminary_Submission__r.Outcome__c = 'Invited to Submit Full Application'
                OR Campaign_Preliminary_Submission__r.Outcome__c = 'Unit No Longer Available')
            AND Campaign_Preliminary_Submission__r.Service_File__r.PHA__Application_Status__c != 'Declined'
            AND Campaign_Preliminary_Submission__r.Status__c != 'On Hold - Does Not Meet Local Preference Criteria'
            AND Campaign_Preliminary_Submission__r.Status__c !='Referred to Landlord'
            AND Campaign_Preliminary_Submission__r.Status__c !='Referred to Developer/Homeowner'
            AND Campaign.Campaign_Property__r.id = :psPropId
            AND EA_Sort__c <= :lastEAsort
        ORDER BY EA_Sort__c ASC
        ];
    psListCount = PreScreenListFinal.size();

    }


}