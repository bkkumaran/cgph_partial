@istest
public class MTFRextTest {
private static testmethod void MTFRextTest() {
    	Municipality__c objMuni = new Municipality__c();
		objMuni.Name = 'Test';
		insert objMuni;
    
        Monitoring_Trust_Fund_Report__c objMTFR = new Monitoring_Trust_Fund_Report__c();
		objMTFR.Name = 'Test';
    	objMTFR.MTF_Municipality__c = objMuni.Id;
		insert objMTFR;
				
		ApexPages.currentPage().getParameters().put('id', objMTFR.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objMTFR);
	    MTFRext objMTFRext  = new MTFRext(std);
    }
}