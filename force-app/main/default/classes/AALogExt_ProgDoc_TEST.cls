@istest
public class AALogExt_ProgDoc_TEST {
	private static testmethod void AALogExt_ProgDoc_TEST(){
		
        Municipality__c objMuni = new Municipality__c();
		objMuni.Name = 'Test Muni';
		insert objMuni;
        
        Program_Document__c objProgDoc = new Program_Document__c();
        objProgDoc.Name = 'TEST';
        objProgDoc.Municipality__c = objMuni.Id;
        insert objProgDoc;

		ApexPages.currentPage().getParameters().put('id', objProgDoc.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objProgDoc);
	    AALogExt_ProgDoc AALogExt_ProgDoc_TEST  = new AALogExt_ProgDoc(std);

    }
}