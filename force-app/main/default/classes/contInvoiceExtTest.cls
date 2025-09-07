@istest
public class contInvoiceExtTest {
	private static testmethod void contInvoiceExtTest() {

       	Account objAccount = new Account();
        objAccount.name = 'Test Account';
        insert objAccount;
        
        Contract objContract = new Contract();
        objContract.name = 'Test';
        objContract.AccountId = objAccount.Id;
        insert objContract;
				
		ApexPages.currentPage().getParameters().put('id', objContract.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objContract);
	    contInvoiceExt objcontInvoiceExt  = new contInvoiceExt(std);
		
    }
}