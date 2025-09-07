@istest
public class HRCaseFileExtTest {
Private static testmethod void HRCaseFileExtTest(){
    
    Municipality__c newMuni = new Municipality__c();
    newMuni.Name = 'TEST MUNI';
    insert newMuni;
    
    HR_Program__c newHRProg = new HR_Program__c();
    newHRProg.Name = 'Test Prog';
    newHRProg.Status__c = 'Active';
    newHRProg.Municipality__c = newMuni.Id;
    insert newHRProg;
    
    HR_Case_File__c newHRCF = new HR_Case_File__c();
    newHRCF.Name = 'TEST HRCF';
    newHRCF.Municipality__c = newMuni.Id;
    newHRCF.Program_Name__c = newHRProg.Id;
    insert newHRCF;
    
    Staff_Member__c newStaff = new Staff_Member__c();
    newStaff.Name = 'Test';
    insert newStaff;
    
    Log_Entry__c newLogEntry = new Log_Entry__c();
    newLogEntry.Description__c = 'TEST';
    newLogEntry.Entry_Date__c = date.TODAY();
    newLogEntry.Staff_Member__c = newStaff.Id;
    newLogEntry.HR_Case_File__c = newHRCF.Id;
    insert newLogEntry;
			
		ApexPages.currentPage().getParameters().put('id', newHRCF.id);
		ApexPages.StandardController std = new ApexPages.StandardController(newHRCF);
	    HRCaseFileExt objHRCaseFileExt  = new HRCaseFileExt(std);
        
        objHRCaseFileExt.save();
}
}