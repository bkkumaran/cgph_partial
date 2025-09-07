@ISTEST
public class InvoicePreviewExt_TEST {

    private static testmethod void InvoicePreviewExt_TEST(){
    
        Account objAcct = new Account();
        objAcct.Name = 'Test';
        INSERT objAcct;
        
        TS_Contract__c objTS = new TS_Contract__c();
        objTS.Name='Test';
        objTS.Client_Type__c = 'Public';
        objTS.Related_Account__c = objAcct.Id;
        INSERT objTS;
        
        Contract objContract = new Contract();
    	objContract.Name = 'test';
        objContract.StartDate = date.today();
        objContract.AccountId = objAcct.Id;
   	 	insert objContract;
             
        Invoice__c objInv = new Invoice__c();
        objInv.Name = '11111';
        objInv.Invoice_Date__c = date.today();
        objInv.Invoice_Amount__c = 1;
        objInv.Salesforce_Contract__c = objContract.Id;
        INSERT objInv;

		Invoice_Entry__c objIE = new Invoice_Entry__C();
        objIE.Invoice_Setup__c = objTS.Id;
        objIE.Invoice_Record__c = objInv.Id;
        INSERT objIE;
        
        Invoice_Entry__c objIE2 = new Invoice_Entry__C();
        objIE2.Invoice_Setup__c = objTS.Id;
        objIE2.Invoice_Record__c = objInv.Id;
        objIE2.Do_Not_Bill__c = true;
        INSERT objIE2;
        
        
   		ApexPages.currentPage().getParameters().put('id', objInv.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objInv);
	    InvoicePreviewExt InvoicePreviewExt_TEST  = new InvoicePreviewExt(std);
    }
    
}