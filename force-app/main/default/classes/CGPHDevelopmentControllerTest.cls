@isTest
private class CGPHDevelopmentControllerTest {
    static testMethod void myUnitTest()
    {
    	
       CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPHTestFactory.createCGPHProfileCustomSettings();
      	//Object creation using helper class
		Income_Limits__c r1IncomeLimit = CGPHTestFactory.createIncomeLimit('1');
		Income_Limits__c r2IncomeLimit = CGPHTestFactory.createIncomeLimit('2');
		Income_Limits__c r3IncomeLimit = CGPHTestFactory.createIncomeLimit('3');
		Income_Limits__c r4IncomeLimit = CGPHTestFactory.createIncomeLimit('4');
		Income_Limits__c r5IncomeLimit = CGPHTestFactory.createIncomeLimit('5');
		Income_Limits__c r6IncomeLimit = CGPHTestFactory.createIncomeLimit('6');
		
		PreApplicants__c applicant1 = CGPHTestFactory.createPreapplicant(true,false,true);
       
       
        Municipality__c objmunicipality1 = CGPHTestFactory.createMunicipalityObject('Township1','1',false,false,'All AR','All AR',true,true,0,'Moderate;Low;Very Low','Moderate;Low;Very Low');//condition1
		Municipality__c objmunicipality2 = CGPHTestFactory.createMunicipalityObject('Township2','2',true,true,'All AR','All AR',true,true,0,'Moderate;Low','Moderate;Low');//condition2
		Municipality__c objmunicipality3 = CGPHTestFactory.createMunicipalityObject('Township3','3',true,true,'All AR','All AR',false,false,0,'Low','Low');//condition3
		Municipality__c objmunicipality4 = CGPHTestFactory.createMunicipalityObject('Township4','4',true,true,'No AR','No AR',false,false,0,'Moderate','Moderate');//condition4
		Municipality__c objmunicipality5 = CGPHTestFactory.createMunicipalityObject('Township5','5',true,true,'','',false,false,41000,'Moderate','Moderate');//condition5
		Municipality__c objmunicipality6 = CGPHTestFactory.createMunicipalityObject('Township6','6',true,true,'No AR','No AR',false,false,41000,'Very Low','Very Low');//condition6
		Municipality__c objmunicipality7 = CGPHTestFactory.createMunicipalityObject('Township7','5',true,true,'','',false,false,4000,'Low','Low');
	
		CGPHTestFactory.createProperty(objmunicipality1.id,'Rental Unit','Available For Rent');
		CGPHTestFactory.createProperty(objmunicipality1.id,'Homeownership','Available for Sale/Resale');
		
		CGPHTestFactory.createProperty(objmunicipality1.id,'Rental Unit','Available For Rent');
		CGPHTestFactory.createProperty(objmunicipality1.id,'Homeownership','Available for Sale/Resale');
		
		CGPHTestFactory.createProperty(objmunicipality2.id,'Rental Unit','Available For Rent');
		CGPHTestFactory.createProperty(objmunicipality2.id,'Homeownership','Available for Sale/Resale');
		
		HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality3.id,'Rental Unit','Available For Rent');
		CGPHTestFactory.createProperty(objmunicipality3.id,'Homeownership','Available for Sale/Resale');

		
		CGPHDevelopmentController cntrl = new CGPHDevelopmentController();
        cntrl.strDevelopmentId = property.id;
        cntrl.getDevelopmentInfo();

    }
}