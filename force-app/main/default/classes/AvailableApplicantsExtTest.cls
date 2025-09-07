@istest
public class AvailableApplicantsExtTest {
private static testmethod void AvailableApplicantsExtTest() {
    
    Municipality__c objMuni = new Municipality__c();
        objMuni.Name = 'Test Muni';
        insert objMuni;
                    
       	HOMETRACKER__Property__c objProp = new HOMETRACKER__Property__c();
        objProp.name = 'Test Property';
        objProp.Municipality_Name__c = objMuni.Id;
        insert objProp;

        HOMEtracker__Service_File__c objSF = new HOMEtracker__Service_File__c();
        objSF.RecordTypeId = '012o00000003fYBAAY';
        objSF.Name = 'test SF';
        objSF.HOMEtracker__Property__c = objProp.Id;
        insert objSF;
        
        Outreach_Tracking__c objOT = new Outreach_Tracking__c();
        objOT.Name = 'test';
        objOT.Tracker_Status__c = 'Primary';
        objOT.Service_File__c = objSF.Id;
        objOT.Property_Unit__c = objProp.Id;
        insert objOT;
				
		ApexPages.currentPage().getParameters().put('id', objProp.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objProp);
	    AvailableApplicantsExt objAvailableApplicantsExtTest  = new AvailableApplicantsExt(std);
}
}