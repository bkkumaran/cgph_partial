@istest
public class OutreachListAAContTest {
    
    static testMethod void EdisonAHP_PropOnlyContTest(){
        Income_Limits__c r1IncomeLimit = CGPHTestFactory.createIncomeLimit('1');
        PreApplicants__c applicant1 = CGPHTestFactory.createPreapplicant(true,false,true);
        Municipality__c objmunicipality1 = CGPHTestFactory.createMunicipalityObject('Township1','1',false,false,'All AR','All AR',true,true,0,'Moderate;Low;Very Low','Moderate;Low;Very Low');//condition1
        HOMEtracker__Property__c development = CGPHTestFactory.createProperty(objmunicipality1.id,'Development','Available For Rent');
        HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality1.id,'Rental Unit','Available For Rent');
        property.Development_address__c = development.Id;
        update property;
        
        HOMEtracker__Service_File__c sf = new HOMEtracker__Service_File__c();
        insert sf;
            
        Outreach_Tracking__c ot = new Outreach_Tracking__c();
        ot.Date_CGPH_Added_Name__c = System.today();
        ot.Date_Marked_Primary__c = System.today();
        ot.Landlord_Developer_App_Sent__c = 'true';
        ot.Landlord_Developer_Deadline__c = System.today();
        ot.Landlord_Developer_Determination_Date__c = System.today();
        ot.Landlord_Developer_Determination__c = 'Approved';
        ot.Landlord_Developer_Last_Update__c = System.now();
        ot.Landlord_Developer_Notes__c = 'test';
        ot.Landlord_Developer_Tour__c = 'test';
        ot.Name = 'test name';
        ot.Property_Unit__c = property.id;
        ot.Service_File__c = sf.id;
        ot.Tracker_Status__c = 'Primary';
        ot.Unit__c = '1';
        insert ot;
        
        
        OutreachListAACont controller = new OutreachListAACont();
        String result = controller.result;
        
    }

}