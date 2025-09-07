@istest
public class MRprojExtTest {
    private static testmethod void MRprojExtTest() {
        Municipality__c objMuni = new Municipality__c();
		objMuni.Name = 'Test';
		insert objMuni;
				
		ApexPages.currentPage().getParameters().put('id', objMuni.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objMuni);
	    MRprojExt objMRprojExt  = new MRprojExt(std);
    }

}