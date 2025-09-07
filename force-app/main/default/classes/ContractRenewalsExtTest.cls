@istest
public with sharing class ContractRenewalsExtTest {
    private static testmethod void ContractRenewalsExtTest() {
        Account newAccount = new Account();
        newAccount.Name = 'test account';
        insert newAccount;
        
        String acctID = newAccount.id;
        
    	Contract objContract = new Contract();
		objContract.Name = 'test';
        objContract.StartDate = date.today() - 100;
        objContract.EndDate = date.today() - 50;
        objContract.AccountId = acctID;
		insert objContract;
				
		ApexPages.currentPage().getParameters().put('id', objContract.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objContract);
	    ContractRenewalsExt objContractRenewalsExt  = new ContractRenewalsExt(std);
		
        objContractRenewalsExt.getMonths();
        objContractRenewalsExt.save();
}
}