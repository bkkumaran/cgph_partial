@istest
public class AssignmentsMuniEXT_TEST {
	private static testmethod void AssignmentsMuniEXT_TEST(){
    
    Municipality__c objMuni = new Municipality__c();
    objMuni.Name = 'Test Muni';
    insert objMuni;
     
    ApexPages.currentPage().getParameters().put('id', objMuni.id);
    ApexPages.StandardController std = new ApexPages.StandardController(objMuni);
    AssignmentsMuniEXT AssignmentsMuniEXT_TEST  = new AssignmentsMuniEXT(std);

    }
}