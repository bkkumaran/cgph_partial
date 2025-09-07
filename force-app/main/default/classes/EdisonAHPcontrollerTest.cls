@isTest
public class EdisonAHPcontrollerTest {
    static testMethod void EdisonAHPcontrollerTest(){
        PreApplicants__c objPreApp = new PreApplicants__c();
        objPreApp.name = 'test';
        objPreApp.Annual_Income__c = 75000;
		objPreApp.Household_Size__c = '2';
		objPreApp.First_Name__c = 'Test';
		objPreApp.Last_Name__c = 'test';
		objPreApp.Email__c = 'test@test.com';
        Insert objPreApp;

		Income_Limits__c objLimit = new Income_Limits__c();
        objLimit.Name = 'test';
        objLimit.X1_Person__c = 100000;
        objLimit.X2_Person__c = 100000;
        objLimit.X3_Person__c = 100000;
        objLimit.X4_Person__c = 100000;
        objLimit.X5_Person__c = 100000;
        objLimit.X6_Person__c = 100000;
        objLimit.X7_Person_Median__c = 100000;
        objLimit.X7_Person_Median__c = 100000;
        Insert objLimit;

        Municipality__c objMuni= new Municipality__c();
        objMuni.name = 'Edison';
        objMuni.Equalization_Ratio__c = 36.48;
		objMuni.General_Tax_Rate__c = 5.7;
        objMuni.Income_Limit__c = objLimit.Id;
        Insert objMuni;
        
        CGPH_Profile_Custom_Settings__c objCS = new CGPH_Profile_Custom_Settings__c();
        objCS.Mortgage_Rate__c = 5;
        objCS.Insurance_4_Bedroom__c = 30;
        objCS.PMI_Rate_for_LTV_90__c = 1;
        Insert objCS;
        
        ApexPages.currentPage().getParameters().put('code', objPreApp.Id);
        ApexPages.currentPage().getParameters().put('display', 'show');
        ApexPages.currentPage().getParameters().put('lp', '350000');
        ApexPages.currentPage().getParameters().put('br', '2');
        ApexPages.currentPage().getParameters().put('hoa', '200');
        ApexPages.currentPage().getParameters().put('dp', '2500');
                                                    
		EdisonAHPcontroller controller = new EdisonAHPcontroller();
        controller.Bedrooms = 2;
        controller.Median = 120000;
        controller.tModIncome=100000;
        controller.tModIncomeGet(controller.bedrooms, controller.Median);
		controller.tMaxMonthlyCostGet(100000);
        

        

        

		

    }
}