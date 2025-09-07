@istest
public class AALogExt_Program_TEST {
	private static testmethod void AALogExt_Program_TEST(){
		
        Municipality__c objMuni = new Municipality__c();
		objMuni.Name = 'Test Muni';
		insert objMuni;
        
        HR_Program__c objProg = new HR_Program__c();
        objProg.Name = 'TEST';
        objProg.Municipality__c = objMuni.Id;
        objProg.Status__c = 'Active';
        insert objProg;

		ApexPages.currentPage().getParameters().put('id', objProg.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objProg);
	    AALogExt_Program AALogExt_Program_TEST  = new AALogExt_Program(std);

    }
}