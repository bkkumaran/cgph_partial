@istest
public class TrainAAExtTest {
    private static testmethod void TrainAAExtTest(){
		
        Training_Module__c objTM = new Training_Module__c();
		objTM.Name = '1234';
		insert objTM;
				
		ApexPages.currentPage().getParameters().put('id', objTM.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objTM);
	    TrainAAExt objTrainAAExtTest  = new TrainAAExt(std);
        
        objTrainAAExtTest.saveAll();

    }

    
    
}