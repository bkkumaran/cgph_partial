@istest
public class TrainExtTest {
    private static testmethod void TrainExtTest(){
		
        Training_Module__c objTM = new Training_Module__c();
		objTM.Name = '1234';
		insert objTM;
				
		ApexPages.currentPage().getParameters().put('id', objTM.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objTM);
	    TrainExt objTrainExtTest  = new TrainExt(std);
        
        objTrainExtTest.saveAll();

    }

    
    
}