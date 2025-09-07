@ISTEST
public class InvoiceWorkbookController_TEST {
private static testmethod void InvoiceWorkbookController_TEST(){
        
    	Account objAcct = new Account();
        objAcct.Name = 'Test';
        INSERT objAcct;
    
    	Account objAcct2 = new Account();
        objAcct2.Name = 'Test2';
        INSERT objAcct2;
        
        TS_Contract__c objTS1 = new TS_Contract__c();
        objTS1.Name='Test1';
    	OBJts1.ActiveTS__c = TRUE;
        objTS1.Client_Type__c = 'Public';
        objTS1.Related_Account__c = objAcct.Id;
        INSERT objTS1;
    
    	TS_Contract__c objTS2 = new TS_Contract__c();
        objTS2.Name='Test2';
    	OBJts2.ActiveTS__c = TRUE;
        objTS2.Client_Type__c = 'Public';
        objTS2.Related_Account__c = objAcct2.Id;
        INSERT objTS2;

	ApexPages.currentPage().getParameters().put('limit', '5');    
    InvoiceWorkbookController InvoiceWorkbookController_TEST  = new InvoiceWorkbookController();
    }
}