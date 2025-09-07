@istest
public class AALogExt_Muni_TEST {
    private static testmethod void AALogExt_Muni_TEST(){
		
        Municipality__c objMuni = new Municipality__c();
		objMuni.Name = 'Test Muni';
		insert objMuni;
				
		ApexPages.currentPage().getParameters().put('id', objMuni.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objMuni);
	    AALogExt_Muni AALogExt_Muni_TEST  = new AALogExt_Muni(std);

    }
}