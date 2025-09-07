public class ApplicantsIFext {
    public HOMEtracker__Property__c prop {get; set;}
    public Campaign camp {get; set;}
    public List<CampaignMember> ifEligNotInv {get; set;}
    public List<CampaignMember> ifInvited {get; set;}
    public List<CampaignMember> ifInvPreDead {get; set;}
    public List<CampaignMember> ifInvPostDead {get; set;}
    public List<CampaignMember> ifNoSubmit {get; set;}
    public List<CampaignMember> ifNotInterest {get; set;}
    public List<CampaignMember> ifNotEligible {get; set;}
    public List<CampaignMember> ifUndetermined {get; set;}
    public List<CampaignMember> ifEligible {get; set;}
    public List<CampaignMember> ifOnHoldLocal {get; set;}
    
    public List<CampaignMember> fullInvited {get; set;}
    public List<CampaignMember> fullReferred {get; set;}
    public List<CampaignMember> fullOpenHouse {get; set;}
    public List<CampaignMember> fullSentForMPA {get; set;}
    public List<CampaignMember> fullApprovedOwnBackup {get; set;}
    
    public Integer ifEligNotInvCount {get; set;}
    public Integer ifInvitedCount {get; set;}
    public Integer ifInvPreDeadCount {get; set;}
    public Integer ifInvPostDeadCount {get; set;}
    public Integer ifNoSubmitCount {get; set;}
    public Integer ifNotInterestCount {get; set;}
    public Integer ifNotEligibleCount {get; set;}
    public Integer ifUndeterminedCount {get; set;}
    public Integer ifEligibleCount {get; set;}
    public Integer ifOnHoldLocalCount {get; set;}
    
    public Integer fullInvitedCount {get; set;}
    public Integer fullReferredCount {get; set;}
    public Integer fullOpenHouseCount {get; set;}
    public Integer fullSentForMPACount {get; set;}
    public Integer fullApprovedOwnBackupCount {get; set;}  

    public ApplicantsIFext(ApexPages.StandardController controller) {
    
    prop = (HOMETracker__Property__c )controller.getRecord();
    
    String propId = prop.Id;
    
    String campId = '';
        IF(camp == NULL) {
            campId = '';
        } ELSE {
        camp = [SELECT Id FROM Campaign WHERE Campaign_Property__r.Id = :propId LIMIT 1];
            campId = camp.Id;
        }
    
    //Interest Form: Eligible applicants not yet invited
    ifeligNotInv = [
                SELECT id 
                    FROM CampaignMember 
                    WHERE Status = 'Not Invited' 
                        AND Base_Eligibility_Check__c = true
                        AND Special_Preference_Eligible__c = true
                        AND (Rental_Eligible__c = true OR Ownership_Eligible__c = true)
                        AND CampaignId = :campId
                    ORDER BY EA_Sort__c ASC
                 ];
    ifeligNotInvCount = ifeligNotInv.size();         
                 
    //Interest Form: Eligible applicants invited    
    ifInvited = [
                SELECT Id
                FROM CampaignMember
                WHERE Invited_Date__c>1900-01-01
                    AND Status != 'Not Invited'
                    AND Status != 'Ineligible'
                    AND CampaignId= :campId
                ORDER BY EA_Sort__c ASC 
                ];
    ifInvitedCount = ifInvited.size();
    
    //Interest Form: Eligible applicants invited: IF Deadline has not passed
    ifInvPreDead = [
                SELECT Id
                FROM CampaignMember
                WHERE Invited_Date__c>1900-01-01
                    AND Status != 'Not Invited'
                    AND Status != 'Ineligible'
                    AND CampaignId= :campId
                    AND Deadline_Date__c >= TODAY
                ORDER BY EA_Sort__c ASC 
                ];
    ifInvPreDeadCount = ifInvPreDead.size();
                
    //Interest Form: Eligible applicants invited: IF Deadline has passed
    ifInvPostDead = [
                SELECT Id
                FROM CampaignMember
                WHERE Invited_Date__c>1900-01-01
                    AND Status != 'Not Invited'
                    AND Status != 'Ineligible'
                    AND CampaignId= :campId
                    AND Deadline_Date__c < TODAY
                ORDER BY EA_Sort__c ASC 
                ];
     ifInvPostDeadCount = ifInvPostDead.size();       
 
 
     //INTEREST FORM RESULTS
         
     //Interest Form: Eligible applicants invited: IF Deadline has passed: did not submit               
     ifNoSubmit = [
             SELECT Id
             FROM CampaignMember
             WHERE Invited_Date__c > 1900-01-01
                 AND (Status = 'Emailed'
                 OR Status = 'Called'
                 OR Status = 'Mailed'
                 OR Status = 'Sent')
                 AND Campaign_Preliminary_Submission__r.Id=''
                 AND Deadline_Date__c < TODAY
                 AND CampaignId = :campId
             ORDER BY EA_Sort__c ASC ];           
     ifNoSubmitCount = ifNoSubmit.size();
     
     //Interest Form: Eligible applicants invited: IF Deadline has passed: Not Interested in Unit
     ifNotInterest = [
             SELECT Id
             FROM CampaignMember
             WHERE Invited_Date__c > 1900-01-01
                 AND Status = 'Not Interested in Unit'
                 AND Campaign_Preliminary_Submission__r.Id=''
                 AND Deadline_Date__c < TODAY
                 AND CampaignId = :campId
             ORDER BY EA_Sort__c ASC
                     ];            
     ifNotInterestCount = ifNotInterest.size();
 
 
 
 // REDO FROM HERE USING PRELIM SUBS!!!
 // add   [  AND Campaign_Preliminary_Submission__r.Id != ''  ] to all??
     
     //Interest Form: Eligible applicants invited: IF Deadline has passed: determined Not eligible at this time after submitting IF form
     ifNotEligible = [
             SELECT Id
             FROM CampaignMember
             WHERE Invited_Date__c > 1900-01-01
                 AND Campaign_Preliminary_Submission__r.Status__c = 'Ineligible, Pending Staff Action'
                 AND Deadline_Date__c < TODAY
                 AND CampaignId = :campId
             ORDER BY EA_Sort__c ASC
                     ];            
     ifNotEligibleCount = ifNotEligible.size();
     
     //Interest Form: Eligible applicants invited: IF Deadline has passed: marked as 'Undetermined' after submitting IF form for manual processing
     ifUndetermined = [
             SELECT Id
             FROM CampaignMember
             WHERE Invited_Date__c > 1900-01-01
                 AND Campaign_Preliminary_Submission__r.Status__c = 'Undetermined, Pending Staff Action'
                 AND Deadline_Date__c < TODAY
                 AND CampaignId = :campId
             ORDER BY EA_Sort__c ASC
                     ];             
     ifUndeterminedCount = ifUndetermined.size();
     
     //Interest Form: Eligible applicants invited: IF Deadline has passed: marked as 'Eligible, pending...' after submitting IF form
     ifEligible = [
             SELECT Id
             FROM CampaignMember
             WHERE Invited_Date__c > 1900-01-01
                 AND Campaign_Preliminary_Submission__r.Status__c = 'Eligible, Pending Staff Action'
                 AND Deadline_Date__c < TODAY
                 AND CampaignId = :campId
             ORDER BY EA_Sort__c ASC
                     ];
     ifEligibleCount = ifEligible.size();


     //Interest Form: Eligible applicants invited: IF Deadline has passed: marked as On Hold for Local Preference... after submitting IF form
     ifOnHoldLocal = [
             SELECT Id
             FROM CampaignMember
             WHERE Invited_Date__c > 1900-01-01
                 AND Campaign_Preliminary_Submission__r.Status__c = 'On Hold - Does Not Meet Local Preference Criteria'
                 AND Deadline_Date__c < TODAY
                 AND CampaignId = :campId
             ORDER BY EA_Sort__c ASC
                     ];
     ifOnHoldLocalCount = ifOnHoldLocal.size();     
     
     //FULL APP INVITATION SENT
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

     //FULL APP SUBMITTED: referred to landlord / developer
     fullReferred = [
             SELECT Id
             FROM CampaignMember
             WHERE Invited_Date__c > 1900-01-01
                 AND Campaign_Preliminary_Submission__r.Status__c = 'Referred to Landlord'
                 AND Deadline_Date__c < TODAY
                 AND CampaignId = :campId
             ORDER BY EA_Sort__c ASC
                     ];
     fullReferredCount = fullReferred.size();

     //FULL APP SUBMITTED: Sent to Visit Unit (Open House)
     fullOpenHouse = [
             SELECT Id
             FROM CampaignMember
             WHERE Invited_Date__c > 1900-01-01
                 AND Campaign_Preliminary_Submission__r.Status__c = 'Sent to Visit Unit (Open House)'
                 AND Deadline_Date__c < TODAY
                 AND CampaignId = :campId
             ORDER BY EA_Sort__c ASC
                     ];
     fullOpenHouseCount = fullOpenHouse.size();
     
     //FULL APP SUBMITTED: Sent to Obtain a Mortgage Pre-Approval
     fullSentForMPA = [
             SELECT Id
             FROM CampaignMember
             WHERE Invited_Date__c > 1900-01-01
                 AND Campaign_Preliminary_Submission__r.Status__c = 'Sent to Obtain a Mortgage Pre-Approval'
                 AND Deadline_Date__c < TODAY
                 AND CampaignId = :campId
             ORDER BY EA_Sort__c ASC
                     ];
     fullSentForMPACount = fullSentForMPA.size();
     
     //FULL APP SUBMITTED: Approved Ownership Back Up Applicant
     fullApprovedOwnBackup = [
             SELECT Id
             FROM CampaignMember
             WHERE Invited_Date__c > 1900-01-01
                 AND (Campaign_Preliminary_Submission__r.Status__c = 'Approved Ownership Back Up Applicant - Pending Full Application Invitation'
                     OR Campaign_Preliminary_Submission__r.Status__c = 'Approved Ownership Back Up Applicant - Pending Referral')
                 AND Deadline_Date__c < TODAY
                 AND CampaignId = :campId
             ORDER BY EA_Sort__c ASC
                     ];
     fullApprovedOwnBackupCount = fullApprovedOwnBackup.size();


                       
    }

}