@istest
public class IncomeCalcExtTest {
	private static testmethod void IncomeCalcExtTest() {

        HOMEtracker__Service_File__c objSF = new HOMEtracker__Service_File__c();
		objSF.Name = 'test';
		insert objSF;
				
		ApexPages.currentPage().getParameters().put('id', objSF.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objSF);
	    IncomeCalcExt objIncomeCalcExt  = new IncomeCalcExt(std);
	
		objIncomeCalcExt.doShowSimple();
        objIncomeCalcExt.doShowYTD();
        objIncomeCalcExt.doShowPaystubs();
	}
}