@isTest
public class ListingUtilityTest {
    @isTest
    public static void unitTest(){
        
        Municipality__c objmunicipality1 = CGPHTestFactory.createMunicipalityObject('Township1','1',false,false,'All AR','All AR',true,true,0,'Moderate;Low;Very Low','Moderate;Low;Very Low');
       PreApplicants__c applicant1 = CGPHTestFactory.createPreapplicant(true,false,true);
        Municipality_Preference__c rentalMunicipalPref1 = CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id, applicant1.id, 'Rental');
        rentalMunicipalPref1.General_Local__c=true;
        update rentalMunicipalPref1;
        HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality1.id,'Rental Unit','Available For Rent - Immediate Occupancy');
        
        //CGPHTestFactory.createProperty(objmunicipality1.id,'Homeownership','Available for Sale/Resale');
        Campaign camp = CGPHTestFactory.createCampaign();
        property.Campaign__c = camp.id;
        property.Local_Preference_for_Priority__c='General_Local__c';
        update property;
      
        
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
        
       ListingUtility.addCampaignMembers(property.Id,'10');
        
        Test.stopTest();
    }
}