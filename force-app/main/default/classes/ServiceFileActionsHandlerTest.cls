@isTest
public class ServiceFileActionsHandlerTest 
{
    @testSetup
    public static void testData()
    {
        Test.startTest();
        //create municipality record
        Municipality__c municipality = new Municipality__c();
        municipality.Name='Test Municipality';
        insert municipality;
        
        //Create property
        Id devRecordTypeId = Schema.SObjectType.HOMEtracker__Property__c.getRecordTypeInfosByName().get('Homeownership').getRecordTypeId();
        
        HOMEtracker__Property__c property = new HOMEtracker__Property__c();
        property.RecordTypeId=devRecordTypeId;
        property.Name='123 test street';
        property.Municipality_Name__c=municipality.Id;
        property.Income_Level__c='Low';
        insert property;
        
        Contact objContact = new Contact();
        objContact.Firstname = 'Test';
        objContact.Lastname = 'Test';
        insert objContact;
        List<HOMEtracker__Service_file__C> lstSVF= new List<HOMEtracker__Service_file__C>();
        RecordType rt2 =[select id from RecordType where name='Homeownership' and SObjectType = 'HOMEtracker__Service_File__c'];
        HOMEtracker__Service_file__C svf = new HOMEtracker__Service_file__c();
        svf.Name = 'Test';
        svf.RecordType = rt2;
        svf.HOMEtracker__Status__c = 'Application in Process';
        svf.HOMEtracker__Applicant__c = objContact.Id;
        svf.HOMEtracker__Property__c = property.Id;
        svf.HOMEtracker__Annual_Income_Eligibility__c=25000 ;
        svf.Very_Low_Income_Limit__c=50000;
        svf.Low_Income_Limit__c=100000;
        svf.Moderate_Income_Limit__c=200000;
        
        lstSVF.add(svf);
        Insert svf;   
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest()
    {
        Test.startTest();
        HOMEtracker__Property__c property = [SELECT Id,Income_Level__c FROM HOMEtracker__Property__c LIMIT 1];
        property.Income_Level__c='Moderate';
        update property;
        
        HOMEtracker__Service_file__C svf=[SELECT Id,HOMEtracker__Annual_Income_Eligibility__c FROM HOMEtracker__Service_file__C LIMIT 1];
        update svf;
        
        property.Income_Level__c='Very Low';
        update property;
        svf.HOMEtracker__Annual_Income_Eligibility__c=25000 ;       
        update svf;
        
        Test.stopTest();
    }
    @isTest
    public static void unitTestRental()
    {
        Test.startTest();
        Municipality__c objmunicipality2 = CGPHTestFactory.createMunicipalityObject('Township2','2',true,true,'All AR','All AR',true,true,0,'Moderate;Low','Moderate;Low');//condition2
        Contact objContact = new Contact();
        objContact.Firstname = 'Test';
        objContact.Lastname = 'Test';
        insert objContact;
        
        HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality2.id,'Rental Unit','Available For Rent - Immediate Occupancy');
        Id devRecordTypeId = Schema.SObjectType.HOMEtracker__Service_file__C.getRecordTypeInfosByName().get('Rental').getRecordTypeId();
        HOMEtracker__Service_file__C svf1 = new HOMEtracker__Service_file__c();
        svf1.Name = 'Test';
        svf1.RecordTypeId = devRecordTypeId;
        svf1.HOMEtracker__Status__c = 'Current Renter';
        svf1.HOMEtracker__Applicant__c = objContact.Id;
        svf1.HOMEtracker__Property__c = property.Id;
        // lstSVF.add(svf1);
        insert svf1;
        
      //  svf1.
        Test.stopTest();
    }
}