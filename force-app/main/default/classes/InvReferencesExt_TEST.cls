@ISTEST
public class InvReferencesExt_TEST {

    private static testmethod void InvReferencesExt_TEST(){
    
        Account objAcct = new Account();
        objAcct.Name = 'Test';
        INSERT objAcct;
        
        TS_Contract__c objTS = new TS_Contract__c();
        objTS.Name='Test';
        objTS.Client_Type__c = 'Public';
        objTS.Related_Account__c = objAcct.Id;
        INSERT objTS;
        
        Invoice_Reference__c objIR = new Invoice_Reference__c();
        objIR.name = 'test';
        objIR.Invoice_Setup__c = objTS.Id;
        INSERT objIR;
        
   		ApexPages.currentPage().getParameters().put('id', objTS.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objTS);
	    InvReferencesExt InvReferencesExt_TEST  = new InvReferencesExt(std);
        
        InvReferencesExt_TEST.save();

    }
}