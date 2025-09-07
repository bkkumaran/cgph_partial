@istest
public class AALogExt_Monitoring_TEST {
	private static testmethod void AALogExt_Monitoring_TEST(){
		
        Municipality__c objMuni = new Municipality__c();
		objMuni.Name = 'Test Muni';
		insert objMuni;
        
		Monitoring_Project_Unit__c objMONT = new Monitoring_Project_Unit__c();
        objMONT.Name='test';
        objMONT.MR_Municipality__c = objMuni.id;
        insert objMONT;

		ApexPages.currentPage().getParameters().put('id', objMONT.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objMONT);
	    AALogExt_Monitoring AALogExt_Monitoring_TEST  = new AALogExt_Monitoring(std);

    }
}