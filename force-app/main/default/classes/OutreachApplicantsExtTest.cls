@ISTEST
public class OutreachApplicantsExtTest {
	static testMethod void OutreachApplicantsExtTest(){
    	
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

        Municipality__c objMuni = new Municipality__c();
        objMuni.Name = 'Test Muni';
        insert objMuni;
                    
       	HOMETRACKER__Property__c objProp = new HOMETRACKER__Property__c();
        objProp.name = 'Test Property';
        objProp.Municipality_Name__c = objMuni.Id;
        insert objProp;

		HOMEtracker__Service_File__c objSF = new HOMEtracker__Service_File__c();
        objSF.RecordTypeId = '012o00000003fYBAAY';
        objSF.Name = 'test SF';
        objSF.HOMEtracker__Property__c = objProp.Id;
        insert objSF;

        PreApplicants__c objPreApp = new PreApplicants__c();
        objPreApp.name='test';
        Insert objPreApp;
        
        Application__c objPS = new Application__c();
        objPS.Name = 'test';
        objPS.Pre_Applicant__c = objPreApp.Id;
        objPS.RecordTypeId = '012o000000048DLAAY';
        insert objPS;
        
		ApexPages.StandardController std = new ApexPages.StandardController(objProp);
	    OutreachApplicantsExt OutreachApplicantsExtTest  = new OutreachApplicantsExt(std);
	}
}