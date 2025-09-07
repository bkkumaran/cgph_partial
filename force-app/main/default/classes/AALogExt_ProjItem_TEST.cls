@istest
public class AALogExt_ProjItem_TEST {
	private static testmethod void AALogExt_ProjItem_TEST(){
		
        Municipality__c objMuni = new Municipality__c();
		objMuni.Name = 'Test Muni';
		insert objMuni;
        
        Project_Item__c objItem = new Project_Item__c();
        objItem.Name = 'TEST';
        objItem.Project_Category__c = 'New Client Setup';
        objItem.Status__c = 'Active';
        objItem.Municipality__c = objMuni.Id;
        insert objItem;

		ApexPages.currentPage().getParameters().put('id', objItem.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objItem);
	    AALogExt_ProjItem AALogExt_ProjItem_TEST  = new AALogExt_ProjItem(std);

    }
}