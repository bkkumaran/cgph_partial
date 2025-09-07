@istest
public class IncomeWorksheetVPPHextTest {
    private static testmethod void IncomeWorksheetVPPHextTest(){    	
    	HOMEtracker__Service_File__c objServiceFile = new HOMEtracker__Service_File__c();
		objServiceFile.Name = 'Test';
		insert objServiceFile;
				
		ApexPages.currentPage().getParameters().put('id', objServiceFile.id);
		ApexPages.StandardController stdSF = new ApexPages.StandardController(objServiceFile);
	    IncomeWorksheetVPPHext objIncomeWorksheetVPPHext  = new IncomeWorksheetVPPHext(stdSF);
        
        objIncomeWorksheetVPPHext.saveIS();
		objIncomeWorksheetVPPHext.saveAsset();
		objIncomeWorksheetVPPHext.saveSF();
		objIncomeWorksheetVPPHext.save();
		objIncomeWorksheetVPPHext.reFresh();

}
}