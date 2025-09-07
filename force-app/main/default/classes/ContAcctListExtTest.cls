@istest
public class ContAcctListExtTest {
	private static testmethod void ContAcctListExtTest() {
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
	    ContAcctListExt objContAcctListExt  = new ContAcctListExt(std);
		
        objContAcctListExt.getABC();
	}

}