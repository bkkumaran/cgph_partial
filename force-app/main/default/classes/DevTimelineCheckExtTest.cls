@istest
public class DevTimelineCheckExtTest {
    private static testmethod void DevTimelineCheckExtTest() {
        Municipality__c objMuni = new Municipality__c();
        objMuni.Name = 'Test Muni';
        insert objMuni;
                    
       	HOMETRACKER__Property__c objProp = new HOMETRACKER__Property__c();
        objProp.name = 'Test Property';
        objProp.Municipality_Name__c = objMuni.Id;
        objProp.RecordTypeId = '012o00000003bU2AAI';
        insert objProp;
        
        ApexPages.currentPage().getParameters().put('id', objProp.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objProp);
	    DevTimelineCheckExt objDevTimelineCheckExt  = new DevTimelineCheckExt(std);
    }

}