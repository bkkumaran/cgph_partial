@istest
public class AALogExt_Case_TEST {
    private static testmethod void AALogExt_Case_TEST(){
		
        Municipality__c objMuni = new Municipality__c();
		objMuni.Name = 'Test Muni';
		insert objMuni;
        
        Case objCase = new Case();
        objCase.Status = 'New';
        objCase.Origin = 'Email';
        objCase.Municipality__c = objMuni.Id;
        insert objCase;

		ApexPages.currentPage().getParameters().put('id', objCase.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objCase);
	    AALogExt_Case AALogExt_Case_TEST  = new AALogExt_Case(std);

    }
}