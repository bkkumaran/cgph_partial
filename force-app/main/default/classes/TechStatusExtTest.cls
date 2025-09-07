@istest
public class TechStatusExtTest {
	Private static testmethod void TechStatusExtTest(){
        Case objCase = new Case();
        objCase.Subject = 'test';
        objCase.Origin = 'email';


    ApexPages.StandardController stdCase = new ApexPages.StandardController(objCase);
    TechStatusExt objTechStatusExt = new TechStatusExt(stdCase);
   
    }
}