@istest
public class HR_Payments_Ext_Test {
    private static testmethod void HR_Payments_Ext_Test() {
        Municipality__c objMuni = new Municipality__c();
        objMuni.Name = 'Test Muni';
        insert objMuni;
        
        HR_Program__c objProg = new HR_Program__c();
        objProg.Name = 'test Prog';
        objProg.RecordTypeId = '0123m000001g5jOAAQ';
        objProg.Municipality__c = objMuni.Id;
        insert objProg;
        
        HR_Case_File__c objHRCF = new HR_Case_File__c();
        objHRCF.Name = 'Test HRCF';
        objHRCF.Municipality__c = objMuni.id;
        objHRCF.Program_Name__c = objProg.id;
        insert objHRCF;
        
        HR_Contractor_Payment__c objPay = new HR_Contractor_Payment__c();
        objPay.HR_Case_File__c = objHRCF.Id;
        objPay.Approval_Date__c = Date.today();
        insert objPay;
        
        ApexPages.currentPage().getParameters().put('id', objHRCF.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objHRCF);
	    HR_Payments_Ext objHR_Payments_Ext  = new HR_Payments_Ext(std);
        
    }   
}