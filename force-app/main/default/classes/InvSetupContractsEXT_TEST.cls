@istest
public class InvSetupContractsEXT_TEST {
	private static testmethod void InvSetupContractsEXT_TEST() {
        Account objAcct = new Account();
        objAcct.Name = 'test account';
        insert objAcct;
		
        TS_Contract__c objTS = new TS_Contract__c();
        objTS.Name='Test';
        objTS.Client_Type__c = 'Public';
        objTS.Related_Account__c = objAcct.Id;
        INSERT objTS;
		        
    	Contract objContract = new Contract();
		objContract.Name = 'test';
        objContract.Associated_TS_Contract_1__c = objTS.Id;
        objContract.StartDate = date.today();
        objContract.AccountId = objAcct.id;
		insert objContract;
				
		ApexPages.currentPage().getParameters().put('id', objTS.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objTS);
	    InvSetupContractsEXT objInvSetupContractsEXT  = new InvSetupContractsEXT(std);
		
	}
}