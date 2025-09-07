@ISTEST
public class OutreachTrackerControllerTest {
    private static testmethod void OutreachTrackerControllerTest(){
       Municipality__c objMuni = new Municipality__c();
        objMuni.Name = 'Test Muni';
        insert objMuni;
                    
       	HOMETRACKER__Property__c objDev = new HOMETRACKER__Property__c();
        objDev.name = 'Test Development';
        objDev.Municipality_Name__c = objMuni.Id;
        objDev.RecordTypeId='012o00000003bU2AAI';
        insert objDev;
        
        HOMETRACKER__Property__c objProp1 = new HOMETRACKER__Property__c();
        objProp1.name = 'Test Property';
        objProp1.Municipality_Name__c = objMuni.Id;
        objProp1.Development_address__c = objDev.id;
        objProp1.RecordTypeId='012o00000003bU7AAI';
        insert objProp1;

        HOMEtracker__Service_File__c objSF = new HOMEtracker__Service_File__c();
        objSF.RecordTypeId = '012o00000003fYBAAY';
        objSF.Name = 'test SF';
        objSF.HOMEtracker__Property__c = objProp1.Id;
        objSF.Priority__c=1;
        objSF.HOMEtracker__Status__c = 'Application in Process';
        objSF.Application_Workflow_Status__c ='Application Received - Waiting for Credit Results';
        insert objSF;
        
        Outreach_Tracking__c objOT = new Outreach_Tracking__c();
        objOT.Name = 'test';
        objOT.Tracker_Status__c = 'Primary';
        objOT.Service_File__c = objSF.Id;
        objOT.Property_Unit__c = objProp1.Id;
        insert objOT;
        
        Outreach_Tracking__c objOT2 = new Outreach_Tracking__c();
        objOT2.Name = 'test2';
        objOT2.Tracker_Status__c = 'Primary';
        objOT2.Service_File__c = objSF.Id;
        objOT2.Property_Unit__c = NULL;
        insert objOT2;
        
        
        ApexPages.currentPage().getParameters().put('d', objDev.Id);
        OutreachTrackerController controller = new OutreachTrackerController();
        controller.getotByProperty();
               
        
    }

}