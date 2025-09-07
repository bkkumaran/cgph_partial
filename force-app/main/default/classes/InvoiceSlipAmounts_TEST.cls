@ISTEST
public class InvoiceSlipAmounts_TEST {
   
    private static testmethod void InvoiceSlipAmounts_TEST(){
        
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
        
        Invoice_Entry__c objSlip = new Invoice_Entry__c();
        objSlip.Invoice_Record__c = objInv.Id;
        objSlip.Invoice_Setup__c = objTS.Id;
        objSlip.Date__c = date.today();
        objSlip.Amount__c= 100.00;
        INSERT objSlip;
        
        InvoiceSlipAmounts InvoiceSlipAmounts_TEST  = new InvoiceSlipAmounts();
    }

}