public with sharing class InvSetupContractsEXT {
    
    public List<Contract> listCont {get; set;}
    public Integer countCont {get; set;}
    Public String setupID {get; set;}
    
    public InvSetupContractsEXT(ApexPages.StandardController controller) {
        
        setupID = apexpages.currentpage().getparameters().get('id');
        
        listCont = [
            SELECT 
            Id,
            Account.Id,
            Name,
            Prior_Contract__r.Id,
            Contract_Spreadsheet_URL__c,
            Account.Total_Past_Due_Acc__c,
            Associated_Opportunity__c,
            Total_Past_Due__c,
            Contract_PDF_URL__c,
            Contract_PDF_Calc__c,
            Contract_Spreadsheet__c
            FROM Contract
            WHERE
            (Current_Billing_Status__c =: 'Active under Contract' OR
             Current_Billing_Status__c=: 'Active without Contract') AND
            (Associated_TS_Contract_1__c = :setupID OR
             Associated_TS_Contract_2__c = :setupID OR
             Associated_TS_Contract_3__c = :setupID OR
             Associated_TS_Contract_4__c = :setupID OR
             Associated_TS_Contract_5__c= :setupID)
            ORDER BY Name ASC
        ];
        
        countCont = listCont.size();
        IF(countCont == 0) {listCont = NULL;}
        
        
    }
    
}