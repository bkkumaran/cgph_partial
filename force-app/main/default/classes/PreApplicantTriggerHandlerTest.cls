@isTest
public class PreApplicantTriggerHandlerTest{
    public static testmethod void preApplicantTrigger0()
{
        
        // before setting the custom settings insert the pre applicant
        //create contact
        Contact con = new Contact();
        con.FirstName='FirstName';
        con.LastName='LastName';
        insert con;
        
        //Preapplicant object
        PreApplicants__c applicant0 = new PreApplicants__c();
        applicant0.Contact__c=con.Id;
        applicant0.Name = 'Test1';
        applicant0.Last_Name__c = 'Person';
        applicant0.Email__c = 'test@test.com';
        applicant0.City__c = 'TestCity';
        applicant0.Phone__c = '1234567890';
        applicant0.Postal_Code__c = '12345';
        applicant0.Street__c = 'TestStreet';
        applicant0.State__c = 'TestState'; 
        applicant0.Most_Recent_Update__c = Datetime.now();
        applicant0.AR_Properties_Only__c = true;
        applicant0.Live_Work_Regions__c = '1;2;3';
        applicant0.Annual_Income__c = 28000;
        applicant0.Monthly_Other_Assistance__c = 1000;
        applicant0.Rental_Interest__c = true;
        applicant0.Purchase_Interest__c = true;
        applicant0.Household_Members_55__c = false;
        applicant0.Household_Disabled__c = true;
        applicant0.Section_8__c = false;
        applicant0.Household_Size__c = '1';
        applicant0.Most_Recent_Update__c = Datetime.now();
        insert applicant0;
        system.assertNotEquals(applicant0.id,null);
        
       
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
        applicant1.Most_Recent_Update__c = Datetime.now();
        insert applicant1;
        system.assertNotEquals(applicant1.id,null);
        
        
        
        //Custom Setting
        CGPH_Triggers_Custom_Settings__c cgphTriggersSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
        list<user> lstUser = new list<user>([SELECT id FROM User Limit 1]);
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) 
        {
            if(cgphTriggersSettings == null){
                 cgphTriggersSettings = new CGPH_Triggers_Custom_Settings__c();
                 cgphTriggersSettings.Pre_Applicant_Profile_Updates__c = true;
                 insert cgphTriggersSettings;
                 System.assertNotEquals( cgphTriggersSettings.Id, null);
            }
            else{
                if(!cgphTriggersSettings.Pre_Applicant_Profile_Updates__c){
                    cgphTriggersSettings.Pre_Applicant_Profile_Updates__c = true;
                    upsert cgphTriggersSettings;
                }
            }
            
            if(cgphProfileSettings == null){
                cgphProfileSettings = new CGPH_Profile_Custom_Settings__c();
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
                insert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
            }else{
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
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
        
            
        //Municpality Object
        Municipality__c municipality1 = new Municipality__c();
        municipality1.Name = 'Township1';
        municipality1.AR_Rental_Properties__c =  'All AR';
        municipality1.Min_Income__c = 14000;
        municipality1.Region__c = '1';
        municipality1.Rental_Portfolio__c = false;
        municipality1.Purchase_Portfolio__c = false;
        municipality1.Rental_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality1.Rental_Unit_Size__c = '1';
        municipality1.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality1.Rental_Units__c = 5;
        municipality1.Rental_Waiting_List_Type__c = 'Random Selection';
        municipality1.Rental_Permanent_Disability_AR_Exception__c = false;
        municipality1.Live_Work_Preference__c = true;
        municipality1.AR_Purchase_Properties__c = 'All AR';
        municipality1.Purchase_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality1.Purchase_Unit_Size__c = '1';
        municipality1.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality1.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality1.Purchase_Units__c = 5;
        
        insert municipality1;
        system.assertNotEquals(municipality1.id,null);
        
            
        //Municpality Object
        Municipality__c municipality2 = new Municipality__c();
        municipality2.Name = 'Township2';
        municipality2.AR_Rental_Properties__c =  'All AR';
        municipality2.Min_Income__c = 14000;
        municipality2.Region__c = '1';
        municipality2.Rental_Portfolio__c = false;
        municipality2.Purchase_Portfolio__c = false;
        municipality2.Rental_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality2.Rental_Unit_Size__c = '1';
        municipality2.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality2.Rental_Units__c = 12;
        municipality2.Rental_Permanent_Disability_AR_Exception__c = false;
        municipality2.Live_Work_Preference__c = true;
        municipality2.AR_Purchase_Properties__c = 'All AR';
        municipality2.Purchase_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality2.Purchase_Unit_Size__c = '1';
        municipality2.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality2.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality2.Purchase_Units__c = 5;
        insert municipality2;
        system.assertNotEquals(municipality1.id,null);
        
        //Municipality_Preference__c object
        Municipality_Preference__c municipalityPreference1 = new Municipality_Preference__c();
        municipalityPreference1.Name = 'TownshipPref1';
        municipalityPreference1.Municipality__c = municipality1.id;
        municipalityPreference1.PreApplicant__c = applicant1.id; 
        municipalityPreference1.Status__c = 'Active';
        municipalityPreference1.Type__c = 'Rental';
        insert municipalityPreference1;
        system.assertNotEquals(municipalityPreference1.id,null);
        
        
        //Municipality_Preference__c object
        Municipality_Preference__c municipalityPreference2 = new Municipality_Preference__c();
        municipalityPreference2.Name = 'TownshipPref2';
        municipalityPreference2.Municipality__c = municipality2.id;
        municipalityPreference2.PreApplicant__c = applicant1.id; 
        municipalityPreference2.Status__c = 'Active';
        municipalityPreference2.Type__c = 'Rental';
        insert municipalityPreference2;
        system.assertNotEquals(municipalityPreference2.id,null);
        
        
        //Purchase Municipality_Preference__c Object
        Municipality_Preference__c municipalityPreference3 = new Municipality_Preference__c();
        municipalityPreference3.Name = 'TownshipPref3';
        municipalityPreference3.Municipality__c = municipality1.id;
        municipalityPreference3.PreApplicant__c = applicant1.id; 
        municipalityPreference3.Status__c = 'Active';
        municipalityPreference3.Type__c = 'Ownership';
        insert municipalityPreference3;
        system.assertNotEquals(municipalityPreference3.id,null);
        
        //Purchase Municipality_Preference__c Object
        Municipality_Preference__c municipalityPreference4 = new Municipality_Preference__c();
        municipalityPreference4.Name = 'TownshipPref4';
        municipalityPreference4.Municipality__c = municipality2.id;
        municipalityPreference4.PreApplicant__c = applicant1.id; 
        municipalityPreference4.Status__c = 'Active';
        municipalityPreference4.Type__c = 'Ownership';
        insert municipalityPreference4;
        system.assertNotEquals(municipalityPreference4.id,null);
        
        //After Insert Trigger Test 
        //applicant1 = [Select Id, PreApplicant_Encoded_Id__c From PreApplicants__c Where Id = : applicant1.id];
        //String strAppId = EncodingUtil.base64Decode(applicant1.PreApplicant_Encoded_Id__c).toString();
        //system.assertEquals(strAppId,applicant1.id);
        
        ///Before Update Trigger Test///
        set<id> setMunicipalPrefIds = new set<id>();
        set<id> setMunicipalityIds = new set<id>();
        List<Municipality_Preference__c> lstMunicipalPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstToUpdateMunPreference = new List<Municipality_Preference__c>();
        List<Municipality__c> lstMunicipality = new List<Municipality__c>();
        List<Municipality__c> lstToUpdateMunicipality = new List<Municipality__c>();
        
        setMunicipalPrefIds.add(municipalityPreference1.id);
        setMunicipalPrefIds.add(municipalityPreference2.id);
        setMunicipalPrefIds.add(municipalityPreference3.id);
        setMunicipalPrefIds.add(municipalityPreference4.id);
        
        setMunicipalityIds.add(municipality1.id);
        setMunicipalityIds.add(municipality2.id);
        
        lstMunicipality = [Select Purchase_Portfolio__c, Rental_Portfolio__c  FROM Municipality__c Where Id IN: setMunicipalityIds];
        
         List<Municipality_Preference__c> lstRentalMunicipalityPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstOwnerMunicipalityPreference = new List<Municipality_Preference__c>();
        lstRentalMunicipalityPreference = [Select Id, Type__c, Township_Interest_ID__c, Status__c, 
                  Removal_Trigger__c, Removal_Date__c, PreApplicant__c,
                  Name, Municipality__c,  Interest_Date__c, Ineligibilty_Reason__c, Municipality__r.Name
                  From Municipality_Preference__c Where  Type__c = 'Rental' AND Status__c = 'Active'];
                  
        lstOwnerMunicipalityPreference = [Select Id, Type__c, Township_Interest_ID__c, Status__c, 
                  Removal_Trigger__c, Removal_Date__c, PreApplicant__c,
                  Name, Municipality__c,  Interest_Date__c, Ineligibilty_Reason__c, Municipality__r.Name
                  From Municipality_Preference__c Where Type__c = 'Ownership' AND Status__c = 'Active'];
                  
       system.debug('In the test method : '+lstRentalMunicipalityPreference);
       system.debug('In the test method : '+lstOwnerMunicipalityPreference);
        
        
        
        PreApplicantTriggerHandler cntrl = new PreApplicantTriggerHandler();
        cntrl.strEmailBody = 'test';
        cntrl.sendEmail('test@test.com');
        
        applicant1.Household_Disabled__c = false;
        update applicant1;
        
        
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Household_Disabled__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){        
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        //3rd Condition Failed
        
        lstMunicipality = [Select AR_Rental_Properties__c FROM Municipality__c Where Id IN: setMunicipalityIds];
        for(Municipality__c municipality : lstMunicipality ){
            municipality.AR_Rental_Properties__c = 'No AR';
            municipality.AR_Purchase_Properties__c = 'No AR';
            lstToUpdateMunicipality.add(municipality);
        }
        if(lstToUpdateMunicipality != null && lstToUpdateMunicipality.size() > 0){
            update lstToUpdateMunicipality;
            lstToUpdateMunicipality.clear();
        }
        applicant1.Household_Disabled__c = true;
        
        Test.startTest();
        update applicant1;
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Household_Disabled__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
           // system.assertEquals(municipalPref.PreApplicant__r.Household_Disabled__c,true);
           // system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
           // system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //4th Condition Failed
        lstMunicipality = [Select AR_Rental_Properties__c FROM Municipality__c Where Id IN: setMunicipalityIds];
        for(Municipality__c municipality : lstMunicipality ){
            municipality.AR_Rental_Properties__c = 'All AR';
            municipality.AR_Purchase_Properties__c = 'All AR';
            lstToUpdateMunicipality.add(municipality);
        }
        if(lstToUpdateMunicipality != null && lstToUpdateMunicipality.size() > 0){
            update lstToUpdateMunicipality;
            lstToUpdateMunicipality.clear();
        }
        
        applicant1.Section_8__c = true;
        update applicant1;    


        //try{
       // Test.startTest();
        //update applicant1;
        /*
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Household_Disabled__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Household_Disabled__c,true);
            system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //4th Condition Failed
        lstMunicipality = [Select AR_Rental_Properties__c FROM Municipality__c Where Id IN: setMunicipalityIds];
        for(Municipality__c municipality : lstMunicipality ){
            municipality.AR_Rental_Properties__c = 'All AR';
            municipality.AR_Purchase_Properties__c = 'All AR';
            lstToUpdateMunicipality.add(municipality);
        }
        if(lstToUpdateMunicipality != null && lstToUpdateMunicipality.size() > 0){
            update lstToUpdateMunicipality;
            lstToUpdateMunicipality.clear();
        }
        
        applicant1.Section_8__c = true;
        update applicant1;
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,true);
            system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //5th Condition
        applicant1.Household_Members_55__c = true;
        applicant1.Section_8__c = false;
        update applicant1;
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,false);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            //system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //6th condition
        applicant1.Section_8__c = true;
        update applicant1;
        
            
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,true);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
        //  system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        // check for preapplicant ineligibility
        applicant1.Household_Size__c = '9+';
        applicant1.Live_Work_Regions__c = '';
        applicant1.Annual_Income__c = null;
        applicant1.Monthly_Other_Assistance__c = null;
        update applicant1;
                
        //Test.stopTest();
        */  
 //     }catch(exception e){}
     //   Test.stopTest();
    }
    
    public static testmethod void preApplicantTrigger(){
        
        // before setting the custom settings insert the pre applicant
        //create contact
        Contact con = new Contact();
        con.FirstName='FirstName';
        con.LastName='LastName';
        insert con;
        
        
        //Preapplicant object
        PreApplicants__c applicant0 = new PreApplicants__c();
        applicant0.Contact__c=con.Id;
        applicant0.Name = 'Test1';
        applicant0.Last_Name__c = 'Person';
        applicant0.Email__c = 'test@test.com';
        applicant0.City__c = 'TestCity';
        applicant0.Phone__c = '1234567890';
        applicant0.Postal_Code__c = '12345';
        applicant0.Street__c = 'TestStreet';
        applicant0.State__c = 'TestState'; 
        applicant0.Most_Recent_Update__c = Datetime.now();
        applicant0.AR_Properties_Only__c = true;
        applicant0.Live_Work_Regions__c = '1;2;3';
        applicant0.Annual_Income__c = 28000;
        applicant0.Monthly_Other_Assistance__c = 1000;
        applicant0.Rental_Interest__c = true;
        applicant0.Purchase_Interest__c = true;
        applicant0.Household_Members_55__c = false;
        applicant0.Household_Disabled__c = true;
        applicant0.Section_8__c = false;
        applicant0.Household_Size__c = '1';
        applicant0.Most_Recent_Update__c = Datetime.now();
        insert applicant0;
        system.assertNotEquals(applicant0.id,null);
        
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
        
        Income_Limits__c incomeLimit = new Income_Limits__c();
        incomeLimit.Name='test Limit';
        incomeLimit.X1_Person__c = 59095;
        incomeLimit.X2_Person__c = 67538;
        incomeLimit.X3_Person__c = 75980;
        incomeLimit.X4_Person__c = 84422;
        incomeLimit.X5_Person__c = 91176;
        incomeLimit.X6_Person__c = 97930;
        incomeLimit.X7_Person_Median__c = 104684;
        incomeLimit.X8_Person_Median__c = 111438;
        incomeLimit.Region__c = '1';
        insert incomeLimit;
        
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
        applicant1.Most_Recent_Update__c = Datetime.now();
        insert applicant1;
        system.assertNotEquals(applicant1.id,null);
        
            
        //Municpality Object
        Municipality__c municipality1 = new Municipality__c();
        municipality1.Name = 'Township1';
        municipality1.AR_Rental_Properties__c =  'All AR';
        municipality1.Min_Income__c = 14000;
        municipality1.Region__c = '1';
        municipality1.Income_Limit__c= region1ILimit.Id;
        municipality1.Rental_Portfolio__c = false;
        municipality1.Purchase_Portfolio__c = false;
        municipality1.Rental_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality1.Rental_Unit_Size__c = '1';
        municipality1.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality1.Rental_Units__c = 5;
        municipality1.Rental_Waiting_List_Type__c = 'Random Selection';
        municipality1.Rental_Permanent_Disability_AR_Exception__c = false;
        municipality1.Live_Work_Preference__c = true;
        municipality1.AR_Purchase_Properties__c = 'All AR';
        municipality1.Purchase_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality1.Purchase_Unit_Size__c = '1';
        municipality1.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality1.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality1.Purchase_Units__c = 5;
        
        insert municipality1;
        system.assertNotEquals(municipality1.id,null);
        
        
        //Custom Setting
        CGPH_Triggers_Custom_Settings__c cgphTriggersSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) 
        {
            if(cgphTriggersSettings == null){
                 cgphTriggersSettings = new CGPH_Triggers_Custom_Settings__c();
                 cgphTriggersSettings.Pre_Applicant_Profile_Updates__c = true;
                 insert cgphTriggersSettings;
                 System.assertNotEquals( cgphTriggersSettings.Id, null);
            }
            else{
                if(!cgphTriggersSettings.Pre_Applicant_Profile_Updates__c){
                    cgphTriggersSettings.Pre_Applicant_Profile_Updates__c = true;
                    upsert cgphTriggersSettings;
                }
            }
            list<user> lstUser = new list<user>([SELECT id FROM User Limit 1]);
            if(cgphProfileSettings == null){
                cgphProfileSettings = new CGPH_Profile_Custom_Settings__c();
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
                cgphProfileSettings.Montaclair_Municipality_Id__c = municipality1.id;
                insert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
            }else{
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
                cgphProfileSettings.Montaclair_Municipality_Id__c = municipality1.id;
                upsert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
            }
        }
        
        // test for Local Municipality urls
        applicant1.MP_Id__c = municipality1.id;
        applicant1.MP_Type__c = 'Ownership';
        applicant1.MP_Update__c = true;
        update applicant1;
            
        //Municpality Object
        Municipality__c municipality2 = new Municipality__c();
        municipality2.Name = 'Township2';
        municipality2.AR_Rental_Properties__c =  'All AR';
        municipality2.Min_Income__c = 14000;
        municipality2.Region__c = '1';
        municipality2.Income_Limit__c= region1ILimit.Id;
        municipality2.Rental_Portfolio__c = true;
        municipality2.Purchase_Portfolio__c = false;
        municipality2.Rental_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality2.Rental_Unit_Size__c = '1';
        municipality2.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality2.Rental_Units__c = 12;
        municipality2.Rental_Permanent_Disability_AR_Exception__c = false;
        municipality2.Live_Work_Preference__c = true;
        municipality2.AR_Purchase_Properties__c = 'All AR';
        municipality2.Purchase_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality2.Purchase_Unit_Size__c = '1';
        municipality2.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality2.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality2.Purchase_Units__c = 5;
        insert municipality2;
        system.assertNotEquals(municipality1.id,null);
        
        //Municipality_Preference__c object
        Municipality_Preference__c municipalityPreference1 = new Municipality_Preference__c();
        municipalityPreference1.Name = 'TownshipPref1';
        municipalityPreference1.Municipality__c = municipality1.id;
        municipalityPreference1.PreApplicant__c = applicant1.id; 
        municipalityPreference1.Status__c = 'Active';
        municipalityPreference1.General_Local__c = true;
        municipalityPreference1.Alternate_Local__c = true;
        municipalityPreference1.Type__c = 'Rental';
        municipalityPreference1.On_Hold__c = true;
        insert municipalityPreference1;
        system.assertNotEquals(municipalityPreference1.id,null); 
        
        PreApplicantTriggerHandler.MunicipalityPreferenceWrapper w = new PreApplicantTriggerHandler.MunicipalityPreferenceWrapper(municipalityPreference1.Id,'strMunicipalityName', 'strIneligibleReason');
        
        //Municipality_Preference__c object
        Municipality_Preference__c municipalityPreference2 = new Municipality_Preference__c();
        municipalityPreference2.Name = 'TownshipPref2';
        municipalityPreference2.Municipality__c = municipality2.id;
        municipalityPreference2.PreApplicant__c = applicant1.id; 
        municipalityPreference2.Status__c = 'Active';
        municipalityPreference2.Type__c = 'Rental';
        municipalityPreference2.On_Hold__c = true;
        insert municipalityPreference2;
        system.assertNotEquals(municipalityPreference2.id,null);
        
        
        //Purchase Municipality_Preference__c Object
        Municipality_Preference__c municipalityPreference3 = new Municipality_Preference__c();
        municipalityPreference3.Name = 'TownshipPref3';
        municipalityPreference3.Municipality__c = municipality1.id;
        municipalityPreference3.PreApplicant__c = applicant1.id; 
        municipalityPreference3.Status__c = 'Active';
        municipalityPreference3.Type__c = 'Ownership';
        insert municipalityPreference3;
        system.assertNotEquals(municipalityPreference3.id,null);
        
        //Purchase Municipality_Preference__c Object
        Municipality_Preference__c municipalityPreference4 = new Municipality_Preference__c();
        municipalityPreference4.Name = 'TownshipPref4';
        municipalityPreference4.Municipality__c = municipality2.id;
        municipalityPreference4.PreApplicant__c = applicant1.id; 
        municipalityPreference4.Status__c = 'Active';
        municipalityPreference4.Type__c = 'Ownership';
        insert municipalityPreference4;
        system.assertNotEquals(municipalityPreference4.id,null);
        
        //After Insert Trigger Test 
        //applicant1 = [Select Id, PreApplicant_Encoded_Id__c From PreApplicants__c Where Id = : applicant1.id];
        //String strAppId = EncodingUtil.base64Decode(applicant1.PreApplicant_Encoded_Id__c).toString();
        //system.assertEquals(strAppId,applicant1.id);
        
        ///Before Update Trigger Test///
        set<id> setMunicipalPrefIds = new set<id>();
        set<id> setMunicipalityIds = new set<id>();
        List<Municipality_Preference__c> lstMunicipalPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstToUpdateMunPreference = new List<Municipality_Preference__c>();
        List<Municipality__c> lstMunicipality = new List<Municipality__c>();
        List<Municipality__c> lstToUpdateMunicipality = new List<Municipality__c>();
        
        setMunicipalPrefIds.add(municipalityPreference1.id);
        setMunicipalPrefIds.add(municipalityPreference2.id);
        setMunicipalPrefIds.add(municipalityPreference3.id);
        setMunicipalPrefIds.add(municipalityPreference4.id);
        
        setMunicipalityIds.add(municipality1.id);
        setMunicipalityIds.add(municipality2.id);
        
        lstMunicipality = [Select Purchase_Portfolio__c, Rental_Portfolio__c  FROM Municipality__c Where Id IN: setMunicipalityIds];
        
         List<Municipality_Preference__c> lstRentalMunicipalityPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstOwnerMunicipalityPreference = new List<Municipality_Preference__c>();
        lstRentalMunicipalityPreference = [Select Id, Type__c, Township_Interest_ID__c, Status__c, 
                  Removal_Trigger__c, Removal_Date__c, PreApplicant__c,
                  Name, Municipality__c,  Interest_Date__c, Ineligibilty_Reason__c, Municipality__r.Name
                  From Municipality_Preference__c Where  Type__c = 'Rental' AND Status__c = 'Active'];
                  
        lstOwnerMunicipalityPreference = [Select Id, Type__c, Township_Interest_ID__c, Status__c, 
                  Removal_Trigger__c, Removal_Date__c, PreApplicant__c,
                  Name, Municipality__c,  Interest_Date__c, Ineligibilty_Reason__c, Municipality__r.Name
                  From Municipality_Preference__c Where Type__c = 'Ownership' AND Status__c = 'Active'];
                  
       system.debug('In the test method : '+lstRentalMunicipalityPreference);
       system.debug('In the test method : '+lstOwnerMunicipalityPreference);
        
        //condition 1 If Applicant have no interest in Rental Properties
        applicant1.Rental_Interest__c = false;
        applicant1.Purchase_Interest__c = false;
        update applicant1;
        system.assertNotEquals(applicant1.id,null);
        system.debug('lstMunicipality::::::::::::::'+lstMunicipality);
        lstMunicipalPreference = [Select Status__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.debug('$$$$$ Preference status = >> '+municipalPref.Status__c);
            //system.assertEquals(municipalPref.Status__c,'Inactive');
            municipalPref.Status__c = 'Active';
            municipalPref.On_Hold__c = true;
            lstToUpdateMunPreference.add(municipalPref);
        }
        
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        Test.startTest();
        
        applicant1.Purchase_Interest__c = true;
        applicant1.Rental_Interest__c = true;
        update applicant1;
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Purchase_Interest__c, PreApplicant__r.Rental_Interest__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            //system.assertEquals(municipalPref.PreApplicant__r.Purchase_Interest__c,true);
           // system.assertEquals(municipalPref.PreApplicant__r.Rental_Interest__c,true);
          //  system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null); 
            //system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }   
        
        //PreApplicantTriggerHandler.MunicipalityPreferenceWrapper w = new PreApplicantTriggerHandler.MunicipalityPreferenceWrapper(municipalityPreference1.Id, 'strMunicipalityName', 'strIneligibleReason');        
        /*
        
        //2nd Condition
        for(Municipality__c municipality : lstMunicipality ){
            municipality.Purchase_Portfolio__c = true;
            municipality.Rental_Portfolio__c = true;
            lstToUpdateMunicipality.add(municipality);
        }
        if(lstToUpdateMunicipality != null && lstToUpdateMunicipality.size() > 0){
            update lstToUpdateMunicipality;
            lstToUpdateMunicipality.clear();
        }
        
        applicant1.Household_Disabled__c = false;
        update applicant1;
        
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Household_Disabled__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Household_Disabled__c,false);
            system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        //3rd Condition Failed
        
        lstMunicipality = [Select AR_Rental_Properties__c FROM Municipality__c Where Id IN: setMunicipalityIds];
        for(Municipality__c municipality : lstMunicipality ){
            municipality.AR_Rental_Properties__c = 'No AR';
            municipality.AR_Purchase_Properties__c = 'No AR';
            lstToUpdateMunicipality.add(municipality);
        }
        if(lstToUpdateMunicipality != null && lstToUpdateMunicipality.size() > 0){
            update lstToUpdateMunicipality;
            lstToUpdateMunicipality.clear();
        }
        applicant1.Household_Disabled__c = true;
        
        
        try{
        Test.startTest();
        update applicant1;
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Household_Disabled__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Household_Disabled__c,true);
            system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //4th Condition Failed
        lstMunicipality = [Select AR_Rental_Properties__c FROM Municipality__c Where Id IN: setMunicipalityIds];
        for(Municipality__c municipality : lstMunicipality ){
            municipality.AR_Rental_Properties__c = 'All AR';
            municipality.AR_Purchase_Properties__c = 'All AR';
            lstToUpdateMunicipality.add(municipality);
        }
        if(lstToUpdateMunicipality != null && lstToUpdateMunicipality.size() > 0){
            update lstToUpdateMunicipality;
            lstToUpdateMunicipality.clear();
        }
        
        applicant1.Section_8__c = true;
        update applicant1;
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,true);
            system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //5th Condition
        applicant1.Household_Members_55__c = true;
        applicant1.Section_8__c = false;
        update applicant1;
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,false);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            //system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //6th condition
        applicant1.Section_8__c = true;
        update applicant1;
        
            
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,true);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
        //  system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
         
        // check for preapplicant ineligibility
        applicant1.Household_Size__c = '9+';
        applicant1.Live_Work_Regions__c = '';
        applicant1.Annual_Income__c = null;
        applicant1.Monthly_Other_Assistance__c = null;
        update applicant1;
                
        //Test.stopTest();  
        }catch(exception e){}
        */
        Test.stopTest();
    }
    
    
    
    
    

    public static testmethod void preApplicantTrigger1(){
        
        // before setting the custom settings insert the pre applicant
        //create contact
        Contact con = new Contact();
        con.FirstName='FirstName';
        con.LastName='LastName';
        insert con;
        
        //Preapplicant object
        PreApplicants__c applicant0 = new PreApplicants__c();
        applicant0.Contact__c=con.Id;
        applicant0.Name = 'Test1';
        applicant0.Last_Name__c = 'Person';
        applicant0.Email__c = 'test@test.com';
        applicant0.City__c = 'TestCity';
        applicant0.Phone__c = '1234567890';
        applicant0.Postal_Code__c = '12345';
        applicant0.Street__c = 'TestStreet';
        applicant0.State__c = 'TestState'; 
        applicant0.Most_Recent_Update__c = Datetime.now();
        applicant0.AR_Properties_Only__c = true;
        applicant0.Live_Work_Regions__c = '1;2;3';
        applicant0.Annual_Income__c = 28000;
        applicant0.Monthly_Other_Assistance__c = 1000;
        applicant0.Rental_Interest__c = true;
        applicant0.Purchase_Interest__c = true;
        applicant0.Household_Members_55__c = false;
        applicant0.Household_Disabled__c = true;
        applicant0.Section_8__c = false;
        applicant0.Household_Size__c = '1';
        applicant0.Most_Recent_Update__c = Datetime.now();
        insert applicant0;
        system.assertNotEquals(applicant0.id,null);
        
        
        
        //Custom Setting
        CGPH_Triggers_Custom_Settings__c cgphTriggersSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
        list<user> lstUser = new list<user>([SELECT id FROM User Limit 1]);
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) 
        {
            if(cgphTriggersSettings == null){
                 cgphTriggersSettings = new CGPH_Triggers_Custom_Settings__c();
                 cgphTriggersSettings.Pre_Applicant_Profile_Updates__c = true;
                 insert cgphTriggersSettings;
                 System.assertNotEquals( cgphTriggersSettings.Id, null);
            }
            else{
                if(!cgphTriggersSettings.Pre_Applicant_Profile_Updates__c){
                    cgphTriggersSettings.Pre_Applicant_Profile_Updates__c = true;
                    upsert cgphTriggersSettings;
                }
            }
            
            if(cgphProfileSettings == null){
                cgphProfileSettings = new CGPH_Profile_Custom_Settings__c();
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
                insert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
            }else{
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
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
        applicant1.Most_Recent_Update__c = Datetime.now();
        insert applicant1;
        system.assertNotEquals(applicant1.id,null);
        
            
        //Municpality Object
        Municipality__c municipality1 = new Municipality__c();
        municipality1.Name = 'Township1';
        municipality1.AR_Rental_Properties__c =  'All AR';
        municipality1.Min_Income__c = 14000;
        municipality1.Region__c = '1';
        municipality1.Rental_Portfolio__c = false;
        municipality1.Purchase_Portfolio__c = false;
        municipality1.Rental_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality1.Rental_Unit_Size__c = '1';
        municipality1.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality1.Rental_Units__c = 5;
        municipality1.Rental_Waiting_List_Type__c = 'Random Selection';
        municipality1.Rental_Permanent_Disability_AR_Exception__c = false;
        municipality1.Live_Work_Preference__c = true;
        municipality1.AR_Purchase_Properties__c = 'All AR';
        municipality1.Purchase_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality1.Purchase_Unit_Size__c = '1';
        municipality1.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality1.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality1.Purchase_Units__c = 5;
        
        insert municipality1;
        system.assertNotEquals(municipality1.id,null);
        
            
        //Municpality Object
        Municipality__c municipality2 = new Municipality__c();
        municipality2.Name = 'Township2';
        municipality2.AR_Rental_Properties__c =  'All AR';
        municipality2.Min_Income__c = 14000;
        municipality2.Region__c = '1';
        municipality2.Rental_Portfolio__c = false;
        municipality2.Purchase_Portfolio__c = false;
        municipality2.Rental_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality2.Rental_Unit_Size__c = '1';
        municipality2.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality2.Rental_Units__c = 12;
        municipality2.Rental_Permanent_Disability_AR_Exception__c = false;
        municipality2.Live_Work_Preference__c = true;
        municipality2.AR_Purchase_Properties__c = 'All AR';
        municipality2.Purchase_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality2.Purchase_Unit_Size__c = '1';
        municipality2.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality2.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality2.Purchase_Units__c = 5;
        insert municipality2;
        system.assertNotEquals(municipality1.id,null);
        
        //Municipality_Preference__c object
        Municipality_Preference__c municipalityPreference1 = new Municipality_Preference__c();
        municipalityPreference1.Name = 'TownshipPref1';
        municipalityPreference1.Municipality__c = municipality1.id;
        municipalityPreference1.PreApplicant__c = applicant1.id; 
        municipalityPreference1.Status__c = 'Active';
        municipalityPreference1.Type__c = 'Rental';
        insert municipalityPreference1;
        system.assertNotEquals(municipalityPreference1.id,null);
        
        
        //Municipality_Preference__c object
        Municipality_Preference__c municipalityPreference2 = new Municipality_Preference__c();
        municipalityPreference2.Name = 'TownshipPref2';
        municipalityPreference2.Municipality__c = municipality2.id;
        municipalityPreference2.PreApplicant__c = applicant1.id; 
        municipalityPreference2.Status__c = 'Active';
        municipalityPreference2.Type__c = 'Rental';
        insert municipalityPreference2;
        system.assertNotEquals(municipalityPreference2.id,null);
        
        
        //Purchase Municipality_Preference__c Object
        Municipality_Preference__c municipalityPreference3 = new Municipality_Preference__c();
        municipalityPreference3.Name = 'TownshipPref3';
        municipalityPreference3.Municipality__c = municipality1.id;
        municipalityPreference3.PreApplicant__c = applicant1.id; 
        municipalityPreference3.Status__c = 'Active';
        municipalityPreference3.Type__c = 'Ownership';
        insert municipalityPreference3;
        system.assertNotEquals(municipalityPreference3.id,null);
        
        //Purchase Municipality_Preference__c Object
        Municipality_Preference__c municipalityPreference4 = new Municipality_Preference__c();
        municipalityPreference4.Name = 'TownshipPref4';
        municipalityPreference4.Municipality__c = municipality2.id;
        municipalityPreference4.PreApplicant__c = applicant1.id; 
        municipalityPreference4.Status__c = 'Active';
        municipalityPreference4.Type__c = 'Ownership';
        insert municipalityPreference4;
        system.assertNotEquals(municipalityPreference4.id,null);
        
        //After Insert Trigger Test 
        //applicant1 = [Select Id, PreApplicant_Encoded_Id__c From PreApplicants__c Where Id = : applicant1.id];
        //String strAppId = EncodingUtil.base64Decode(applicant1.PreApplicant_Encoded_Id__c).toString();
        //system.assertEquals(strAppId,applicant1.id);
        
        ///Before Update Trigger Test///
        set<id> setMunicipalPrefIds = new set<id>();
        set<id> setMunicipalityIds = new set<id>();
        List<Municipality_Preference__c> lstMunicipalPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstToUpdateMunPreference = new List<Municipality_Preference__c>();
        List<Municipality__c> lstMunicipality = new List<Municipality__c>();
        List<Municipality__c> lstToUpdateMunicipality = new List<Municipality__c>();
        
        setMunicipalPrefIds.add(municipalityPreference1.id);
        setMunicipalPrefIds.add(municipalityPreference2.id);
        setMunicipalPrefIds.add(municipalityPreference3.id);
        setMunicipalPrefIds.add(municipalityPreference4.id);
        
        setMunicipalityIds.add(municipality1.id);
        setMunicipalityIds.add(municipality2.id);
        
        lstMunicipality = [Select Purchase_Portfolio__c, Rental_Portfolio__c  FROM Municipality__c Where Id IN: setMunicipalityIds];
        
         List<Municipality_Preference__c> lstRentalMunicipalityPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstOwnerMunicipalityPreference = new List<Municipality_Preference__c>();
        lstRentalMunicipalityPreference = [Select Id, Type__c, Township_Interest_ID__c, Status__c, 
                  Removal_Trigger__c, Removal_Date__c, PreApplicant__c,
                  Name, Municipality__c,  Interest_Date__c, Ineligibilty_Reason__c, Municipality__r.Name
                  From Municipality_Preference__c Where  Type__c = 'Rental' AND Status__c = 'Active'];
                  
        lstOwnerMunicipalityPreference = [Select Id, Type__c, Township_Interest_ID__c, Status__c, 
                  Removal_Trigger__c, Removal_Date__c, PreApplicant__c,
                  Name, Municipality__c,  Interest_Date__c, Ineligibilty_Reason__c, Municipality__r.Name
                  From Municipality_Preference__c Where Type__c = 'Ownership' AND Status__c = 'Active'];
                  
       system.debug('In the test method : '+lstRentalMunicipalityPreference);
       system.debug('In the test method : '+lstOwnerMunicipalityPreference);
        
        
        // check for basic condition
        applicant1.Household_Size__c = '9+';
        update applicant1;
        
        PreApplicantTriggerHandler cntrl = new PreApplicantTriggerHandler();
        cntrl.strEmailBody = 'test';
        cntrl.sendEmail('test@test.com');
        
        Test.StartTest();
        //condition 1 If Applicant have no interest in Rental Properties
        applicant1.Household_Size__c = '1';
        applicant1.Rental_Interest__c = false;
        applicant1.Purchase_Interest__c = false;
        update applicant1;
        system.assertNotEquals(applicant1.id,null);
        system.debug('lstMunicipality::::::::::::::'+lstMunicipality);
        lstMunicipalPreference = [Select Status__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.debug('$$$$$ Preference status = >> '+municipalPref.Status__c);
            //system.assertEquals(municipalPref.Status__c,'Inactive');
            municipalPref.Status__c = 'Active';
            municipalPref.On_Hold__c = true;
            lstToUpdateMunPreference.add(municipalPref);
        }
        
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        
        
        //2nd Condition
        for(Municipality__c municipality : lstMunicipality ){
            municipality.Income_Limit__c= region1ILimit.Id;
            municipality.Purchase_Portfolio__c = true;
            municipality.Rental_Portfolio__c = true;
            lstToUpdateMunicipality.add(municipality);
        }
        if(lstToUpdateMunicipality != null && lstToUpdateMunicipality.size() > 0){
            update lstToUpdateMunicipality;
            lstToUpdateMunicipality.clear();
        }
        
        applicant1.Household_Disabled__c = false;
        update applicant1;
        
        //Test.startTest();
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Household_Disabled__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
        //  system.assertEquals(municipalPref.PreApplicant__r.Household_Disabled__c,false);
        //  system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
        //  system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        //3rd Condition Failed
        
        lstMunicipality = [Select AR_Rental_Properties__c FROM Municipality__c Where Id IN: setMunicipalityIds];
        for(Municipality__c municipality : lstMunicipality ){
            municipality.AR_Rental_Properties__c = 'No AR';
            municipality.AR_Purchase_Properties__c = 'No AR';
            lstToUpdateMunicipality.add(municipality);
        }
        if(lstToUpdateMunicipality != null && lstToUpdateMunicipality.size() > 0){
            update lstToUpdateMunicipality;
            lstToUpdateMunicipality.clear();
        }
        applicant1.Household_Disabled__c = true;
        
        
        //try{
       // Test.startTest();
       // update applicant1;
        /*
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Household_Disabled__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Household_Disabled__c,true);
            system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //4th Condition Failed
        lstMunicipality = [Select AR_Rental_Properties__c FROM Municipality__c Where Id IN: setMunicipalityIds];
        for(Municipality__c municipality : lstMunicipality ){
            municipality.AR_Rental_Properties__c = 'All AR';
            municipality.AR_Purchase_Properties__c = 'All AR';
            lstToUpdateMunicipality.add(municipality);
        }
        if(lstToUpdateMunicipality != null && lstToUpdateMunicipality.size() > 0){
            update lstToUpdateMunicipality;
            lstToUpdateMunicipality.clear();
        }
        
        applicant1.Section_8__c = true;
        update applicant1;
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,true);
            system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //5th Condition
        applicant1.Household_Members_55__c = true;
        applicant1.Section_8__c = false;
        update applicant1;
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,false);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            //system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //6th condition
        applicant1.Section_8__c = true;
        update applicant1;
        
            
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,true);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
        //  system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        // check for preapplicant ineligibility
        applicant1.Household_Size__c = '9+';
        applicant1.Live_Work_Regions__c = '';
        applicant1.Annual_Income__c = null;
        applicant1.Monthly_Other_Assistance__c = null;
        update applicant1;
                
        //Test.stopTest();
        */  
 //     }catch(exception e){}
        Test.stopTest();
    }
   
    
        public static testmethod void preApplicantTrigger2(){
        
        // before setting the custom settings insert the pre applicant
        Contact con = new Contact();
        con.FirstName='FirstName';
        con.LastName='LastName';
        insert con;
            
        //Preapplicant object
        PreApplicants__c applicant0 = new PreApplicants__c();
         applicant0.Contact__c=con.Id;   
        applicant0.Name = 'Test1';
        applicant0.Last_Name__c = 'Person';
        applicant0.Email__c = 'test@test.com';
        applicant0.City__c = 'TestCity';
        applicant0.Phone__c = '1234567890';
        applicant0.Postal_Code__c = '12345';
        applicant0.Street__c = 'TestStreet';
        applicant0.State__c = 'TestState'; 
        applicant0.Most_Recent_Update__c = Datetime.now();
        applicant0.AR_Properties_Only__c = true;
        applicant0.Live_Work_Regions__c = '1;2;3';
        applicant0.Annual_Income__c = 28000;
        applicant0.Monthly_Other_Assistance__c = 1000;
        applicant0.Rental_Interest__c = true;
        applicant0.Purchase_Interest__c = true;
        applicant0.Household_Members_55__c = false;
        applicant0.Household_Disabled__c = true;
        applicant0.Section_8__c = false;
        applicant0.Household_Size__c = '1';
        applicant0.Most_Recent_Update__c = Datetime.now();
        insert applicant0;
        system.assertNotEquals(applicant0.id,null);
        
        
        
        //Custom Setting
        CGPH_Triggers_Custom_Settings__c cgphTriggersSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) 
        {
            if(cgphTriggersSettings == null){
                 cgphTriggersSettings = new CGPH_Triggers_Custom_Settings__c();
                 cgphTriggersSettings.Pre_Applicant_Profile_Updates__c = true;
                 insert cgphTriggersSettings;
                 System.assertNotEquals( cgphTriggersSettings.Id, null);
            }
            else{
                if(!cgphTriggersSettings.Pre_Applicant_Profile_Updates__c){
                    cgphTriggersSettings.Pre_Applicant_Profile_Updates__c = true;
                    upsert cgphTriggersSettings;
                }
            }
            list<user> lstUser = new list<user>([SELECT id FROM User Limit 1]);
            if(cgphProfileSettings == null){
                cgphProfileSettings = new CGPH_Profile_Custom_Settings__c();
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
                insert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
            }else{
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
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
        applicant1.Most_Recent_Update__c = Datetime.now();
        insert applicant1;
        system.assertNotEquals(applicant1.id,null);
        
            
        //Municpality Object
        Municipality__c municipality1 = new Municipality__c();
        municipality1.Name = 'Township1';
        municipality1.AR_Rental_Properties__c =  'All AR';
        municipality1.Min_Income__c = 14000;
        municipality1.Region__c = '1';
        municipality1.Rental_Portfolio__c = false;
        municipality1.Purchase_Portfolio__c = false;
        municipality1.Rental_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality1.Rental_Unit_Size__c = '1';
        municipality1.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality1.Rental_Units__c = 5;
        municipality1.Rental_Waiting_List_Type__c = 'Random Selection';
        municipality1.Rental_Permanent_Disability_AR_Exception__c = false;
        municipality1.Live_Work_Preference__c = true;
        municipality1.AR_Purchase_Properties__c = 'All AR';
        municipality1.Purchase_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality1.Purchase_Unit_Size__c = '1';
        municipality1.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality1.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality1.Purchase_Units__c = 5;
        
        insert municipality1;
        system.assertNotEquals(municipality1.id,null);
        
            
        //Municpality Object
        Municipality__c municipality2 = new Municipality__c();
        municipality2.Name = 'Township2';
        municipality2.AR_Rental_Properties__c =  'All AR';
        municipality2.Min_Income__c = 14000;
        municipality2.Region__c = '1';
        municipality2.Rental_Portfolio__c = false;
        municipality2.Purchase_Portfolio__c = false;
        municipality2.Rental_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality2.Rental_Unit_Size__c = '1';
        municipality2.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality2.Rental_Units__c = 12;
        municipality2.Rental_Permanent_Disability_AR_Exception__c = false;
        municipality2.Live_Work_Preference__c = true;
        municipality2.AR_Purchase_Properties__c = 'All AR';
        municipality2.Purchase_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality2.Purchase_Unit_Size__c = '1';
        municipality2.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality2.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality2.Purchase_Units__c = 5;
        insert municipality2;
        system.assertNotEquals(municipality1.id,null);
        
        //Municipality_Preference__c object
        Municipality_Preference__c municipalityPreference1 = new Municipality_Preference__c();
        municipalityPreference1.Name = 'TownshipPref1';
        municipalityPreference1.Municipality__c = municipality1.id;
        municipalityPreference1.PreApplicant__c = applicant1.id; 
        municipalityPreference1.Status__c = 'Active';
        municipalityPreference1.Type__c = 'Rental';
        insert municipalityPreference1;
        system.assertNotEquals(municipalityPreference1.id,null);
        
        
        //Municipality_Preference__c object
        Municipality_Preference__c municipalityPreference2 = new Municipality_Preference__c();
        municipalityPreference2.Name = 'TownshipPref2';
        municipalityPreference2.Municipality__c = municipality2.id;
        municipalityPreference2.PreApplicant__c = applicant1.id; 
        municipalityPreference2.Status__c = 'Active';
        municipalityPreference2.Type__c = 'Rental';
        insert municipalityPreference2;
        system.assertNotEquals(municipalityPreference2.id,null);
        
        
        //Purchase Municipality_Preference__c Object
        Municipality_Preference__c municipalityPreference3 = new Municipality_Preference__c();
        municipalityPreference3.Name = 'TownshipPref3';
        municipalityPreference3.Municipality__c = municipality1.id;
        municipalityPreference3.PreApplicant__c = applicant1.id; 
        municipalityPreference3.Status__c = 'Active';
        municipalityPreference3.Type__c = 'Ownership';
        insert municipalityPreference3;
        system.assertNotEquals(municipalityPreference3.id,null);
        
        //Purchase Municipality_Preference__c Object
        Municipality_Preference__c municipalityPreference4 = new Municipality_Preference__c();
        municipalityPreference4.Name = 'TownshipPref4';
        municipalityPreference4.Municipality__c = municipality2.id;
        municipalityPreference4.PreApplicant__c = applicant1.id; 
        municipalityPreference4.Status__c = 'Active';
        municipalityPreference4.Type__c = 'Ownership';
        insert municipalityPreference4;
        system.assertNotEquals(municipalityPreference4.id,null);
        
        //After Insert Trigger Test 
        //applicant1 = [Select Id, PreApplicant_Encoded_Id__c From PreApplicants__c Where Id = : applicant1.id];
        //String strAppId = EncodingUtil.base64Decode(applicant1.PreApplicant_Encoded_Id__c).toString();
        //system.assertEquals(strAppId,applicant1.id);
        
        ///Before Update Trigger Test///
        set<id> setMunicipalPrefIds = new set<id>();
        set<id> setMunicipalityIds = new set<id>();
        List<Municipality_Preference__c> lstMunicipalPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstToUpdateMunPreference = new List<Municipality_Preference__c>();
        List<Municipality__c> lstMunicipality = new List<Municipality__c>();
        List<Municipality__c> lstToUpdateMunicipality = new List<Municipality__c>();
        
        setMunicipalPrefIds.add(municipalityPreference1.id);
        setMunicipalPrefIds.add(municipalityPreference2.id);
        setMunicipalPrefIds.add(municipalityPreference3.id);
        setMunicipalPrefIds.add(municipalityPreference4.id);
        
        setMunicipalityIds.add(municipality1.id);
        setMunicipalityIds.add(municipality2.id);
        
        lstMunicipality = [Select Purchase_Portfolio__c, Rental_Portfolio__c  FROM Municipality__c Where Id IN: setMunicipalityIds];
        
         List<Municipality_Preference__c> lstRentalMunicipalityPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstOwnerMunicipalityPreference = new List<Municipality_Preference__c>();
        lstRentalMunicipalityPreference = [Select Id, Type__c, Township_Interest_ID__c, Status__c, 
                  Removal_Trigger__c, Removal_Date__c, PreApplicant__c,
                  Name, Municipality__c,  Interest_Date__c, Ineligibilty_Reason__c, Municipality__r.Name
                  From Municipality_Preference__c Where  Type__c = 'Rental' AND Status__c = 'Active'];
                  
        lstOwnerMunicipalityPreference = [Select Id, Type__c, Township_Interest_ID__c, Status__c, 
                  Removal_Trigger__c, Removal_Date__c, PreApplicant__c,
                  Name, Municipality__c,  Interest_Date__c, Ineligibilty_Reason__c, Municipality__r.Name
                  From Municipality_Preference__c Where Type__c = 'Ownership' AND Status__c = 'Active'];
                  
       system.debug('In the test method : '+lstRentalMunicipalityPreference);
       system.debug('In the test method : '+lstOwnerMunicipalityPreference);
        
        
        // check for basic condition
        applicant1.Household_Size__c = '9+';
        update applicant1;
        
        
        //3rd Condition Failed
        
        lstMunicipality = [Select AR_Rental_Properties__c FROM Municipality__c Where Id IN: setMunicipalityIds];
        for(Municipality__c municipality : lstMunicipality ){
            municipality.AR_Rental_Properties__c = 'No AR';
            municipality.AR_Purchase_Properties__c = 'No AR';
            lstToUpdateMunicipality.add(municipality);
        }
        if(lstToUpdateMunicipality != null && lstToUpdateMunicipality.size() > 0){
            update lstToUpdateMunicipality;
            lstToUpdateMunicipality.clear();
        }
        applicant1.Household_Disabled__c = true;
        
        
//      try{
        
        update applicant1;
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Household_Disabled__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Household_Disabled__c,true);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            //system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        Test.startTest();
        //4th Condition Failed
        lstMunicipality = [Select AR_Rental_Properties__c FROM Municipality__c Where Id IN: setMunicipalityIds];
        for(Municipality__c municipality : lstMunicipality ){
            municipality.AR_Rental_Properties__c = 'All AR';
            municipality.AR_Purchase_Properties__c = 'All AR';
            lstToUpdateMunicipality.add(municipality);
        }
        if(lstToUpdateMunicipality != null && lstToUpdateMunicipality.size() > 0){
            update lstToUpdateMunicipality;
            lstToUpdateMunicipality.clear();
        }
        
        applicant1.Section_8__c = true;
        update applicant1;
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,true);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            //system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        /*
        //5th Condition
        applicant1.Household_Members_55__c = true;
        applicant1.Section_8__c = false;
        update applicant1;
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,false);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            //system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //6th condition
        applicant1.Section_8__c = true;
        update applicant1;
        
            
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,true);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
        //  system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        // check for preapplicant ineligibility
        applicant1.Household_Size__c = '9+';
        applicant1.Live_Work_Regions__c = '';
        applicant1.Annual_Income__c = null;
        applicant1.Monthly_Other_Assistance__c = null;
        update applicant1;
                
        //Test.stopTest();
        */  
 //     }catch(exception e){}
        Test.stopTest();
    }
    
    
    public static testmethod void preApplicantTrigger3(){       
        // before setting the custom settings insert the pre applicant
         Contact con = new Contact();
        con.FirstName='FirstName';
        con.LastName='LastName';
        insert con;
        
        //Preapplicant object
        PreApplicants__c applicant0 = new PreApplicants__c();
        applicant0.Contact__c=con.Id;
        applicant0.Name = 'Test1';
        applicant0.Last_Name__c = 'Person';
        applicant0.Email__c = 'test@test.com';
        applicant0.City__c = 'TestCity';
        applicant0.Phone__c = '1234567890';
        applicant0.Postal_Code__c = '12345';
        applicant0.Street__c = 'TestStreet';
        applicant0.State__c = 'TestState'; 
        applicant0.Most_Recent_Update__c = Datetime.now();
        applicant0.AR_Properties_Only__c = true;
        applicant0.Live_Work_Regions__c = '1;2;3';
        applicant0.Annual_Income__c = 28000;
        applicant0.Monthly_Other_Assistance__c = 1000;
        applicant0.Rental_Interest__c = true;
        applicant0.Purchase_Interest__c = true;
        applicant0.Household_Members_55__c = false;
        applicant0.Household_Disabled__c = true;
        applicant0.Section_8__c = false;
        applicant0.Household_Size__c = '1';
        applicant0.Most_Recent_Update__c = Datetime.now();
        insert applicant0;
        system.assertNotEquals(applicant0.id,null);
        
        
        
        //Custom Setting
        CGPH_Triggers_Custom_Settings__c cgphTriggersSettings = CGPH_Triggers_Custom_Settings__c.getInstance();
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPH_Profile_Custom_Settings__c.getInstance();
        System.runAs ( new User(Id = UserInfo.getUserId()) ) 
        {
            if(cgphTriggersSettings == null){
                 cgphTriggersSettings = new CGPH_Triggers_Custom_Settings__c();
                 cgphTriggersSettings.Pre_Applicant_Profile_Updates__c = true;
                 insert cgphTriggersSettings;
                 System.assertNotEquals( cgphTriggersSettings.Id, null);
            }
            else{
                if(!cgphTriggersSettings.Pre_Applicant_Profile_Updates__c){
                    cgphTriggersSettings.Pre_Applicant_Profile_Updates__c = true;
                    upsert cgphTriggersSettings;
                }
            }
            list<user> lstUser = new list<user>([SELECT id FROM User Limit 1]);
            if(cgphProfileSettings == null){
                cgphProfileSettings = new CGPH_Profile_Custom_Settings__c();
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
                insert cgphProfileSettings;
                System.assertNotEquals( cgphProfileSettings.Id, null);
            }else{
                cgphProfileSettings.Moderate_AMI__c = 80;
                cgphProfileSettings.Low_AMI__c = 50;
                cgphProfileSettings.Very_Low_AMI__c = 30;
                cgphProfileSettings.Admin_User_Id__c = lstUser[0].id;
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
        applicant1.Most_Recent_Update__c = Datetime.now();
        insert applicant1;
        system.assertNotEquals(applicant1.id,null);
        
            
        //Municpality Object
        Municipality__c municipality1 = new Municipality__c();
        municipality1.Name = 'Township1';
        municipality1.AR_Rental_Properties__c =  'All AR';
        municipality1.Min_Income__c = 14000;
        municipality1.Region__c = '1';
        municipality1.Rental_Portfolio__c = false;
        municipality1.Purchase_Portfolio__c = false;
        municipality1.Rental_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality1.Rental_Unit_Size__c = '1';
        municipality1.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality1.Rental_Units__c = 5;
        municipality1.Rental_Waiting_List_Type__c = 'Random Selection';
        municipality1.Rental_Permanent_Disability_AR_Exception__c = false;
        municipality1.Live_Work_Preference__c = true;
        municipality1.AR_Purchase_Properties__c = 'All AR';
        municipality1.Purchase_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality1.Purchase_Unit_Size__c = '1';
        municipality1.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality1.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality1.Purchase_Units__c = 5;
        
        insert municipality1;
        system.assertNotEquals(municipality1.id,null);
        
            
        //Municpality Object
        Municipality__c municipality2 = new Municipality__c();
        municipality2.Name = 'Township2';
        municipality2.AR_Rental_Properties__c =  'All AR';
        municipality2.Min_Income__c = 14000;
        municipality2.Region__c = '1';
        municipality2.Rental_Portfolio__c = false;
        municipality2.Purchase_Portfolio__c = false;
        municipality2.Rental_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality2.Rental_Unit_Size__c = '1';
        municipality2.Rental_Waiting_List__c = 'Less than 2 yr';
        municipality2.Rental_Units__c = 12;
        municipality2.Rental_Permanent_Disability_AR_Exception__c = false;
        municipality2.Live_Work_Preference__c = true;
        municipality2.AR_Purchase_Properties__c = 'All AR';
        municipality2.Purchase_Portfolio_Income_Levels__c = 'Moderate;Low;';
        municipality2.Purchase_Unit_Size__c = '1';
        municipality2.Purchase_Waiting_List__c = 'Less than 2 yr';
        municipality2.Purchase_Waiting_List_Type__c = 'Random Selection';
        municipality2.Purchase_Units__c = 5;
        insert municipality2;
        system.assertNotEquals(municipality1.id,null);
        
        //Municipality_Preference__c object
        Municipality_Preference__c municipalityPreference1 = new Municipality_Preference__c();
        municipalityPreference1.Name = 'TownshipPref1';
        municipalityPreference1.Municipality__c = municipality1.id;
        municipalityPreference1.PreApplicant__c = applicant1.id; 
        municipalityPreference1.Status__c = 'Active';
        municipalityPreference1.Type__c = 'Rental';
        insert municipalityPreference1;
        system.assertNotEquals(municipalityPreference1.id,null);
        
        
        //Municipality_Preference__c object
        Municipality_Preference__c municipalityPreference2 = new Municipality_Preference__c();
        municipalityPreference2.Name = 'TownshipPref2';
        municipalityPreference2.Municipality__c = municipality2.id;
        municipalityPreference2.PreApplicant__c = applicant1.id; 
        municipalityPreference2.Status__c = 'Active';
        municipalityPreference2.Type__c = 'Rental';
        insert municipalityPreference2;
        system.assertNotEquals(municipalityPreference2.id,null);
        
        
        //Purchase Municipality_Preference__c Object
        Municipality_Preference__c municipalityPreference3 = new Municipality_Preference__c();
        municipalityPreference3.Name = 'TownshipPref3';
        municipalityPreference3.Municipality__c = municipality1.id;
        municipalityPreference3.PreApplicant__c = applicant1.id; 
        municipalityPreference3.Status__c = 'Active';
        municipalityPreference3.Type__c = 'Ownership';
        insert municipalityPreference3;
        system.assertNotEquals(municipalityPreference3.id,null);
        
        //Purchase Municipality_Preference__c Object
        Municipality_Preference__c municipalityPreference4 = new Municipality_Preference__c();
        municipalityPreference4.Name = 'TownshipPref4';
        municipalityPreference4.Municipality__c = municipality2.id;
        municipalityPreference4.PreApplicant__c = applicant1.id; 
        municipalityPreference4.Status__c = 'Active';
        municipalityPreference4.Type__c = 'Ownership';
        insert municipalityPreference4;
        system.assertNotEquals(municipalityPreference4.id,null);
        
        //After Insert Trigger Test 
        //applicant1 = [Select Id, PreApplicant_Encoded_Id__c From PreApplicants__c Where Id = : applicant1.id];
        //String strAppId = EncodingUtil.base64Decode(applicant1.PreApplicant_Encoded_Id__c).toString();
        //system.assertEquals(strAppId,applicant1.id);
        
        ///Before Update Trigger Test///
        set<id> setMunicipalPrefIds = new set<id>();
        set<id> setMunicipalityIds = new set<id>();
        List<Municipality_Preference__c> lstMunicipalPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstToUpdateMunPreference = new List<Municipality_Preference__c>();
        List<Municipality__c> lstMunicipality = new List<Municipality__c>();
        List<Municipality__c> lstToUpdateMunicipality = new List<Municipality__c>();
        
        setMunicipalPrefIds.add(municipalityPreference1.id);
        setMunicipalPrefIds.add(municipalityPreference2.id);
        setMunicipalPrefIds.add(municipalityPreference3.id);
        setMunicipalPrefIds.add(municipalityPreference4.id);
        
        setMunicipalityIds.add(municipality1.id);
        setMunicipalityIds.add(municipality2.id);
        
        lstMunicipality = [Select Purchase_Portfolio__c, Rental_Portfolio__c  FROM Municipality__c Where Id IN: setMunicipalityIds];
        
         List<Municipality_Preference__c> lstRentalMunicipalityPreference = new List<Municipality_Preference__c>();
        List<Municipality_Preference__c> lstOwnerMunicipalityPreference = new List<Municipality_Preference__c>();
        lstRentalMunicipalityPreference = [Select Id, Type__c, Township_Interest_ID__c, Status__c, 
                  Removal_Trigger__c, Removal_Date__c, PreApplicant__c,
                  Name, Municipality__c,  Interest_Date__c, Ineligibilty_Reason__c, Municipality__r.Name
                  From Municipality_Preference__c Where  Type__c = 'Rental' AND Status__c = 'Active'];
                  
        lstOwnerMunicipalityPreference = [Select Id, Type__c, Township_Interest_ID__c, Status__c, 
                  Removal_Trigger__c, Removal_Date__c, PreApplicant__c,
                  Name, Municipality__c,  Interest_Date__c, Ineligibilty_Reason__c, Municipality__r.Name
                  From Municipality_Preference__c Where Type__c = 'Ownership' AND Status__c = 'Active'];
                  
       system.debug('In the test method : '+lstRentalMunicipalityPreference);
       system.debug('In the test method : '+lstOwnerMunicipalityPreference);
        
        
        // check for basic condition
        applicant1.Household_Size__c = '9+';
        update applicant1;
        
        
        Test.startTest();
        
        //5th Condition
        applicant1.Household_Members_55__c = true;
        applicant1.Section_8__c = false;
        update applicant1;
        
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,false);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
            //system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        //6th condition
        applicant1.Section_8__c = true;
        update applicant1;
        
            
        lstMunicipalPreference = [Select Status__c,Ineligibilty_Reason__c, PreApplicant__r.Section_8__c FROM Municipality_Preference__c Where Id IN: setMunicipalPrefIds];
        for(Municipality_Preference__c municipalPref : lstMunicipalPreference){
            system.assertEquals(municipalPref.PreApplicant__r.Section_8__c,true);
            //system.assertNotEquals(municipalPref.Ineligibilty_Reason__c,null);
        //  system.assertEquals(municipalPref.Status__c,'Ineligible');
            municipalPref.Status__c = 'Active';
            municipalPref.Ineligibilty_Reason__c = '';
            lstToUpdateMunPreference.add(municipalPref);
        }
        if(lstToUpdateMunPreference != null && lstToUpdateMunPreference.size() > 0){
            update lstToUpdateMunPreference;
            lstToUpdateMunPreference.clear();
        }
        
        // check for preapplicant ineligibility
        applicant1.Household_Size__c = '9+';
        applicant1.Live_Work_Regions__c = '';
        applicant1.Annual_Income__c = null;
        applicant1.Monthly_Other_Assistance__c = null;
        update applicant1;
                
        //Test.stopTest();  
 //     }catch(exception e){}
        Test.stopTest();
    }
    
    
}