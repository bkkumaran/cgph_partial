@isTest
public class PropertyInventoryControllerTest {
    static testMethod void PropertyInventoryControllerTest(){
        
        Municipality__c objMuni = new Municipality__c();
        	objMuni.Name = 'Test Muni';
        insert objMuni;
        
        HOMEtracker__Property__c objDev = new HOMEtracker__Property__c();
        	objDev.name = 'Test Dev';
        	objDev.Municipality_Name__c = objMuni.Id;
        	objDev.HOMEtracker__Status__c = 'Initial lease up in progress';
        	objDev.RecordTypeId = '012o00000003bU2AAI';
        insert objDev;
        
        HOMEtracker__Property__c objProp1 = new HOMEtracker__Property__c();
        	objProp1.name = 'Test Dev';
        	objProp1.Municipality_Name__c = objMuni.Id;
        	objProp1.HOMEtracker__Status__c = 'Available for Rent';
        	objProp1.RecordTypeId = '012o00000003bU7AAI';
        	objProp1.Development_address__c = objDev.Id;
        insert objProp1;
        
        HOMEtracker__Property__c objProp2 = new HOMEtracker__Property__c();
        	objProp2.name = 'Test Dev';
        	objProp2.Municipality_Name__c = objMuni.Id;
        	objProp2.HOMEtracker__Status__c = 'Available for Rent';
        	objProp2.RecordTypeId = '012o00000003bU7AAI';
        	objProp1.Development_address__c = objDev.Id;
        insert objProp2;
        
        ApexPages.currentPage().getParameters().put('d', objDev.Id);
        ApexPages.currentPage().getParameters().put('g', '1');
        PropertyInventoryController controller = new PropertyInventoryController();
        controller.save();
        controller.saveT();
        
        
    }
}