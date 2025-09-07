public class AppInvitesExt {
    public HOMEtracker__Property__c AppInvProp {get; set;}
    public Integer countInitialBackupR {get; set;}
    public Integer countInitialBackupO {get; set;}
//    public Integer countStepOne {get; set;}
    public Integer countStepTwo {get; set;}
    public Integer countReadyForMPA {get; set;}
    
    
    public AppInvitesExt(ApexPages.StandardController controller) {
        AppInvProp = (HOMETracker__Property__c )controller.getRecord();
        String AppInvPropId = AppInvProp.Id;
        
        //Applicants ready for Initial Backup Email (Rental)
        List<Application__c>  listInitialBackupR = [
            SELECT Id, Name
            FROM Application__c 
            WHERE
                Property__c = :AppInvPropId AND 
                Status__c = 'Eligible, Pending Staff Action' AND 
                Outcome__c = 'Pending' AND 
                RecordTypeId = '012o000000048DL' AND 
                (Ready_to_Refer_to_Landlord__c = false OR 
                    R_Date_Initial_Backup_Email_Sent__c = NULL ) 
            ORDER BY EA_Sort__c ASC
            ];
        countInitialBackupR = listInitialBackupR.size();
            
        //Applicants ready for Initial Backup Email (Ownership)
        List<Application__c> listInitialBackupO = [
            SELECT Id, Name 
            FROM Application__c 
            WHERE 
                Property__c = :AppInvPropId AND 
                (Status__c = 'Eligible, Pending Staff Action'  
                    OR Status__c = 'Sent to Obtain a Mortgage Pre-Approval') AND 
                Outcome__c = 'Pending' AND 
                RecordTypeId = '012o000000048DL' AND 
                (Ready_to_Refer_to_Developer_Homeowner__c = false OR 
                    O_Date_Initial_Backup_Email_Sent__c  = NULL ) 
            ORDER BY EA_Sort__c ASC
            ];
            countInitialBackupO = listInitialBackupO.size();
        
        //Applicants ready for STEP ONE(process people with multiple service files)
        //    countStepOne
        // ????????????
        
        //Applicants ready for STEP TWO (invite to submit full app)
        List<Application__c> listStepTwo = [
            SELECT Id, Name 
            FROM Application__c 
            WHERE 
                Property__c = :AppInvPropId AND 
                RecordTypeId = '012o000000048DL' AND 
                Outcome__c = 'Pending' AND 
                (Status__c LIKE 'Approved%'  
                    OR Status__c = 'Sent to Obtain a Mortgage Pre-Approval') AND 
                Invite_to_Apply__c = false 
            ORDER BY EA_Sort__c ASC 
            ];
            countStepTwo= listStepTwo.size();
        
        //Applicants ready to be sent for a mortgage preapproval
        List<Application__c> listReadyForMPA = [
            SELECT Id, Name 
            FROM Application__c 
            WHERE 
                Property__c = :AppInvPropId AND 
                Mortgage_Pre_Approval_Deadline__c = NULL AND 
                Date_Sent_to_Obtain_MPA__c = NULL AND 
                ((Status__c = 'Approved Ownership Back Up Applicant - Pending Referral' AND 
                    Outcome__c = 'Pending') OR  
                    (Status__c = 'Invited to Submit a Full Application' 
                    AND Outcome__c = 'Invited to Submit Full Application'))  
            ORDER BY EA_Sort__c ASC
            ];
        countReadyForMPA = listReadyForMPA.size();
        
        
    }

}