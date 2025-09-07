/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class PropertyDetailsControllerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        // create data for testing
        
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
		CGPHTestFactory.createProperty(objmunicipality1.id,'Homeownership','Available for Sale/Resale');
		
		CGPHTestFactory.createProperty(objmunicipality2.id,'Rental Unit','Available For Rent - Immediate Occupancy');
		CGPHTestFactory.createProperty(objmunicipality2.id,'Homeownership','Available for Sale/Resale');
		
		HOMEtracker__Property__c property1 = CGPHTestFactory.createProperty(objmunicipality3.id,'Rental Unit','Available For Rent - Immediate Occupancy');
		CGPHTestFactory.createProperty(objmunicipality3.id,'Homeownership','Available for Sale/Resale');
		
		Campaign camp = CGPHTestFactory.createCampaign();
		property.Campaign__c = camp.id;
		update property; 
		
		Contact c = CGPHTestFactory.createContact();
		PreApplicants__c preApp = CGPHTestFactory.createPreapplicant(true, true,true);
		preApp.Property__c = property.id;
		preApp.Contact__c = c.id;
		update preApp;
		
		CampaignMember member = new CampaignMember();
		member.CampaignId = camp.id;
		member.ContactId = c.id;
		member.status = 'Emailed';
		insert member;
		
		PropertyDetailsController cntrl = new PropertyDetailsController();
		cntrl.preappId = preApp.id;
		cntrl.propertyId = property.id;
		
		cntrl.getPropertyDetails();
		
		//PropertyDetailsController.WrapperPropertyDetails innerCtrl = new PropertyDetailsController.WrapperPropertyDetails(property,preApp,'','','','');
		
    }
}