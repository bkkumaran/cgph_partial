public class OutreachApplicantsExt {
    public HOMEtracker__Property__c psProp {get; set;}
    public List<CampaignMember> OutreachApplicantList {get; set;}
    public integer oaListCount {get; set;}

    public OutreachApplicantsExt(ApexPages.StandardController controller) {
    psProp = (HOMETracker__Property__c )controller.getRecord();
    String psPropId = psProp.Id;
    
       OutreachApplicantList = [
        SELECT Id,
            EA_Sort__c,
            Link__c,
            Campaign_Preliminary_Submission__r.Name,
            Campaign_Preliminary_Submission__r.Id,
            Deadline_Date__c, Outreach_Applicant_Process__c,
            Campaign_Preliminary_Submission__r.Application_Due__c,
            Campaign_Preliminary_Submission__r.Status__c,
            Campaign_Preliminary_Submission__r.Service_File__r.Id,
            Campaign_Preliminary_Submission__r.Service_File__r.HOMEtracker__Status__c,
            Campaign_Preliminary_Submission__r.Service_File__r.PHA__Application_Status__c,
            Campaign_Preliminary_Submission__r.Service_File__r.PHA__Application_Submitted__c,
            Campaign_Preliminary_Submission__r.Service_File__r.Application_Workflow_Status__c,
            Campaign_Preliminary_Submission__r.Service_File__r.Priority__c,
            Outreach_Notes__c
        FROM CampaignMember
        WHERE
           Campaign_Preliminary_Submission__r.RecordTypeId = '012o000000048DLAAY'
           AND Campaign.Campaign_Property__r.id = :psPropId
           AND (Campaign_Preliminary_Submission__r.Outcome__c = 'Full Online Application Submitted'
                OR Campaign_Preliminary_Submission__r.Outcome__c = 'Invited to Submit Full Application'
                OR Campaign_Preliminary_Submission__r.Outcome__c = 'Unit No Longer Available')
            AND Campaign_Preliminary_Submission__r.Service_File__r.PHA__Application_Status__c != 'Declined'
            AND Campaign_Preliminary_Submission__r.Status__c != 'On Hold - Does Not Meet Local Preference Criteria'
           AND (Campaign_Preliminary_Submission__r.Service_File__r.Application_Workflow_Status__c = 'Invited - Waiting to Submit'
           OR Campaign_Preliminary_Submission__r.Service_File__r.Application_Workflow_Status__c = 'Pre-Screen Complete, Not Yet Referred'
           OR Campaign_Preliminary_Submission__r.Service_File__r.Application_Workflow_Status__c = 'Application Received - Waiting for Credit Results'
           OR Campaign_Preliminary_Submission__r.Service_File__r.Application_Workflow_Status__c = 'Waiting for Rental Pre-Screen'
               )
        
           ORDER BY
            EA_Sort__c ASC
            ];
                oaListCount = OutreachApplicantList.size();


}
}