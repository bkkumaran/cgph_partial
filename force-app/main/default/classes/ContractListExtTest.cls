@istest
public class ContractListExtTest{
	private static testmethod void ContractListExtTest() {
        Account newAccount = new Account();
        newAccount.Name = 'test account';
        insert newAccount;
        
        String acctID = newAccount.id;
        
    	Contract objContract = new Contract();
		objContract.Name = 'test';
        objContract.StartDate = date.today();
        objContract.AccountId = acctID;
		insert objContract;
				
		ApexPages.currentPage().getParameters().put('id', objContract.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objContract);
	    ContractListExt objContractListExt  = new ContractListExt(std);
		
        objContractListExt.getABC();
	}
}