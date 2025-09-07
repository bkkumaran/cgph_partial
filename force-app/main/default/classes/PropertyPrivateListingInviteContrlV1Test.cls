/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 */
@isTest
private class PropertyPrivateListingInviteContrlV1Test {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        // create test data
        
         CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPHTestFactory.createCGPHProfileCustomSettings();
        //Object creation using helper class
    Income_Limits__c r1IncomeLimit = CGPHTestFactory.createIncomeLimit('1');
    Income_Limits__c r2IncomeLimit = CGPHTestFactory.createIncomeLimit('2');
    Income_Limits__c r3IncomeLimit = CGPHTestFactory.createIncomeLimit('3');
    Income_Limits__c r4IncomeLimit = CGPHTestFactory.createIncomeLimit('4');
    Income_Limits__c r5IncomeLimit = CGPHTestFactory.createIncomeLimit('5');
    Income_Limits__c r6IncomeLimit = CGPHTestFactory.createIncomeLimit('6');
    
    PreApplicants__c applicant1 = CGPHTestFactory.createPreapplicant(true,false,true);
       
       
        Municipality__c objmunicipality1 = CGPHTestFactory.createMunicipalityObject('Township1','1',false,false,'All AR','All AR',true,true,0,'Moderate;Low;Very Low','Moderate;Low;Very Low');//condition1
    Municipality__c objmunicipality2 = CGPHTestFactory.createMunicipalityObject('Township2','2',true,true,'All AR','All AR',true,true,0,'Moderate;Low','Moderate;Low');//condition2
    Municipality__c objmunicipality3 = CGPHTestFactory.createMunicipalityObject('Township3','3',true,true,'All AR','All AR',false,false,0,'Low','Low');//condition3
    Municipality__c objmunicipality4 = CGPHTestFactory.createMunicipalityObject('Township4','4',true,true,'No AR','No AR',false,false,0,'Moderate','Moderate');//condition4
    Municipality__c objmunicipality5 = CGPHTestFactory.createMunicipalityObject('Township5','5',true,true,'','',false,false,41000,'Moderate','Moderate');//condition5
    Municipality__c objmunicipality6 = CGPHTestFactory.createMunicipalityObject('Township6','6',true,true,'No AR','No AR',false,false,41000,'Very Low','Very Low');//condition6
    Municipality__c objmunicipality7 = CGPHTestFactory.createMunicipalityObject('Township7','5',true,true,'','',false,false,4000,'Low','Low');
  
    Municipality_Preference__c rentalMunicipalPref1 = CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id, applicant1.id, 'Rental');
    Municipality_Preference__c rentalMunicipalPref2 = CGPHTestFactory.createMunicipalityPreference(objmunicipality2.id, applicant1.id, 'Rental');
    Municipality_Preference__c rentalMunicipalPref3 = CGPHTestFactory.createMunicipalityPreference(objmunicipality3.id, applicant1.id, 'Rental');
    Municipality_Preference__c rentalMunicipalPref4 = CGPHTestFactory.createMunicipalityPreference(objmunicipality4.id, applicant1.id, 'Rental');
    Municipality_Preference__c rentalMunicipalPref5 = CGPHTestFactory.createMunicipalityPreference(objmunicipality5.id, applicant1.id, 'Rental');    
    //Municipality_Preference__c rentalMunicipalPref6 = CGPHTestFactory.createMunicipalityPreference(objmunicipality6.id, applicant1.id, 'Rental');
    
    
    Municipality_Preference__c purchaseMunicipalPref1 = CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id, applicant1.id, 'Ownership');
      Municipality_Preference__c purchaseMunicipalPref2 = CGPHTestFactory.createMunicipalityPreference(objmunicipality2.id, applicant1.id, 'Ownership');
      Municipality_Preference__c purchaseMunicipalPref3 = CGPHTestFactory.createMunicipalityPreference(objmunicipality3.id, applicant1.id, 'Ownership');
      Municipality_Preference__c purchaseMunicipalPref4 = CGPHTestFactory.createMunicipalityPreference(objmunicipality4.id, applicant1.id, 'Ownership');
      Municipality_Preference__c purchaseMunicipalPref5 = CGPHTestFactory.createMunicipalityPreference(objmunicipality5.id, applicant1.id, 'Ownership');
      //Municipality_Preference__c purchaseMunicipalPref6 = CGPHTestFactory.createMunicipalityPreference(objmunicipality6.id, applicant1.id, 'Ownership');
    
  
    HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality1.id,'Rental Unit','Available For Rent - Immediate Occupancy');
      
    CGPHTestFactory.createProperty(objmunicipality1.id,'Homeownership','Available for Sale/Resale');
    
    CGPHTestFactory.createProperty(objmunicipality1.id,'Rental Unit','Available For Rent - Immediate Occupancy');
    HOMEtracker__Property__c Property2 = CGPHTestFactory.createProperty(objmunicipality1.id,'Homeownership','Available for Sale/Resale');
    Property2.Listing_Type__c = 'Public';
    update Property2;
    
    HOMEtracker__Property__c Property3 = CGPHTestFactory.createProperty(objmunicipality1.id,'Homeownership','Available for Sale/Resale');
    Property3.Listing_Type__c = 'Public';
    update Property3;
    
    CGPHTestFactory.createProperty(objmunicipality2.id,'Rental Unit','Available For Rent - Immediate Occupancy');
    CGPHTestFactory.createProperty(objmunicipality2.id,'Homeownership','Available for Sale/Resale');
    
    HOMEtracker__Property__c property1 = CGPHTestFactory.createProperty(objmunicipality3.id,'Rental Unit','Available For Rent - Immediate Occupancy');
    CGPHTestFactory.createProperty(objmunicipality3.id,'Homeownership','Available for Sale/Resale');
    
    Campaign camp = CGPHTestFactory.createCampaign();
    property.Campaign__c = camp.id;
    update property;
        Property2.Campaign__c = camp.id;
        update Property2;
    
    Contact c = CGPHTestFactory.createContact();
    PreApplicants__c preApp = CGPHTestFactory.createPreapplicant(true, true,true);
    preApp.Property__c = property.id;
    preApp.Contact__c = c.id;
    update preApp;
    Test.startTest();
    Contact c1 = CGPHTestFactory.createContact();
    
    Campaign camp1 = CGPHTestFactory.createCampaign();
    CampaignMember member = new CampaignMember();
    member.ContactId = c1.id;
    member.CampaignId = camp1.id;
    insert member;
    
             
    ApexPages.currentPage().getParameters().put('id',property.id);
        
    CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id,preApp.id, 'Rental');
    
    PropertyPrivateListingInviteControllerV1 cntrl = new PropertyPrivateListingInviteControllerV1();
    
    // add campaign member 
    PropertyPrivateListingInviteControllerV1.addCampaignMembers(property.id,'10000');
    
    list<CampaignMember> lstMemberUpdate = new list<CampaignMember>();
    list<campaignMember> lstMembers = new list<CampaignMember>([select id,Status FROM CampaignMember WHERE CampaignId =: camp.id]);
    for( CampaignMember cMem : lstMembers)
    {
        CampaignMember updateMember = new CampaignMember(id=cMem.Id);
        updateMember.Status = 'Not Invited';
        lstMemberUpdate.add(updateMember);
    }   
    
    if(lstMemberUpdate != null && lstMemberUpdate.size() > 0)
    {
        update lstMemberUpdate;
    } 
    // get property details
    PropertyPrivateListingInviteControllerV1.getPropertyDetails(property.id);  
    
    // get member details
    try{
    PropertyPrivateListingInviteControllerV1.getMembersDetails(property.id,'10000');
    }catch(exception ex){}
    
    // get getStatusWiseMemberMap
    PropertyPrivateListingInviteControllerV1.getStatusWiseMemberMap(property.id);
    
    list<string> lstContactIds = new list<string>();
    lstContactIds.add(c.id);
    
    list<string> lstPreAppIds = new list<string>();
    lstPreAppIds.add(preApp.id);
    //send email action
    
    PropertyPrivateListingInviteControllerV1.sendEmail(camp.id,property.id,lstContactIds,'12/12/2016','Test outreach note',lstPreAppIds,'New Invite','Email');
        
    // method for follow up action
    PropertyPrivateListingInviteControllerV1.followUpAction(camp.id,property.id,lstContactIds,'12/12/2016','Test outreach note',lstPreAppIds,'Called','New Invite');
    
    string propertyId = property.id;
    // update campaign member method
    PropertyPrivateListingInviteControllerV1.updateCampaignMember(camp.id,lstContactIds,'Emailed',date.today(),'test outreachnote','Called',propertyId);
    
    // update campaign member method
    PropertyPrivateListingInviteControllerV1.updateCampaignMember(camp.id,lstContactIds,'Did Not Respond to Invite',date.today(),'test outreachnote','Called',propertyId);
    
    // select campaign member
    
    list<CampaignMember> lstMember = new list<CampaignMember>([SELECT id FROM CampaignMember]);
    
    string memberId;
    if(lstMember != null && lstMember.size() > 0)
    {
      memberId = lstMember[0].id;
      PropertyPrivateListingInviteControllerV1.getCampaignMember(memberId);
    }   
    
    
    // add campaign member 
    PropertyPrivateListingInviteControllerV1.addCampaignMembers(Property2.id,'10000');
    
    // get property details
    PropertyPrivateListingInviteControllerV1.getPropertyDetails(Property2.id);  
    
    try{
    // get member details
    PropertyPrivateListingInviteControllerV1.getMembersDetails(Property2.id,'10000'); 
    }catch(exception ex){
    system.debug('Error in test method '+ex);
    }
    
    // get getStatusWiseMemberMap
    PropertyPrivateListingInviteControllerV1.getStatusWiseMemberMap(Property2.id);
    
    // get email limit
    PropertyPrivateListingInviteControllerV1.getEmailLimits();
    
    // get custom settings
    PropertyPrivateListingInviteControllerV1.getPreAppTriggerSettings(); 
    
    // test create task method
    PropertyPrivateListingInviteControllerV1.createTask('This is test subject','This is test description',preApp.id);
    Test.stopTest();
    }
    
    public static testmethod void unitTest2()
    {
        
    }
}