@istest
public class ImpTickExtTest {
    private static testmethod void ImpTickExtTest(){    	
    	case objCase = new case();
		objCase.Subject = 'Test';
        objCase.Status = 'New';
        objCase.Origin = 'Email';
		insert ObjCase;
        

		ApexPages.currentPage().getParameters().put('id', objCase.id);
		ApexPages.StandardController stdCase = new ApexPages.StandardController(objCase);
	    ImpTickExt objImpTickExt  = new ImpTickExt(stdCase);
        objImpTickExt.getX='1';
        objImpTickExt.save();
        objImpTickExt.getX='2';
        objImpTickExt.save();
        objImpTickExt.getX='3';
        objImpTickExt.save();
        objImpTickExt.getX='4';
        objImpTickExt.save();
        objImpTickExt.getX='5';
        objImpTickExt.save();
}
}