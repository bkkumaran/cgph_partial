public with sharing class HRAppPoolCont {

    Public String dupeSH {get; set;}
    Public String termSH {get; set;}
    Public String caseSH {get; set;}
    Public String actSH {get; set;}
    Public String MuniId {get; set;}
    Public String flip {get; set;}
    Public Municipality__c Muni {get; set;}
    Public List<HR_Pre_App__c> PreApps {get; set;}
    Public Integer sizePreApps {get; set;}
    Public List<HR_Pre_App__c> revPreApps {get; set;}
    
    public HRAppPoolCont() {

        MuniId= apexpages.currentpage().getparameters().get('muni');
        actSH= apexpages.currentpage().getparameters().get('act');
        caseSH= apexpages.currentpage().getparameters().get('cf');
        termSH= apexpages.currentpage().getparameters().get('tm');
        dupeSH= apexpages.currentpage().getparameters().get('dp');
        flip= apexpages.currentpage().getparameters().get('flip');

        List<Municipality__c> findMuni = [SELECT Name FROM Municipality__c WHERE Id = :MuniId];
        Muni = findMuni.get(0);
        
        String txtACT = 'Active';
        String txtCF = 'Case File';
        String txtCFTM = 'Term: Case';
        String txtTM = 'Term: PreApp';
        String txtDP = 'Duplicate';
        
        IF (actSH == '1') {txtACT = '';}
        IF (caseSH == '1') {txtCF = '';txtCFTM='';}
        IF (termSH == '1') {txtTM = '';}
        IF (dupeSH == '1') {txtDP = '';}
        
        PreApps = [SELECT
                    Id,
                    Name,
                    Contact__r.Alt_Phone_Notes__c,
                    Contact__r.Alternate_Phone__c,
                    Contact__r.Contact_Cellphone__c,
                    Contact__r.Phone,
                    Contact__r.Phone_Notes__c,
                    Contact__r.FirstName,
                    Contact__r.LastName,
                    Contact__r.Name,
                    Contact__r.MailingCity,
                    Contact__r.MailingPostalCode,
                    Contact__r.MailingState,
                    Contact__r.MailingStreet,
                    Contact__r.HR_Email__c,
                    Contact__r.Email,
                    Pre_App_Status__c,
                    Case_File_Text__c,
                    Contact__c,
                    Waitlist_Number__c,
                    Application_Sent_Date__c,
                    Application_Sent_Method__c,
                    Co_op_or_Mobile_Home__c,
                    Comments__c,
                    Contact_Date__c,
                    Follow_Up__c,
                    Follow_Up_Adtl__c ,
                    Gross_Annual_Income__c,
                    Home_damaged_during_Sandy__c,
                    Household_Size__c,
                    How_Hear_Text__c,
                    HR_Case_File_Name_Calc__c,
                    HR_Case_File__c,
                    HR_Ranking__c,
                    HR_Rank_Calc__c,
                    HR_Rank_Order__c,
                    Howell_Sewer__c,
                    If_Yes_did_you_apply_to_FEMA__c,
                    If_yes_did_you_use_hmr_insurance__c,
                    Likely_Eligible__c,
                    Municipality__c,
                    Number_of_Units__c,
                    Occupied_year_round__c,
                    Owner_Occupied__c,
                    Receive_Sandy_Relief_from_Twp__c,
                    Repairs_Requested__c,
                    Restricted_affordable_when_purchased__c,
                    Single_or_Multi_Family__c,
                    Taxes_Current__c,
                    Year_Home_Built__c
                 FROM HR_Pre_App__c
                 WHERE Municipality__r.Id = :MuniId AND (
                     Pre_App_Status__c = :txtACT OR
                     Pre_App_Status__c = :txtCF OR
                     Pre_App_Status__c = :txtCFTM OR
                     Pre_App_Status__c = :txtTM OR
                     Pre_App_Status__c = :txtDP )
                 ORDER BY HR_Rank_Calc__c DESC];
            sizePreApps = PreApps.size();
            revPreApps = new list<HR_Pre_App__c>();
            
            for(Integer i = PreApps.size() - 1; i >= 0; i--){
            revPreApps.add(PreApps[i]);
}
            
            
    }

}