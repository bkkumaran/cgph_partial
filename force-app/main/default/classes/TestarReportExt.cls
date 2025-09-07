@istest
public class TestarReportExt {
    Private static testmethod void TestarReportExt(){
       
        Account objAcct = new Account();
        objAcct.name = 'TestAccount';
        insert objAcct;
        
    ApexPages.currentPage().getParameters().put('x',objAcct.Id);
    ApexPages.StandardController stdAcct = new ApexPages.StandardController(objAcct);
    arReportExt objarReportExt = new arReportExt(stdAcct);
        
    objarReportExt.showFlowF();
    objarReportExt.showFlowT();    

/*        Invoice__c objInv = new Invoice__c();
        objInv.name = '12345';
        objInv.Invoice_Date__c = Date.today();
        objInv.Sent_Date__c = Date.today();
        objInv.Invoice_Amount__c = 123.45;
        objInv.Purchase_Order__c = '17-12345';
        objInv.Invoice_A_R_Note_Date__c = Date.today();
        objInv.PO_Date_Sent__c = Date.today();
        objInv.Salesforce_Contract__c = '800c0000000YFNa';
        insert objInv; */
           

     objarReportExt.invList0 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList1 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList2 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList3 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList4 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList5 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList6 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList7 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList8 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList9 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];   
     objarReportExt.invList10 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList11 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList12 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList13 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList14 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList15 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList16 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList17 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList18 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];
     objarReportExt.invList19 = [SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE name='12345' ORDER BY Name DESC];   
     	objarReportExt.switchRender0();
     	objarReportExt.switchRender1(); 
        objarReportExt.switchRender2(); 
        objarReportExt.switchRender3(); 
        objarReportExt.switchRender4(); 
        objarReportExt.switchRender5(); 
        objarReportExt.switchRender6(); 
        objarReportExt.switchRender7(); 
        objarReportExt.switchRender8(); 
		objarReportExt.switchRender9(); 
        objarReportExt.switchRender10();
     	objarReportExt.switchRender11(); 
        objarReportExt.switchRender12(); 
        objarReportExt.switchRender13(); 
        objarReportExt.switchRender14(); 
        objarReportExt.switchRender15(); 
        objarReportExt.switchRender16(); 
        objarReportExt.switchRender17(); 
        objarReportExt.switchRender18();
    	objarReportExt.switchRender19(); 
    }
}