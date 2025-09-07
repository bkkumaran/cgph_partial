@istest
public class AALogExt_Event_TEST {
	private static testmethod void AALogExt_Event_TEST(){
		
        Municipality__c objMuni = new Municipality__c();
		objMuni.Name = 'Test Muni';
		insert objMuni;
        
        HOMEtracker__Property__c objProp = new HOMEtracker__Property__c();
        objProp.Name = 'TEST';
        objProp.Municipality_Name__c = objMuni.Id;
        objProp.HOMEtracker__Status__c = 'Planned';
        insert objProp;
        
        HOMEtracker__Service_File__c objSF = new HOMEtracker__Service_File__c();
        objSF.Name = 'TEST';
        insert objSF;
        HOMEtracker__Monitoring_Event__c objEvent = new HOMEtracker__Monitoring_Event__c();
        objEvent.HOMEtracker__Monitoring_Event_Type__c = 'Other';
        objEvent.HOMEtracker__Service_File__c = objSF.id;
        objEvent.HOMEtracker__Status__c = 'Active';
        insert objEvent;

		ApexPages.currentPage().getParameters().put('id', objEvent.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objEvent);
	    AALogExt_Event AALogExt_Event_TEST  = new AALogExt_Event(std);

    }
}