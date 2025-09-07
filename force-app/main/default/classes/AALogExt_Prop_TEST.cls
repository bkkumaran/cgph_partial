@istest
public class AALogExt_Prop_TEST {
	private static testmethod void AALogExt_Prop_TEST(){
		
        Municipality__c objMuni = new Municipality__c();
		objMuni.Name = 'Test Muni';
		insert objMuni;
        
        HOMEtracker__Property__c objProp = new HOMEtracker__Property__c();
        objProp.Name = 'TEST';
        objProp.Municipality_Name__c = objMuni.Id;
        objProp.HOMEtracker__Status__c = 'Planned';
        insert objProp;

		ApexPages.currentPage().getParameters().put('id', objProp.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objProp);
	    AALogExt_Prop AALogExt_Prop_TEST  = new AALogExt_Prop(std);

    }
}