@istest
public class IncomeWorksheetVPextTest {
    private static testmethod void IncomeWorksheetVPextTest(){    	
    	HOMEtracker__Service_File__c objServiceFile = new HOMEtracker__Service_File__c();
		objServiceFile.Name = 'Test';
		insert objServiceFile;
				
		ApexPages.currentPage().getParameters().put('id', objServiceFile.id);
		ApexPages.StandardController stdSF = new ApexPages.StandardController(objServiceFile);
	    IncomeWorksheetVPext objIncomeWorksheetVPext  = new IncomeWorksheetVPext(stdSF);
        
        objIncomeWorksheetVPext.saveIS();
		objIncomeWorksheetVPext.saveAsset();
		objIncomeWorksheetVPext.saveSF();
		objIncomeWorksheetVPext.save();
		objIncomeWorksheetVPext.reFresh();

}
}