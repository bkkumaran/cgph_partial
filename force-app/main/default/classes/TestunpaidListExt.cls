@istest
public class TestunpaidListExt {
    Private static testmethod void TestunpaidListExt(){
          
        Invoice__c objInvoice = new Invoice__c();
        objInvoice.name = '12345';
        objInvoice.Invoice_Date__c = Date.today();
        objInvoice.Sent_Date__c = Date.today();
        objInvoice.Invoice_Amount__c = 123.45;
        objInvoice.Purchase_Order__c = '17-12345';
        objInvoice.PO_Date_Sent__c = Date.today();
        objInvoice.Salesforce_Contract__c = '8001N000000Bs8I';

    ApexPages.currentPage().getParameters().put('AcctId',objInvoice.invoiceAccountID__c);
    ApexPages.StandardController stdInv = new ApexPages.StandardController(objInvoice);
    unpaidListExt objunpaidListExt = new unpaidListExt(stdInv);
    
    objunpaidListExt.getURLstring();
    objunpaidListExt.showFlowF();
    objunpaidListExt.showFlowT();
    
    }
}