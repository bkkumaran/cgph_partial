@isTest
public class CGPHTestFactory{
    public static Income_Limits__c createIncomeLimit(String strRegion){
        Income_Limits__c iLimit = new Income_Limits__c();
        iLimit.X1_Person__c = 59095;
        iLimit.X2_Person__c = 67538;
        iLimit.X3_Person__c = 75980;
        iLimit.X4_Person__c = 84422;
        iLimit.X5_Person__c = 91176;
        iLimit.X6_Person__c = 97930;
        iLimit.X7_Person_Median__c = 104684;
        iLimit.X8_Person_Median__c = 111438;
        iLimit.Region__c = strRegion;
        insert iLimit;
        return iLimit;
    }
    
    public static PreApplicants__c createPreapplicant(boolean b_ArPropOnly, boolean b_HH55, boolean b_HDisabled){
        //create contact
        Contact con = new Contact();
        con.FirstName='FirstName';
        con.LastName='LastName';
        insert con;
        
        PreApplicants__c applicant1 = new PreApplicants__c();
        applicant1.Last_Profile_View__c = datetime.now().addHours(-5);
        applicant1.Contact__c=con.Id;
        applicant1.Name = 'Test1';
        applicant1.Last_Name__c = 'Person';
        applicant1.Email__c = 'test@test.com';
        applicant1.City__c = 'TestCity';
        applicant1.Phone__c = '1234567890';
        applicant1.Postal_Code__c = '12345';
        applicant1.Street__c = 'TestStreet';
        applicant1.State__c = 'TestState'; 
        applicant1.Most_Recent_Update__c = Datetime.now();
        applicant1.AR_Properties_Only__c = b_ArPropOnly;
        applicant1.Live_Work_Regions__c = '1;2;3;4;5;6';
        applicant1.Annual_Income__c = 28000;
        applicant1.Monthly_Other_Assistance__c = 1000;
        applicant1.Rental_Interest__c = true;
        applicant1.Purchase_Interest__c = true;
        applicant1.Household_Members_55__c = b_HH55;
        applicant1.Household_Disabled__c = b_HDisabled;
        applicant1.Section_8__c = false;
        applicant1.Household_Size__c = '2';
        applicant1.Max_Down_Payment__c = 1345;
        insert applicant1;
        return applicant1;
    }
    
    public static Municipality__c createMunicipality(){
        Municipality__c municipality1 = new Municipality__c();
        municipality1.Name = 'Township1';
        municipality1.AR_Rental_Properties__c =  'All AR';
        municipality1.Min_Income__c = 41000;
        municipality1.Region__c = '1';
        municipality1.Rental_Portfolio__c = true;
        municipality1.Purchase_Portfolio__c = true;
        municipality1.Rental_Portfolio_Income_Levels__c = 'Moderate;Low';
        municipality1.Rental_Unit_Size__c = '1';
        municipality1.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality1.Rental_Units__c = 5;
        municipality1.Rental_Waiting_List_Type__c = 'Random Selection';
        municipality1.Rental_Permanent_Disability_AR_Exception__c = false;
        municipality1.Live_Work_Preference__c = true;
        municipality1.AR_Purchase_Properties__c = 'All AR';
        municipality1.Purchase_Portfolio_Income_Levels__c = 'Moderate;Low';
        municipality1.Purchase_Unit_Size__c = '1';
        municipality1.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality1.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality1.Purchase_Units__c = 5;
        municipality1.Purchase_Permanent_Disability_AR_Excepti__c = false;
        // create income limit on municipality
        Income_Limits__c incomeLimit = new Income_Limits__c();
        incomeLimit = CGPHTestFactory.createIncomeLimit('1');
        municipality1.Income_Limit__c = incomeLimit.id;
        insert municipality1;
        return municipality1;
    }
   
     public static Municipality__c createMunicipalityObject(String strMunicipalityName, String strRegion, boolean b_RentalPortfolio, boolean b_PurchasePortfolio, String strARRentalProp, String strARPurchaseProp , boolean b_RentPermanDisableARExcepti, boolean b_PurPermanDisableARExcepti, double minIncome,String strRentalLevel, String strPurchaseLevel ){
        Municipality__c municipality1 = new Municipality__c();
        municipality1.Name = strMunicipalityName;
        municipality1.AR_Rental_Properties__c = strARRentalProp;// 'All AR';
        municipality1.Min_Income__c = minIncome;//41000;
        municipality1.Region__c = strRegion;
        municipality1.Rental_Portfolio__c = b_RentalPortfolio;//true;
        municipality1.Purchase_Portfolio__c = b_PurchasePortfolio;//true;
        municipality1.Rental_Portfolio_Income_Levels__c = strRentalLevel;
        municipality1.Rental_Unit_Size__c = '1';
        municipality1.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality1.Rental_Units__c = 5;
        municipality1.Rental_Waiting_List_Type__c = 'Random Selection';
        municipality1.Rental_Permanent_Disability_AR_Exception__c = b_RentPermanDisableARExcepti;//false;
        municipality1.Live_Work_Preference__c = true;
        municipality1.AR_Purchase_Properties__c = strARPurchaseProp;//'All AR';
        municipality1.Purchase_Portfolio_Income_Levels__c = strPurchaseLevel;
        municipality1.Purchase_Unit_Size__c = '1';
        municipality1.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality1.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality1.Purchase_Units__c = 5;
        municipality1.Equalization_Ratio__c = 2.1;
        municipality1.General_Tax_Rate__c = 5.2;
        
        municipality1.Purchase_Permanent_Disability_AR_Excepti__c = b_PurPermanDisableARExcepti;//false;
        
        // create income limit on municipality
        Income_Limits__c incomeLimit = new Income_Limits__c();
        incomeLimit = CGPHTestFactory.createIncomeLimit('2');
        municipality1.Income_Limit__c = incomeLimit.id;
        
        insert municipality1;
        return municipality1;
    }
    
    public static Municipality_Preference__c createMunicipalityPreference(Id municipalityId, Id applicationId, String strType){
        Municipality_Preference__c municipalityPreference1 = new Municipality_Preference__c();
        municipalityPreference1.Name = 'TownshipPref1';
        municipalityPreference1.Municipality__c = municipalityId;
        municipalityPreference1.PreApplicant__c = applicationId; 
        municipalityPreference1.Status__c = 'Active';
        municipalityPreference1.Type__c = strType;
        insert municipalityPreference1;
        return municipalityPreference1;
    }
    
    public static CGPH_Profile_Custom_Settings__c createCGPHProfileCustomSettings(){
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) 
        {
            if(cgphProfileSettings == null){
                cgphProfileSettings = new CGPH_Profile_Custom_Settings__c();
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Insurance_0_Bedroom__c = 30;
                cgphProfileSettings.Insurance_1_Bedroom__c = 30;
                cgphProfileSettings.Insurance_2_Bedroom__c = 30;
                cgphProfileSettings.Insurance_3_Bedroom__c = 30;
                cgphProfileSettings.Mortgage_Rate__c = 3.9800;
                cgphProfileSettings.PMI_Rate_for_LTV_80__c = 0.003200;
                cgphProfileSettings.PMI_Rate_for_LTV_85__c = 0.000000;
                cgphProfileSettings.PMI_Rate_for_LTV_90__c = 0.007800;
                cgphProfileSettings.PMI_Rate_for_LTV_95__c = 0.009000;
                cgphProfileSettings.To_Submit_PQ_Owner_Max_Hsg_vs_Exp__c= 40.00;
                cgphProfileSettings.Rental_Max_Hsg_v_expense_with_waiver__c = 45.00;
                cgphProfileSettings.Age_Rest_Rental_Max_Hsg_v_expense__c = 42.00;
                cgphProfileSettings.Family_Rental_Max_Hsg_v_expense__c = 37.00;
                cgphProfileSettings.Help_URL__c = 'https://www.affordablehomesnewjersey.com/';
                cgphProfileSettings.Encrypted_ID_Suffix__c = '0001';
                insert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
            }else{
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Insurance_0_Bedroom__c = 30;
                cgphProfileSettings.Insurance_1_Bedroom__c = 30;
                cgphProfileSettings.Insurance_2_Bedroom__c = 30;
                cgphProfileSettings.Insurance_3_Bedroom__c = 30;
                cgphProfileSettings.Mortgage_Rate__c = 3.9800;
                cgphProfileSettings.PMI_Rate_for_LTV_80__c = 0.003200;
                cgphProfileSettings.PMI_Rate_for_LTV_85__c = 0.000000;
                cgphProfileSettings.PMI_Rate_for_LTV_90__c = 0.007800;
                cgphProfileSettings.PMI_Rate_for_LTV_95__c = 0.009000;
                cgphProfileSettings.To_Submit_PQ_Owner_Max_Hsg_vs_Exp__c = 40.00;
                cgphProfileSettings.Rental_Max_Hsg_v_expense_with_waiver__c = 45.00;
                cgphProfileSettings.Age_Rest_Rental_Max_Hsg_v_expense__c = 42.00;
                cgphProfileSettings.Family_Rental_Max_Hsg_v_expense__c = 37.00;
                cgphProfileSettings.To_Pass_PQ_Waiver_Rent_Max_Hsg_vs_Exp__c = 45.00;
                cgphProfileSettings.To_Pass_PQ_Family_Rent_Max_Hsg_vs_Exp__c = 37.00;
                cgphProfileSettings.To_Pass_PQ_AR_Rent_Max_Hsg_vs_Exp__c = 42.00;
                cgphProfileSettings.Help_URL__c = 'https://www.affordablehomesnewjersey.com/';
                cgphProfileSettings.Encrypted_ID_Suffix__c = '0001';
                upsert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
            }
        }
        return cgphProfileSettings;
    }
    
    
    public static HOMEtracker__Property__c createProperty(Id municipalityId,string Type,string hometrackerStatus){
         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.HOMEtracker__Property__c ; 
        Map<String,Schema.RecordTypeInfo> PropertiesRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        string strPropertyRecTypeId = PropertiesRecordTypeInfo.get(Type).getRecordTypeId();
        
        HOMEtracker__Property__c property = new HOMEtracker__Property__c();
        property.Name = '123 Victoria Palace';
        property.HOMEtracker__Status__c = hometrackerStatus;
        property.Listing_Type__c = 'Public';
        property.Municipality_Name__c = municipalityId;
        property.Age_Restriction__c = '55+ exclusive';
        property.HOMEtracker__List_Price__c = 12345;
        property.HOMEtracker__Monthly_Rent__c = 12345;
        property.Income_Level__c = 'Very Low;Low;Moderate';
        property.Max_Income_Level__c = 'Very Low;Low;Moderate';
        property.HOMEtracker__Number_of_Bedrooms__c = '1';
        property.Maximum_Household_Size__c = 3;
        property.RecordTypeId = strPropertyRecTypeId;
        property.HOMEtracker__Property_Type__c = 'Single-Family Home';
        property.COAH_Regions__c = 'Sample';
        property.Unit_Mix__c = 'Sample';
        property.Affordability_restriction_del__c = 'Sample';
        property.Age_Restriction__c = 'Sample';
        property.HOMEtracker__Number_of_Stories__c = 'Sample';
        property.Credit_Check_Required__c = 'Sample';
        property.Background_Check_Required__c = 'Sample';
        property.Utilities_Included__c = 'Sample';
        property.Pets_allowed__c = 'Sample';
        property.Amenities__c = 'Sample';
        property.HOMEtracker__Interior__c = 'Sample';
        property.Property_Web_Listing__c = true;
        insert property; 
        return property;
    }
    
    // create application object record
    public static Application__c createApplication(id propertyId,Id preApplicantId)
    {
         Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Application__c ; 
        Map<String,Schema.RecordTypeInfo> ApplicationRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        string strApplicationRecTypeId = ApplicationRecordTypeInfo.get('Property Questionnaire').getRecordTypeId();
        Application__c application = new Application__c();
        application.Annual_Income__c = 20000;
        application.Current_Estimated_Property_Value__c = 90000;
        application.Currently_Owns_Real_Estate__c = true;
        application.Current_Mortgage__c = 2000;
        application.Current_Property_Taxes_Insurance__c = 2211;
        application.Savings_Gifts_Down_Payment__c =5000;
        application.Live_Work_Regions__c = '2;3;4';
        application.Rental_Interest__c = true;
        application.Purchase_Interest__c = true;
        application.Property__c = propertyId;
        application.Pre_Applicant__c = preApplicantId;
        application.RecordTypeId = strApplicationRecTypeId;
        insert application;
        return application;
    }
    
    
    // create campaign
    
    public static Campaign createCampaign()
    {
        Campaign testCampaign = new Campaign();
        testCampaign.Name = 'New Mailing Cmpaign';
        testCampaign.IsActive = true;
        insert testCampaign;
        return testCampaign;        
    }
    
    // create contact
    public static Contact createContact(){
        Contact con = new Contact();
        con.LastName = 'Test Last Name';
        con.Email = 'test@test.com';
        insert con;
        return con;    
    }
    
}