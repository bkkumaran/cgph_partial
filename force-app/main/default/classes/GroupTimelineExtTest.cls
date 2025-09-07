@istest
public class GroupTimelineExtTest {
    private static testmethod void GroupTimelineExtTest() {
        
        Municipality__c objMuni = new Municipality__c();
        objMuni.Name = 'Test Muni';
        insert objMuni;
                    
       	HOMETRACKER__Property__c objProp = new HOMETRACKER__Property__c();
        objProp.name = 'Test Property';
        objProp.Municipality_Name__c = objMuni.Id;
        insert objProp;
        
        ApexPages.currentPage().getParameters().put('id', objProp.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objProp);
	    GroupTimelineExt GroupTimelineExtTest  = new GroupTimelineExt(std);
        
        GroupTimelineExtTest.save();
        
    }
}