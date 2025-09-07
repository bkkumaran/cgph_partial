public with sharing class InvoiceExt {

    public String cID {get; set;}
    public String cName {get; set;}
    public List<Invoice__c> invList {get; set;}
    public List<Contract> theContract {get; set;}
    
    public InvoiceExt(ApexPages.StandardController controller) {
    
        cID = ApexPages.currentPage().getParameters().get('cID');
        invList = [SELECT Id, Name, Invoice_Image_URL__c, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Time_Paid_Unpaid__c, Days_Unpaid__c, Purchase_Order__c, Purchase_Order_URL__c, PO_Date_Sent__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c 
                   FROM Invoice__c
                   WHERE Salesforce_Contract__c=: cID
                   ORDER BY Name DESC];
        theContract = [SELECT Id, Name
                        FROM Contract
                        WHERE Id =: cID];
        cName = theContract[0].Name; 
    }

}