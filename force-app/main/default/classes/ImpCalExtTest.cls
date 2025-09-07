@istest
public class ImpCalExtTest {
	private static testmethod void ImpCalExtTest() {

    	case objCase = new Case();
		objCase.Status = 'test';
        objCase.Origin = 'email';
		insert objCase;
				
		ApexPages.currentPage().getParameters().put('id', objCase.id);
		ApexPages.StandardController std = new ApexPages.StandardController(objCase);
	    ImpCalExt objImpCalExt  = new ImpCalExt(std);
		
        objImpCalExt.getMod();
        objImpCalExt.save();
	}
}