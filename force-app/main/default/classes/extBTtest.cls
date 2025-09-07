@istest
public class extBTtest {
    Private static testmethod void extBTtest(){

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
	    extBT objextBT  = new extBT(std);
        
        objextBT.saveBT();
        objextBT.saveBTA();
        objextBT.saveBTB();
        objextBT.saveBTC();
        objextBT.saveBTD();
        objextBT.saveBTE();
        objextBT.saveHR1();
        objextBT.saveHR2();
	}
}