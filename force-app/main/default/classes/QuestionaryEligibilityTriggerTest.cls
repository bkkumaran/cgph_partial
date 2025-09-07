/**
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class QuestionaryEligibilityTriggerTest {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
         //Custom Setting
        CGPH_Triggers_Custom_Settings__c cgphTriggersSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPHTestFactory.createCGPHProfileCustomSettings();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) 
        {
            
            if(cgphTriggersSettings == null){
                cgphTriggersSettings = new CGPH_Triggers_Custom_Settings__c();
                cgphTriggersSettings.Questionary_Eligibility_Checking__c = true;
                insert cgphTriggersSettings;
                System.assertNotEquals( cgphTriggersSettings.Id, null);
            }
            else{
                if(!cgphTriggersSettings.Questionary_Eligibility_Checking__c){
                    cgphTriggersSettings.Questionary_Eligibility_Checking__c = true;
                    upsert cgphTriggersSettings;
                }
            }
        }
        
        
        
         //Incomelimit object
        Income_Limits__c region1ILimit = new Income_Limits__c();
        region1ILimit.X1_Person__c = 59095;
        region1ILimit.X2_Person__c = 67538;
        region1ILimit.X3_Person__c = 75980;
        region1ILimit.X4_Person__c = 84422;
        region1ILimit.X5_Person__c = 91176;
        region1ILimit.X6_Person__c = 97930;
        region1ILimit.X7_Person_Median__c = 104684;
        region1ILimit.X8_Person_Median__c = 111438;
        region1ILimit.Region__c = '1';
        insert region1ILimit;
        
        Schema.DescribeSObjectResult cfrApplicationSchema = Schema.SObjectType.Application__c ; 
        Map<String,Schema.RecordTypeInfo> ApplicationRecordTypeInfo = cfrApplicationSchema.getRecordTypeInfosByName(); 
        string strApplicationRecTypeId = ApplicationRecordTypeInfo.get('Property Questionnaire').getRecordTypeId();
        
        Municipality__c objmunicipality1 = CGPHTestFactory.createMunicipalityObject('Township1','1',false,false,'All AR','All AR',true,true,0,'Moderate;Low;Very Low','Moderate;Low;Very Low');//condition1
        
        HOMEtracker__Property__c property1 = CGPHTestFactory.createProperty(objmunicipality1.id,'Rental Unit','Available For Rent - Immediate Occupancy');
        property1.Dev_Income_Limit__c = region1ILimit.id;
        update property1;
        
        HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality1.id,'Rental Unit','Available For Rent - Immediate Occupancy');
        property.Development_address__c = property1.id; 
        update property;
        // pre applicant
        PreApplicants__c preApp = new PreApplicants__c();
        preApp = CGPHTestFactory.createPreapplicant(true, true,true);
        
        //application object
        Application__c application = new Application__c();
        try{
        application = CGPHTestFactory.createApplication(property.id,preApp.id);
        }catch(Exception ex)
        {
            system.debug('Exception '+ex);
        }
       
         HOMEtracker__Property__c propertyHomeownership = CGPHTestFactory.createProperty(objmunicipality1.id,'Homeownership','Available for Sale/Resale');
            propertyHomeownership.Development_address__c = property1.Id;
        update propertyHomeownership;
        try{
        application = CGPHTestFactory.createApplication(propertyHomeownership.id,preApp.id);
        }
        catch(Exception ex){
            system.debug('exception '+ex);
        }
    }
}