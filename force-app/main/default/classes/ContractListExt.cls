public with sharing class ContractListExt {

    public List<Contract> listAll {get; set;}
    public Integer AllSize {get; set;}
    Public String alpha {get; set;}
    
    public ContractListExt(ApexPages.StandardController controller) {
    
    alpha = apexpages.currentpage().getparameters().get('alpha');
       
    listAll = [SELECT Id, Account.Id, Name, Contract_Spreadsheet_URL__c, Account.Total_Past_Due_Acc__c, Associated_Opportunity__c, Total_Past_Due__c, Invoicing_Week__c,First_Letter_Calc__c, Staff_Rates__c, Contract_PDF_URL__c, Contract_PDF_Calc__c, PriorIdCalc__c, Contract_Spreadsheet__c
            FROM Contract
            WHERE ((Current_Billing_Status__c=: 'Active under Contract') OR (Current_Billing_Status__c=: 'Active without Contract')) AND First_Letter_Calc__c =:alpha
            ORDER BY Name ASC];
    
     AllSize = listAll.size();
    }
        public String[] getABC() {
        return new String[]{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};
    }
}