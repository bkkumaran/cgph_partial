@isTest
class CGPHProfileControllerTest{
    
    // public static Municipality__c createMunicipalityObject(boolean b_RentalPortfolio, boolean b_PurchasePortfolio, String strARRentalProp, String strARPurchaseProp , boolean b_RentPermanDisableARExcepti, boolean b_PurPermanDisableARExcepti, double minIncome){
    public static testmethod void testCGPHMunicipalities(){
    
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPHTestFactory.createCGPHProfileCustomSettings();
     
       //Object creation using helper class
        Income_Limits__c r1IncomeLimit = CGPHTestFactory.createIncomeLimit('1');
        Income_Limits__c r2IncomeLimit = CGPHTestFactory.createIncomeLimit('2');
        Income_Limits__c r3IncomeLimit = CGPHTestFactory.createIncomeLimit('3');
        Income_Limits__c r4IncomeLimit = CGPHTestFactory.createIncomeLimit('4');
        Income_Limits__c r5IncomeLimit = CGPHTestFactory.createIncomeLimit('5');
        Income_Limits__c r6IncomeLimit = CGPHTestFactory.createIncomeLimit('6');
        Map<id,Income_Limits__c> mapIncomeLimit = new Map<id,Income_Limits__c>();
        mapIncomeLimit.put(r6IncomeLimit.id,r6IncomeLimit);
        mapIncomeLimit.put(r5IncomeLimit.id,r5IncomeLimit);        
        
        PreApplicants__c applicant1 = CGPHTestFactory.createPreapplicant(true,false,true);
        list<PreApplicants__c> lstPreApplicant = new list<PreApplicants__c>();
        lstPreApplicant.add(applicant1);
        //encode applicant id
        Blob beforeblob = Blob.valueOf(applicant1.id+cgphProfileSettings.Encrypted_ID_Suffix__c);
        // base64 encode the blob that contains our url param value
        string paramvalue = EncodingUtil.base64Encode(beforeblob);
        
        ApexPages.currentPage().getParameters().put('appId',paramvalue);
        
        Municipality__c objmunicipality1 = CGPHTestFactory.createMunicipalityObject('Township1','1',false,false,'All AR','All AR',true,true,0,'Moderate;Low;Very Low','Moderate;Low;Very Low');//condition1
        Municipality__c objmunicipality2 = CGPHTestFactory.createMunicipalityObject('Township2','2',true,true,'All AR','All AR',true,true,0,'Moderate;Low','Moderate;Low');//condition2
        Municipality__c objmunicipality3 = CGPHTestFactory.createMunicipalityObject('Township3','3',true,true,'All AR','All AR',false,false,0,'Low','Low');//condition3
        Municipality__c objmunicipality4 = CGPHTestFactory.createMunicipalityObject('Township4','4',true,true,'No AR','No AR',false,false,0,'Moderate','Moderate');//condition4
        Municipality__c objmunicipality5 = CGPHTestFactory.createMunicipalityObject('Township5','5',true,true,'','',false,false,41000,'Moderate','Moderate');//condition5
        Municipality__c objmunicipality6 = CGPHTestFactory.createMunicipalityObject('Township6','6',true,true,'No AR','No AR',false,false,41000,'Very Low','Very Low');//condition6
        Municipality__c objmunicipality7 = CGPHTestFactory.createMunicipalityObject('Township7','5',true,true,'','',false,false,4000,'Low','Low');
        
        Municipality_Preference__c rentalMunicipalPref1 = CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id, applicant1.id, 'Rental');
        Municipality_Preference__c rentalMunicipalPref2 = CGPHTestFactory.createMunicipalityPreference(objmunicipality2.id, applicant1.id, 'Rental');
        Municipality_Preference__c rentalMunicipalPref3 = CGPHTestFactory.createMunicipalityPreference(objmunicipality3.id, applicant1.id, 'Rental');
        Municipality_Preference__c rentalMunicipalPref4 = CGPHTestFactory.createMunicipalityPreference(objmunicipality4.id, applicant1.id, 'Rental');
        Municipality_Preference__c rentalMunicipalPref5 = CGPHTestFactory.createMunicipalityPreference(objmunicipality5.id, applicant1.id, 'Rental');       
        //Municipality_Preference__c rentalMunicipalPref6 = CGPHTestFactory.createMunicipalityPreference(objmunicipality6.id, applicant1.id, 'Rental');
        
        
        Municipality_Preference__c purchaseMunicipalPref1 = CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id, applicant1.id, 'Ownership');
        Municipality_Preference__c purchaseMunicipalPref2 = CGPHTestFactory.createMunicipalityPreference(objmunicipality2.id, applicant1.id, 'Ownership');
        Municipality_Preference__c purchaseMunicipalPref3 = CGPHTestFactory.createMunicipalityPreference(objmunicipality3.id, applicant1.id, 'Ownership');
        Municipality_Preference__c purchaseMunicipalPref4 = CGPHTestFactory.createMunicipalityPreference(objmunicipality4.id, applicant1.id, 'Ownership');
        Municipality_Preference__c purchaseMunicipalPref5 = CGPHTestFactory.createMunicipalityPreference(objmunicipality5.id, applicant1.id, 'Ownership');
        //Municipality_Preference__c purchaseMunicipalPref6 = CGPHTestFactory.createMunicipalityPreference(objmunicipality6.id, applicant1.id, 'Ownership');
        
        
        //Custom Setting
        //CGPH_Triggers_Custom_Settings__c cgphTriggersSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
        list<user> lstUser = new list<user>([SELECT id FROM User Limit 1]);
       // CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) 
        {
                      
            if(cgphProfileSettings == null){
                cgphProfileSettings = new CGPH_Profile_Custom_Settings__c();
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
                cgphProfileSettings.Montaclair_Municipality_Id__c = objmunicipality1.id; 
                cgphProfileSettings.Hoboken_Municipality_Id__c = objmunicipality2.Id; 
                insert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
            }else{
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
                cgphProfileSettings.Montaclair_Municipality_Id__c = objmunicipality1.id; 
                cgphProfileSettings.Hoboken_Municipality_Id__c = objmunicipality2.Id;                 
                upsert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
            }
        }
        
        
        list<Municipality_Preference__c> lstPreferences = new list<Municipality_Preference__c>([select id from Municipality_Preference__c]);
        system.debug(' lstPreferences from test==>  '+lstPreferences);
        
        // create properties for municipalities
        
        CGPHTestFactory.createProperty(objmunicipality1.id,'Rental Unit','Available For Rent');
        CGPHTestFactory.createProperty(objmunicipality1.id,'Homeownership','Available for Sale/Resale');
        
        CGPHTestFactory.createProperty(objmunicipality2.id,'Rental Unit','Available For Rent');
        CGPHTestFactory.createProperty(objmunicipality2.id,'Homeownership','Available for Sale/Resale');
        
        HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality3.id,'Rental Unit','Available For Rent');
        CGPHTestFactory.createProperty(objmunicipality3.id,'Homeownership','Available for Sale/Resale');
        
        List<HOMEtracker__Property__c> lstRentalProperty= new List<HOMEtracker__Property__c>();
        lstRentalProperty.add(property);
            // create pre application record
        Application__c application = CGPHTestFactory.createApplication(property.id,applicant1.Id);
        
        CGPHProfileController cgphController = new CGPHProfileController();
        String appId = applicant1.Id;
        cgphController.strPreApplicantId=appId;
        cgphController.getPreApplicantDetails();
        cgphController.getPreApplicantDetails();
        cgphController.getListRentalMunicipality();
        cgphController.getListPurchaseMunicipality();
        cgphController.setProfileStatistics();
        cgphController.updatePreApplicantActive();
        
        // call rental calculation method using the application record
       // CGPHProfileController.calculateCriteriaForRental(lstRentalProperty,lstPreApplicant,cgphProfileSettings,mapIncomeLimit,applicant1,application,'UseToPassPQCustomSetting');
        
       // calculateCriteriaForRental(list<HOMEtracker__Property__c>lstRentalProperty,list<PreApplicants__c> lstPreApplicant,CGPH_Profile_Custom_Settings__c cgphProfileCustomSettings,map<id,Income_Limits__c> mapIncomeLimit,PreApplicants__c preApplicantsInfo,Application__c application,'UseToPassPQCustomSetting');
       
        apexpages.currentpage().getparameters().put('endPoint','https://www.affordablehomesnewjersey.com/?json=get_page&id=4774');
        cgphController.setEndpoint();
        //redirect to  page RentalMunicipalityPreference  
        //cgphProController.updateMunicipalityPreference();
        cgphController.getRentalTownshipPreferences();
        cgphController.getPurchaseTownshipPreferences();
        cgphController.getRentalProperties();
        
        cgphController.getPurchaseProperties();
        
        PageReference testPage = cgphController.updateMunicipalityPreference();//Page.RentalMunicipalityPreferences;
        //PageReference pageRef = ApexPages.getCurrentPage.getParameters().put('strMunicipalityId', objmunicipality3.id);
        //system.assertEquals('/apex/RentalMunicipalityPreferences?appId='+paramvalue,testPage.getUrl());
        Test.setCurrentPage(testPage);
        
        cgphController.strMunicipalityId = objmunicipality3.id;
        cgphController.removeRentalMunicipalityWaitingList();
        
        // join wating list for existing preference
        ApexPages.currentPage().getParameters().put('strMunicipalityId', objmunicipality3.id);
        cgphController.joinRentalMunicipalityWaitingList();
        
        // join wating list for new preference
        ApexPages.currentPage().getParameters().put('strMunicipalityId', objmunicipality6.id);
        cgphController.joinRentalMunicipalityWaitingList();
        
        cgphController.returnToCGPHProfile();
        
        appId = applicant1.Id;
        cgphController.strPreApplicantId=appId;
        
        //testPage.getParameters().put('appId', paramvalue);
        cgphController.strPropertyId  = property.id;
        cgphController.getPropertyInfo();
        // test for purchase preferences 
        testPage = cgphController.updateMunicipalityHomeOwnerPreference();//Page.RentalMunicipalityPreferences;
        //PageReference pageRef = ApexPages.getCurrentPage.getParameters().put('strMunicipalityId', objmunicipality3.id);
        //system.assertEquals('/apex/HomeownerMunicipalityPreferences?appId='+paramvalue,testPage.getUrl());
        Test.setCurrentPage(testPage);
        cgphController.strPreApplicantId = applicant1.Id;
        cgphController.strMunicipalityId = objmunicipality6.id;
        //cgphController.removeOwnershipMunicipalityWaitingList();
        cgphController.strMunicipalityId = objmunicipality6.id;
        Test.StartTest();
        cgphController.joinOwnershipMunicipalityWaitingList();
        cgphController.amiPercentage();
        cgphController.removeOwnershipMunicipalityWaitingList();
        ApexPages.currentPage().getParameters().put('strMunicipalityId',objmunicipality6.id);
        cgphController.pageName ='HomeownerMunicipalityPreferences' ;
        cgphController.showLocalModal();
        cgphController.createPreference();
        cgphController.saveLocalModal();  
        cgphController.closeLocalModal();
        cgphController.hideLocalModal();
        Test.StopTest();
              
    }
    
}