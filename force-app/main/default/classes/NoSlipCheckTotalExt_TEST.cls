@ISTEST
public class NoSlipCheckTotalExt_TEST {
	private static testmethod void NoSlipCheckTotalExt_TEST(){
        
        Account objAcct = new Account();
        objAcct.Name = 'Test';
        INSERT objAcct;
        
        TS_Contract__c objTS = new TS_Contract__c();
        objTS.Name='Test';
        objTS.Client_Type__c = 'Public';
        objTS.Related_Account__c = objAcct.Id;
        INSERT objTS;
        
       	ApexPages.currentPage().getParameters().put('id', objTS.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objTS);
	    NoSlipCheckTotalExt NoSlipCheckTotalExt_TEST  = new NoSlipCheckTotalExt(std);
    }
}