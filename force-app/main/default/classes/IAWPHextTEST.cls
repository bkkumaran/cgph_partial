@istest
public class IAWPHextTEST {
    private static testmethod void IAWPHextTEST(){    	
    	HOMEtracker__Service_File__c objServiceFile = new HOMEtracker__Service_File__c();
		objServiceFile.Name = 'Test';
		insert objServiceFile;
				
		ApexPages.currentPage().getParameters().put('id', objServiceFile.id);
		ApexPages.StandardController stdSF = new ApexPages.StandardController(objServiceFile);
	    IAWPHext objIAWPHext  = new IAWPHext(stdSF);
        
        objIAWPHext.saveIS();
		objIAWPHext.saveAsset();
		objIAWPHext.saveSF();
		objIAWPHext.save();
//		objIAWPHext.reFresh();

}
}