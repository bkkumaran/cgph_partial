@ISTEST
public class OutreachTrackerExtTest {
    private static testmethod void OutreachTrackerExtTest(){
       Municipality__c objMuni = new Municipality__c();
        objMuni.Name = 'Test Muni';
        insert objMuni;
                    
       	HOMETRACKER__Property__c objDev = new HOMETRACKER__Property__c();
        objDev.name = 'Test Development';
        objDev.Municipality_Name__c = objMuni.Id;
        objDev.RecordTypeId='012o00000003bU2AAI';
        insert objDev;
        
        HOMETRACKER__Property__c objProp = new HOMETRACKER__Property__c();
        objProp.name = 'Test Property';
        objProp.Municipality_Name__c = objMuni.Id;
        objProp.Development_address__c = objDev.id;
        objProp.RecordTypeId='012o00000003bU7AAI';
        insert objProp;

        HOMEtracker__Service_File__c objSF = new HOMEtracker__Service_File__c();
        objSF.RecordTypeId = '012o00000003fYBAAY';
        objSF.Name = 'test SF';
        objSF.HOMEtracker__Property__c = objProp.Id;
        objSF.Priority__c=1;
        objSF.HOMEtracker__Status__c = 'Application in Process';
        objSF.Application_Workflow_Status__c ='Application Received - Waiting for Credit Results';
        insert objSF;
        
        Outreach_Tracking__c objOT = new Outreach_Tracking__c();
        objOT.Name = 'test';
        objOT.Tracker_Status__c = 'Primary';
        objOT.Service_File__c = objSF.Id;
        objOT.Property_Unit__c = objProp.Id;
        insert objOT; 

        ApexPages.currentPage().getParameters().put('id', objDev.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objDev);
	    OutreachTrackerExt objOutreachTrackerExtTest  = new OutreachTrackerExt(std);
        
        objOutreachTrackerExtTest.getotByProperty();
        objOutreachTrackerExtTest.save();
        
        
    }

}