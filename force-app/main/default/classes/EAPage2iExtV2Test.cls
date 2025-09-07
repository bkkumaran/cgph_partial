@istest
public class EAPage2iExtV2Test {
	private static testmethod void EAPage2iExtV2Test() {

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
        EAPage2iExtV2 EAPage2iExtV2Test  = new EAPage2iExtV2(std);
	}
}