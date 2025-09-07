@istest
public class testRental_Service_After{
    Public Static testmethod void testRental_Service_After(){ 
   
   // new municipality
   Municipality__c objmunicipality1 = CGPHTestFactory.createMunicipalityObject('Township1','1',false,false,'All AR','All AR',true,true,0,'Moderate;Low;Very Low','Moderate;Low;Very Low');//condition1
   Municipality__c objmunicipality2 = CGPHTestFactory.createMunicipalityObject('Township2','2',true,true,'All AR','All AR',true,true,0,'Moderate;Low','Moderate;Low');//condition2
   
   
    Contact objContact = new Contact();
    objContact.Firstname = 'Test';
    objContact.Lastname = 'Test';
    insert objContact;
    
    RecordType rt =[select id from RecordType where name='Rental Unit'];
    RecordType rt2 =[select id from RecordType where name='Rental' and SObjectType = 'HOMEtracker__Service_File__c'];
     
      
    HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality2.id,'Rental Unit','Available For Rent - Immediate Occupancy');
	//CGPHTestFactory.createProperty(objmunicipality2.id,'Rental Unit','Available For Rent - Immediate Occupancy');
    
   /* Hometracker__Property__c objproperty = new HOMEtracker__Property__C();
    objProperty.Name = '123 Main st';
    objProperty.HOMEtracker__Status__c = 'Rented';
    objProperty.RecordType = rt;
    insert objProperty;*/
   
    HOMEtracker__Service_file__C svf = new HOMEtracker__Service_file__c();
    svf.Name = 'Test';
    svf.RecordType = rt2;
    svf.HOMEtracker__Status__c = 'Current Renter';
    svf.HOMEtracker__Applicant__c = objContact.Id;
    svf.HOMEtracker__Property__c = property.Id;
    Insert svf;  
    
    svf.HOMEtracker__Status__c = 'Past Renter';
    update svf;
    
    svf.HOMEtracker__Status__c = 'Current Renter';
    update svf;
    
    Contact objContact2 = new Contact();
    objContact2.Firstname = 'Test2';
    objContact2.Lastname = 'Test2';
    insert objContact2;
    
    svf.HOMEtracker__Applicant__C = objContact2.id;
    update svf;
    Test.startTest();
    svf.HOMEtracker__Status__c = 'Current Homeowner';
    svf.RecordType = rt2;
    update svf;
        
    HOMEtracker__Service_file__C svf2 = new HOMEtracker__Service_file__c();
    svf2.Name = 'Test';
    svf2.RecordType = rt2;
    svf2.HOMEtracker__Status__c = 'Current Owner';
    svf2.HOMEtracker__Applicant__C = objContact.Id;
    Insert svf2;      
    Test.stopTest();    
}

}