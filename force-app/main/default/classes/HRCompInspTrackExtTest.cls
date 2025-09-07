@istest
public class HRCompInspTrackExtTest {
    Private static testmethod void HRCompInspTrackExtTest(){
        
    Municipality__c newMuni = new Municipality__c();
    newMuni.Name = 'TEST MUNI';
    insert newMuni;
    
    HR_Program__c newHRProg = new HR_Program__c();
    newHRProg.Name = 'Test Prog';
    newHRProg.Status__c ='Active';
    newHRProg.Municipality__c = newMuni.Id;
    insert newHRProg;
    
    HR_Case_File__c newHRCF = new HR_Case_File__c();
    newHRCF.Name = 'TEST HRCF';
    newHRCF.Municipality__c = newMuni.Id;
    newHRCF.Program_Name__c = newHRProg.Id;
    insert newHRCF;
			
		ApexPages.currentPage().getParameters().put('id', newHRCF.id);
		ApexPages.StandardController std = new ApexPages.StandardController(newHRCF);
	    HRCompInspTrackExt objHRCompInspTrackExt  = new HRCompInspTrackExt(std);
        objHRCompInspTrackExt.save();
        
        
    }
}