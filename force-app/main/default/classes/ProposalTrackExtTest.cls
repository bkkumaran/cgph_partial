@istest
public class ProposalTrackExtTest{
	private static testmethod void ProposalTrackExtTest() {
        Account newAccount = new Account();
        newAccount.Name = 'test account';
        insert newAccount;
        
        String acctID = newAccount.id;
        
    	Opportunity objOpportunity = new Opportunity();
		objOpportunity.Name = 'test';
        objOpportunity.CloseDate = date.today();
        objOpportunity.AccountId = acctID;
        objOpportunity.StageName = 'Lead';
		insert objOpportunity;
				
		ApexPages.currentPage().getParameters().put('id', objOpportunity.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objOpportunity);
	    ProposalTrackExt ProposalTrackExtTest  = new ProposalTrackExt(std);

        ProposalTrackExtTest.save();
        ProposalTrackExtTest.saveR();
	}
}