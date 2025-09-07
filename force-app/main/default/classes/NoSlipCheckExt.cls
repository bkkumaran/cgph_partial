public with sharing class NoSlipCheckExt {
    Public List<Invoice_Entry__c> PendingSlip {get; set;}
    Public List<Contract> ClientSetup {get; set;}
    Public List<HOMETRACKER__Property__c> AAListing {get; set;}
    Public List<Municipality__c> Waitlist {get; set;}
    Public List<HOMEtracker__Service_File__c> MuniClosing {get; set;}
    Public List<HOMEtracker__Service_File__c> PrivOwnCert {get; set;}
    Public List<HOMEtracker__Service_File__c> AAElig {get; set;}
    Public List<Program_Application__c> AssistApps {get; set;}
    Public List<HOMETRACKER__Property__c> EmailList {get; set;}
    Public List<Log_Entry__c> HRMiles {get; set;}
    Public List<AA_Log_Entry__c> MuniAAlogs {get; set;}
    Public List<Contract> RecFlatFee1 {get; set;}
    Public List<Contract> RecFlatFee2 {get; set;}
    
    Public Integer cPendingSlip {get; set;}
    Public Integer cClientSetup {get; set;}
    Public Integer cAAListing {get; set;}
    Public Integer cWaitlist {get; set;}
    Public Integer cMuniClosing {get; set;}
    Public Integer cPrivOwnCert {get; set;}
    Public Integer cAAElig {get; set;}
    Public Integer cAssistApps {get; set;}
    Public Integer cEmailList {get; set;}
    Public Integer cHRMiles {get; set;}
    Public Integer cMuniAAlogs {get; set;}
    Public Integer cRecFlatFee1 {get; set;}
    Public Integer cRecFlatFee2 {get; set;}
    Public Integer cRecFlatFeeBoth {get; set;}
    
    Public String setupID {get; set;}
    Public Date invDate {get; set;}
    

    public NoSlipCheckExt(ApexPages.StandardController controller) {
    
    CGPH_General__c cs = CGPH_General__c.getOrgDefaults();
    invDate = cs.Invoicing_Date__c;
    setupID = ApexPages.currentPage().getParameters().get('id');


    //Pending Slips on Invoicing Setup
        PendingSlip = [
            SELECT Id
            FROM Invoice_Entry__c
            WHERE
                Invoice_Setup__c = :setupID AND
                Invoice_Record__c = '' AND
                Date__C <= :invDate AND
                Do_Not_Bill__c = false
                ];
                
         cPendingSlip = PendingSlip.size();
         IF(cPendingSlip == 0) { PendingSlip = NULL;}
     

    //Private Client Setup Fee
        ClientSetup = [
            SELECT ID
            FROM Contract
            WHERE
                Associated_TS_Contract_1__c = :setupID AND
                StartDate > 2024-01-01 AND
                (Current_Billing_Status__c = 'Active under Contract' OR
                Current_Billing_Status__c = 'Active without Contract')
                AND
                (Timeslips_Contract_Type__c = 'Private R' OR
                Timeslips_Contract_Type__c = 'Private S')
                AND
                Prior_Contract__c = '' AND
                AA_Setup_Billed__c = NULL AND
                AA_Setup_Fee__c != 0
                ];
                
        cClientSetup = ClientSetup.size();
        IF(cClientSetup == 0) { ClientSetup = NULL;}

    //AA Listing Fee
        AAListing = [
            SELECT Id 
            FROM HOMETRACKER__Property__c 
            WHERE
                Development_address__r.TS1__r.Id = :setupID AND
                Development_address__r.TS1__r.Client_Type__c = 'Public' AND
                Date_Outreach_began__c > 2023-07-01 AND
                Date_Outreach_began__c <= :invDate AND
                Listing_Invoiced__c = '' AND
                RecordTypeId = '012o00000003bUCAAY' 
            ];
            
        cAAListing = AAListing.size();
        IF(cAAListing == 0) { AAListing = NULL;}

    //Muni Waitlist Import Fee
        Waitlist = [
            SELECT Id 
            FROM Municipality__c 
            WHERE 
                AA_Muni_Svcs_Invoicing__r.Id = :setupID AND
                Waitlist_Import_Date__c > 2024-04-01 AND 
                Waitlist_Import_Invoiced__c = NULL 
                ];
                
        cWaitlist = Waitlist.size();
        IF(cWaitlist == 0) { Waitlist = NULL;}

    //Muni Closing Fee                 MuniClosing
        MuniClosing = [
            SELECT Id
            FROM HOMEtracker__Service_File__c
            WHERE
                HOMEtracker__Property__r.Development_address__r.TS1__r.Id = :setupID AND 
                Case_Number__c != '' AND 
                HOMEtracker__Property__r.RecordTypeId != '0121N000000uGX3QAM' AND 
                HOMEtracker__Property__r.RecordTypeId != '0121N000000uGX8QAM' AND 
                HOMEtracker__Property__r.Name != '' AND 
                HOMEtracker__Close_Date__c > 2020-01-01 AND 
                HOMEtracker__Close_Date__c <= :invDate AND 
                Date_Closing_Invoiced__c = NULL AND 
                HOMEtracker__Property__r.Development_address__r.TS1__r.Client_Type__c = 'Public' AND 
                Test_Service_File__c = false AND 
                (HOMEtracker__Status__c = 'Certified - Pending Closing' OR 
                HOMEtracker__Status__c = 'Certified - Pending Final Documents' OR 
                HOMEtracker__Status__c = 'Current Owner')
            ];
            
        cMuniClosing = MuniClosing.size();
        IF(cMuniClosing == 0) { MuniClosing = NULL;}

    //Private Ownership Certs          
        PrivOwnCert = [
            SELECT Id
            FROM HOMEtracker__Service_File__c
            WHERE
                HOMEtracker__Property__r.Development_address__r.TS1__r.Id = :setupID AND
                Case_Number__c != '' AND
                HOMEtracker__Property__r.RecordTypeId != '0121N000000uGX3QAM' AND
                HOMEtracker__Property__r.RecordTypeId != '0121N000000uGX8QAM' AND
                HOMEtracker__Property__r.Name != '' AND
                Test_Service_File__c = false AND
                (HOMEtracker__Status__c = 'Certified - Pending Closing' OR
                HOMEtracker__Status__c = 'Certified - Pending Final Documents' OR
                HOMEtracker__Status__c = 'Current Owner') AND
                HOMEtracker__Property__r.Development_address__r.TS1__r.Client_Type__c = 'Private S' AND
                (Purchase_Agreement_Date__c <= :invDate OR HOMEtracker__Close_Date__c <= 2025-06-30) AND
                ((HOMEtracker__Close_Date__c > 2020-01-01 AND
                HOMEtracker__Close_Date__c <= :invDate AND
                Closing_Invoiced__c = false) OR
                ((HOMEtracker__Purchase_and_Sale_Contract_Executed__c >= 2023-07-01 OR
                Purchase_Agreement_Date__c >= 2023-07-01) AND Sale_Contract_Invoiced__c = ''))
                ];
                
        cPrivOwnCert = PrivOwnCert.size();
        IF(cPrivOwnCert == 0) { PrivOwnCert = NULL;}

    //AA Eligibilities                 
        AAElig = [
            SELECT Id
            FROM HOMEtracker__Service_File__c
            WHERE
                HOMEtracker__Property__r.Development_address__r.TS1__r.Id = :setupID AND
                Case_Number__c != '' AND
                Test_Service_File__c = false AND
                HOMEtracker__Property__r.Name != '' AND
                Eligibility_Date__c <= :invDate AND
                (RecordTypeId='012o00000003fYBAAY' OR HOMEtracker__Property__r.Development_address__r.TS1__r.Bill_Sale_Eligibilities__c = true) AND
                ((Eligibility_Date__c > 2020-01-01 AND Date_Invoiced__c = NULL) OR
                (Date_Application_Terminated_Withdrawn__c > 2020-01-01 AND Date_Invoice_Processed__c = NULL))
                ];
            
        cAAElig = AAElig.size();
        IF(cAAElig == 0) { AAElig = NULL;}

    //Assistance Apps                  
        AssistApps = [
            SELECT Id 
            FROM Program_Application__c
            WHERE
                Program__r.Municipality__r.AA_Muni_Svcs_Invoicing__r.Id = :setupID AND
                Assistance_Invoice_Date__c = NULL AND
                (Program__r.Billing_Structure__c = 'Flat Fee' OR
                Program__r.Billing_Structure__c = 'Hourly' OR
                Program__r.Billing_Structure__c = 'Other' OR
                Program__r.Billing_Structure__c = '') AND
                (Application_Status__c = 'With Muni Not Final' OR
                Application_Status__c = 'Muni sent check' OR
                Application_Status__c = 'Assistance Delivered') AND
                Application_Date__c > 2022-01-01 AND
                Date_Docs_Sent_to_Muni__c <= :invDate
                ];
            
        cAssistApps = AssistApps.size();
        IF(cAssistApps == 0) { AssistApps = NULL;}

    //Email list for landlord          
        EmailList = [
            SELECT Id
            FROM HOMETRACKER__Property__c
            WHERE
                Development_address__r.TS1__r.Id = :setupID AND
                Email_blast_to_interest_list__c = 'Sent' AND
                Email_Blast_Invoiced__c = NULL AND
                Flyers_Distributed__c >= 2024-01-01
            ];
            
        cEmailList = EmailList.size();
        IF(cEmailList == 0) { EmailList = NULL;}

    //HR Milestones                    
        HRMiles = [
            SELECT Id
            FROM Log_Entry__c
            WHERE
                HR_Case_File__r.Municipality__r.HR_Case_Invoicing__r.Id = :setupID AND
                Invoice_Needed__c = TRUE AND 
                Entry_Date__c > 2025-01-01 AND 
                Entry_Date__c <= :invDate 
            ];
            
        cHRMiles = HRMiles.size();
        IF(cHRMiles == 0) { HRMiles = NULL;}

    //Muni Activity Logs
        MuniAAlogs = [
            SELECT Id
            FROM AA_Log_Entry__c
            WHERE 
                Municipality__r.AA_Muni_Svcs_Invoicing__r.Id = :setupID AND
                Invoice_Entry__c !='Created' AND 
                Invoice_Entry__c !='Not Applicable' AND 
                Log_Date__c <= :invDate 
                ];
            
        cMuniAAlogs = MuniAAlogs.size();
        IF(cMuniAAlogs == 0) { MuniAAlogs = NULL;}

    //Recurring Flat Fees
        RecFlatFee1 = [
            SELECT ID
            FROM Contract
            WHERE 
                Recurring_Flat_Fee_1_TS__c = :setupID AND 
                Flat_Fee_1_Current__c = true 
                ];
            
        cRecFlatFee1 = RecFlatFee1.size();
        IF(cRecFlatFee1 == 0) { RecFlatFee1 = NULL;}
        
        RecFlatFee2 = [
            SELECT ID
            FROM Contract
            WHERE 
                Recurring_Flat_Fee_2_TS__c = :setupID AND 
                Flat_Fee_2_Current__c = true 
                ];
            
        cRecFlatFee2 = RecFlatFee2.size();
        IF(cRecFlatFee2 == 0) { RecFlatFee2 = NULL;}

        cRecFlatFeeBoth = cRecFlatFee1 +cRecFlatFee2 ;

    }

}