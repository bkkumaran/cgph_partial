@istest
public class InvWkExtTest {
    private static testmethod void InvWkExtTest() {
        
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
        
        ApexPages.currentPage().getParameters().put('id', objInv.id);
        ApexPages.StandardController std = new ApexPages.StandardController(objInv);
        InvWkExt objInvWkExt  = new InvWkExt(std);
        
    }    
    
}