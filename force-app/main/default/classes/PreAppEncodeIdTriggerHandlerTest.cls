@isTest
public class PreAppEncodeIdTriggerHandlerTest{
    public static testmethod void preApplicantTrigger(){
        //Custom Setting
        CGPH_Triggers_Custom_Settings__c cgphTriggersSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) 
        {
            if(cgphTriggersSettings == null){
                cgphTriggersSettings = new CGPH_Triggers_Custom_Settings__c();
                cgphTriggersSettings.Pre_Applicant_Id_Encode__c = true;
                insert cgphTriggersSettings;
                System.assertNotEquals( cgphTriggersSettings.Id, null);
            }
            else{
                if(!cgphTriggersSettings.Pre_Applicant_Id_Encode__c){
                    cgphTriggersSettings.Pre_Applicant_Id_Encode__c = true;
                    upsert cgphTriggersSettings;
                }
            }
        
            if(cgphProfileSettings == null){
                cgphProfileSettings = new CGPH_Profile_Custom_Settings__c();
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                insert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
            }else{
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                upsert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
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
        
        //create contact
        Contact con = new Contact();
        con.FirstName='FirstName';
        con.LastName='LastName';
        insert con;
        
        //Preapplicant object
        PreApplicants__c applicant1 = new PreApplicants__c();
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
        applicant1.AR_Properties_Only__c = true;
        applicant1.Live_Work_Regions__c = '1;2;3';
        applicant1.Annual_Income__c = 28000;
        applicant1.Monthly_Other_Assistance__c = 1000;
        applicant1.Rental_Interest__c = true;
        applicant1.Purchase_Interest__c = true;
        applicant1.Household_Members_55__c = false;
        applicant1.Household_Disabled__c = true;
        applicant1.Section_8__c = false;
        applicant1.Household_Size__c = '1';
        applicant1.Encrypted_ID_Suffix__c = '0001';
        insert applicant1;
        system.assertNotEquals(applicant1.id,null);
        
        
        //After Insert Trigger Test 
        applicant1 = [Select Id, PreApplicant_Encoded_Id__c, Encrypted_ID_Suffix__c From PreApplicants__c Where Id = : applicant1.id];
        String strAppId = EncodingUtil.base64Decode(applicant1.PreApplicant_Encoded_Id__c).toString();
        system.assertEquals(strAppId, applicant1.Id + applicant1.Encrypted_ID_Suffix__c);
        
    }
}