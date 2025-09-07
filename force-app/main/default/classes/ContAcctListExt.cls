public with sharing class ContAcctListExt {

    public List<Contract> listAll {get; set;}

    public Integer AllSize {get; set;}
    
    
    public ContAcctListExt(ApexPages.StandardController controller) {
       
    listAll = [SELECT Id, Name, Account_Name_Text__c , AccountId, Contract_Spreadsheet_URL__c, Invoicing_Week__c,First_Letter_Calc__c, Staff_Rates__c
            FROM Contract
            WHERE ((Current_Billing_Status__c=: 'Active under Contract') OR (Current_Billing_Status__c=: 'Active without Contract')) 
            ORDER BY Name ASC];
    
     AllSize = listAll.size();
    }
        public String[] getABC() {
        return new String[]{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    }
}