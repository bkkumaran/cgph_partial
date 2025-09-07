@ISTEST
public class InviteStepOneExtTest {
    private static testmethod void InviteStepOneExtTest(){
        
        Municipality__c objMuni = new Municipality__c();
        objMuni.Name = 'Test Muni';
        insert objMuni;
                    
       	HOMETRACKER__Property__c objProp = new HOMETRACKER__Property__c();
        objProp.name = 'Test Property';
        objProp.RecordTypeId = '012o00000003bU7AAI';
        objProp.Municipality_Name__c = objMuni.Id;
        insert objProp;
        
        PreApplicants__c objPreApp = new PreApplicants__c();
        objPreApp.name='test';
        Insert objPreApp;
        
        HOMEtracker__Service_File__c objSF = new HOMEtracker__Service_File__c();
        objSF.RecordTypeId = '012o00000003fYBAAY';
        objSF.Name = 'test SF';
        objSF.HOMEtracker__Property__c = objProp.Id;
        objSF.Pre_Applicant__c = objPreApp.Id;
        insert objSF;
        
        Application__c objApp = new Application__c();
        objApp.Name = 'Test';
        objApp.Pre_Applicant__c = objPreApp.Id;
        objApp.Property__c = objProp.Id;
        insert objApp;
        
        ApexPages.currentPage().getParameters().put('id', objApp.id);
        ApexPages.StandardController stdSF = new ApexPages.StandardController(objApp);
        InviteStepOneExt objInviteStepOneExt  = new InviteStepOneExt(stdSF);
        
        
    }
}