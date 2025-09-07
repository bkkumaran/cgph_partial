@istest
public class HR_Case_Log_Ext_Test {
    Private static testmethod void HR_Case_Log_Ext(){
        
        Municipality__c newMuni = new Municipality__c();
        newMuni.Name = 'TEST MUNI';
        insert newMuni;
        
        HR_Program__c newHRProg = new HR_Program__c();
        newHRProg.Name = 'Test Prog';
        newHRProg.Status__c = 'Active';
        newHRProg.Municipality__c = newMuni.Id;
        insert newHRProg;
        
        HR_Case_File__c newHRCF = new HR_Case_File__c();
        newHRCF.Name = 'TEST HRCF 22';
        newHRCF.HR_Case_File_Numeral__c = 22;
        newHRCF.Municipality__c = newMuni.Id;
        newHRCF.Program_Name__c = newHRProg.Id;
        insert newHRCF;
        
        Log_Entry__c newLog = new Log_Entry__c();
        newLog.HR_Case_File__c = newHRCF.Id;
        newLog.Description__c = 'TEST';
        newLog.Entry_Date__c = Date.newInstance(2024, 10, 27);
        insert newLog;
        
        ApexPages.currentPage().getParameters().put('id', newHRCF.id);
        ApexPages.StandardController std = new ApexPages.StandardController(newHRCF);
        HR_Case_Log_Ext objHR_Case_Log_Ext  = new HR_Case_Log_Ext(std);
        
    }
    
}