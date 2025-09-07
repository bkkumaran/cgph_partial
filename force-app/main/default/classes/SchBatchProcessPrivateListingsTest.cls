@isTest
public class SchBatchProcessPrivateListingsTest {
    @isTest
    public static void unitestRental(){
        Test.startTest();
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPHTestFactory.createCGPHProfileCustomSettings();
        //Object creation using helper class
        Income_Limits__c r1IncomeLimit = CGPHTestFactory.createIncomeLimit('1');
        Income_Limits__c r2IncomeLimit = CGPHTestFactory.createIncomeLimit('2');
        Income_Limits__c r3IncomeLimit = CGPHTestFactory.createIncomeLimit('3');
        Income_Limits__c r4IncomeLimit = CGPHTestFactory.createIncomeLimit('4');
        Income_Limits__c r5IncomeLimit = CGPHTestFactory.createIncomeLimit('5');
        Income_Limits__c r6IncomeLimit = CGPHTestFactory.createIncomeLimit('6');
        
        PreApplicants__c applicant1 = CGPHTestFactory.createPreapplicant(true,false,true);
        List<string> lstPreAppId= new List<string>();
        
        Municipality__c objmunicipality1 = CGPHTestFactory.createMunicipalityObject('Township1','1',false,false,'All AR','All AR',true,true,0,'Moderate;Low;Very Low','Moderate;Low;Very Low');//condition1
        
        Municipality_Preference__c rentalMunicipalPref1 = CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id, applicant1.id, 'Rental');
        
        
        Municipality_Preference__c purchaseMunicipalPref1 = CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id, applicant1.id, 'Ownership');
        
        HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality1.id,'Rental Unit','Available For Rent - Immediate Occupancy');
        List<HOMEtracker__Property__c> lstProperty= new List<HOMEtracker__Property__c>();
        
        
        
        Campaign camp = CGPHTestFactory.createCampaign();
        property.Campaign__c = camp.id;
        property.Age_Restriction__c='None';
        property.Maximum_Household_Size__c=8;
        property.HOMEtracker__Number_of_Bedrooms__c='1';
        property.Listing_Stage__c = 'Region and bedroom/household size restricted';
        update property;
        lstProperty.add(property);
        
        Contact c = CGPHTestFactory.createContact();
        PreApplicants__c preApp = CGPHTestFactory.createPreapplicant(true, true,true);
        preApp.Property__c = property.id;
        preApp.Contact__c = c.id;
        preApp.AR_Properties_Only__c=true;
         preApp.Household_Size__c='9+';
        preApp.Live_Work_Regions__c=null;
        update preApp;      
        lstPreAppId.add(preApp.id);
        
        
        CampaignMember member = new CampaignMember();
        member.ContactId = c.id;
        member.CampaignId = camp.id;
        insert member;
        SchBatchProcessPrivateListings sch= new  SchBatchProcessPrivateListings(property.Id,lstProperty,lstPreAppId);        
        sch.mapCampaignMember.put(c.id,member);
        database.executeBatch(sch,200);
        sch.execute(null);
       
        test.stopTest(); 
    }
    
    
    @isTest
    public static void unitestRental2(){
        Test.startTest();
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPHTestFactory.createCGPHProfileCustomSettings();
        //Object creation using helper class
        Income_Limits__c r1IncomeLimit = CGPHTestFactory.createIncomeLimit('1');
        Income_Limits__c r2IncomeLimit = CGPHTestFactory.createIncomeLimit('2');
        Income_Limits__c r3IncomeLimit = CGPHTestFactory.createIncomeLimit('3');
        Income_Limits__c r4IncomeLimit = CGPHTestFactory.createIncomeLimit('4');
        Income_Limits__c r5IncomeLimit = CGPHTestFactory.createIncomeLimit('5');
        Income_Limits__c r6IncomeLimit = CGPHTestFactory.createIncomeLimit('6');
        
        PreApplicants__c applicant1 = CGPHTestFactory.createPreapplicant(true,false,true);
        List<string> lstPreAppId= new List<string>();
        
        Municipality__c objmunicipality1 = CGPHTestFactory.createMunicipalityObject('Township1','1',false,false,'All AR','All AR',true,true,0,'Moderate;Low;Very Low','Moderate;Low;Very Low');//condition1
        
        Municipality_Preference__c rentalMunicipalPref1 = CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id, applicant1.id, 'Rental');
        
        
        Municipality_Preference__c purchaseMunicipalPref1 = CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id, applicant1.id, 'Ownership');
        
        HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality1.id,'Rental Unit','Available For Rent - Immediate Occupancy');
        List<HOMEtracker__Property__c> lstProperty= new List<HOMEtracker__Property__c>();
        
        
        
        Campaign camp = CGPHTestFactory.createCampaign();
        property.Campaign__c = camp.id;
        property.Age_Restriction__c='None';
        update property;
        lstProperty.add(property);
        
        Contact c = CGPHTestFactory.createContact();
        PreApplicants__c preApp = CGPHTestFactory.createPreapplicant(true, true,true);
        preApp.Property__c = property.id;
        preApp.Contact__c = c.id;
        preApp.AR_Properties_Only__c=true;
        update preApp;      
        lstPreAppId.add(preApp.id);
        
        
        CampaignMember member = new CampaignMember();
        member.ContactId = c.id;
        member.CampaignId = camp.id;
        insert member;
        SchBatchProcessPrivateListings sch= new  SchBatchProcessPrivateListings(property.Id,lstProperty,lstPreAppId);        
        sch.mapCampaignMember.put(c.id,member);
        database.executeBatch(sch,200);
        sch.execute(null);
        preApp.AR_Properties_Only__c=false;
        
        property.Age_Restriction__c='Over 18';
        update property;
        update preApp;  
        
        
        SchBatchProcessPrivateListings sch1= new  SchBatchProcessPrivateListings(property.Id,lstProperty,lstPreAppId);        
        sch1.mapCampaignMember.put(c.id,member);
        database.executeBatch(sch1,200);
        sch1.execute(null);
        test.stopTest(); 
    }
    @isTest
    public static void unitestHomeownership(){
        Test.startTest();
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPHTestFactory.createCGPHProfileCustomSettings();
        //Object creation using helper class
        Income_Limits__c r1IncomeLimit = CGPHTestFactory.createIncomeLimit('1');
        Income_Limits__c r2IncomeLimit = CGPHTestFactory.createIncomeLimit('2');
        Income_Limits__c r3IncomeLimit = CGPHTestFactory.createIncomeLimit('3');
        Income_Limits__c r4IncomeLimit = CGPHTestFactory.createIncomeLimit('4');
        Income_Limits__c r5IncomeLimit = CGPHTestFactory.createIncomeLimit('5');
        Income_Limits__c r6IncomeLimit = CGPHTestFactory.createIncomeLimit('6');
        
        PreApplicants__c applicant1 = CGPHTestFactory.createPreapplicant(true,false,true);
        List<string> lstPreAppId= new List<string>();
        
        Municipality__c objmunicipality1 = CGPHTestFactory.createMunicipalityObject('Township1','1',false,false,'All AR','All AR',true,true,0,'Moderate;Low;Very Low','Moderate;Low;Very Low');//condition1
        
         
        
        
        Municipality_Preference__c purchaseMunicipalPref1 = CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id, applicant1.id, 'Ownership');
        
        HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality1.id,'Homeownership','Available for Sale/Resale');
        List<HOMEtracker__Property__c> lstProperty= new List<HOMEtracker__Property__c>();
        
        
        
        Campaign camp = CGPHTestFactory.createCampaign();
        property.Campaign__c = camp.id;
        property.Age_Restriction__c='None';
        property.Maximum_Household_Size__c=8;
        property.Listing_Stage__c = 'Region and bedroom/household size restricted';
        update property;
        lstProperty.add(property);
        
        Contact c = CGPHTestFactory.createContact();
        PreApplicants__c preApp = CGPHTestFactory.createPreapplicant(true, true,true);
        preApp.Property__c = property.id;
        preApp.Contact__c = c.id;
        preApp.AR_Properties_Only__c=true;
        preApp.Household_Size__c='9+';
        preApp.Live_Work_Regions__c=null;
        update preApp;      
        lstPreAppId.add(preApp.id);
        
        
        CampaignMember member = new CampaignMember();
        member.ContactId = c.id;
        member.CampaignId = camp.id;
        insert member;
        SchBatchProcessPrivateListings sch= new  SchBatchProcessPrivateListings(property.Id,lstProperty,lstPreAppId);        
        sch.mapCampaignMember.put(c.id,member);
        database.executeBatch(sch,200);
        sch.execute(null);
        
        test.stopTest(); 
    }
     @isTest
    public static void unitestHomeownership1(){
        Test.startTest();
        CGPH_Profile_Custom_Settings__c cgphProfileSettings = CGPHTestFactory.createCGPHProfileCustomSettings();
        //Object creation using helper class
        Income_Limits__c r1IncomeLimit = CGPHTestFactory.createIncomeLimit('1');
        Income_Limits__c r2IncomeLimit = CGPHTestFactory.createIncomeLimit('2');
        Income_Limits__c r3IncomeLimit = CGPHTestFactory.createIncomeLimit('3');
        Income_Limits__c r4IncomeLimit = CGPHTestFactory.createIncomeLimit('4');
        Income_Limits__c r5IncomeLimit = CGPHTestFactory.createIncomeLimit('5');
        Income_Limits__c r6IncomeLimit = CGPHTestFactory.createIncomeLimit('6');
        
        PreApplicants__c applicant1 = CGPHTestFactory.createPreapplicant(true,false,true);
        List<string> lstPreAppId= new List<string>();
        
        Municipality__c objmunicipality1 = CGPHTestFactory.createMunicipalityObject('Township1','1',false,false,'All AR','All AR',true,true,0,'Moderate;Low;Very Low','Moderate;Low;Very Low');//condition1
        
         
        
        
        Municipality_Preference__c purchaseMunicipalPref1 = CGPHTestFactory.createMunicipalityPreference(objmunicipality1.id, applicant1.id, 'Ownership');
        
        HOMEtracker__Property__c property = CGPHTestFactory.createProperty(objmunicipality1.id,'Homeownership','Available for Sale/Resale');
        List<HOMEtracker__Property__c> lstProperty= new List<HOMEtracker__Property__c>();
        
        
        
        Campaign camp = CGPHTestFactory.createCampaign();
        property.Campaign__c = camp.id;
        property.Age_Restriction__c='None';
        update property;
        lstProperty.add(property);
        
        Contact c = CGPHTestFactory.createContact();
        PreApplicants__c preApp = CGPHTestFactory.createPreapplicant(true, true,true);
        preApp.Property__c = property.id;
        preApp.Contact__c = c.id;
        preApp.AR_Properties_Only__c=true;
        update preApp;      
        lstPreAppId.add(preApp.id);
        
        
        CampaignMember member = new CampaignMember();
        member.ContactId = c.id;
        member.CampaignId = camp.id;
        insert member;
        SchBatchProcessPrivateListings sch= new  SchBatchProcessPrivateListings(property.Id,lstProperty,lstPreAppId);        
        sch.mapCampaignMember.put(c.id,member);
        database.executeBatch(sch,200);
        sch.execute(null);
        preApp.AR_Properties_Only__c=false;
        
        property.Age_Restriction__c='Over 18';
        update property;
        update preApp;  
        
        
        SchBatchProcessPrivateListings sch1= new  SchBatchProcessPrivateListings(property.Id,lstProperty,lstPreAppId);        
        sch1.mapCampaignMember.put(c.id,member);
        database.executeBatch(sch1,200);
        sch1.execute(null);
        test.stopTest(); 
    }
    
}