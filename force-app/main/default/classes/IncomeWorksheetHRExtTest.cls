@istest
public class IncomeWorksheetHRExtTest {
    private static testmethod void IncomeWorksheetHRExtTest(){    	
    	HOMEtracker__Service_File__c objServiceFile = new HOMEtracker__Service_File__c();
		objServiceFile.Name = 'Test';
		insert objServiceFile;
        objServiceFile.Name = 'Test';
        
				
		ApexPages.currentPage().getParameters().put('id', objServiceFile.id);
		ApexPages.StandardController stdSF = new ApexPages.StandardController(objServiceFile);
	    IncomeWorksheetHRExt objIncomeWorksheetHRext  = new IncomeWorksheetHRExt(stdSF);
        
        objIncomeWorksheetHRext.saveIS();
}
}