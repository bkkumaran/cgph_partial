@istest
public class EAPage2nExtTest {
	private static testmethod void EAPage2nExtTest() {

        Campaign objCampaign = new Campaign();
        objCampaign.Name='Test';
		insert objCampaign;
        String CampID = objCampaign.id;
        
        Account newAccount = new Account();
        newAccount.Name = 'test account';
        insert newAccount;
        String acctID = newAccount.id;
        
        Contact newContact = new Contact();
        newContact.FirstName = 'John';
        newContact.LastName = 'Test';
        insert newContact;
        
        String contactID = newContact.Id;
        
    	CampaignMember objCampaignMember = new CampaignMember();
        objCampaignMember.ContactId = contactId;
        objCampaignMember.Status = 'Emailed';
        objCampaignMember.CampaignId = CampID;
		insert objCampaignMember;
        
		ApexPages.currentPage().getParameters().put('id', objCampaign.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objCampaign);
	    EAPage2nExt EAPage2nExtTest  = new EAPage2nExt(std);
	}
}