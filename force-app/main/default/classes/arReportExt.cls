public with sharing class arReportExt {
    public List<Invoice__c> iList {get; set;}
    public List<Account> aList {get; set;}
   
    public String showIL0block {get; set;}
    public String showIL1block {get; set;}
    public String showIL2block {get; set;}
    public String showIL3block {get; set;}
    public String showIL4block {get; set;}
    public String showIL5block {get; set;}
    public String showIL6block {get; set;}
    public String showIL7block {get; set;}
    public String showIL8block {get; set;}
    public String showIL9block {get; set;}
    public String showIL10block {get; set;}
    public String showIL11block {get; set;}
    public String showIL12block {get; set;}
    public String showIL13block {get; set;}
    public String showIL14block {get; set;}
    public String showIL15block {get; set;}
    public String showIL16block {get; set;}
    public String showIL17block {get; set;}
    public String showIL18block {get; set;}
    public String showIL19block {get; set;}
    
    public String showIL0 {get; set;}
    public String showIL1 {get; set;}
    public String showIL2 {get; set;}
    public String showIL3 {get; set;}
    public String showIL4 {get; set;}
    public String showIL5 {get; set;}
    public String showIL6 {get; set;}
    public String showIL7 {get; set;}
    public String showIL8 {get; set;}
    public String showIL9 {get; set;}
    public String showIL10 {get; set;}
    public String showIL11 {get; set;}
    public String showIL12 {get; set;}
    public String showIL13 {get; set;}
    public String showIL14 {get; set;}
    public String showIL15 {get; set;}
    public String showIL16 {get; set;}
    public String showIL17 {get; set;}
    public String showIL18 {get; set;}
    public String showIL19 {get; set;}
    
    public list<Invoice__c> invList0 {get; set;}
    public list<Invoice__c> invList1 {get; set;}
    public list<Invoice__c> invList2 {get; set;}
    public list<Invoice__c> invList3 {get; set;}
    public list<Invoice__c> invList4 {get; set;}
    public list<Invoice__c> invList5 {get; set;}
    public list<Invoice__c> invList6 {get; set;}
    public list<Invoice__c> invList7 {get; set;}
    public list<Invoice__c> invList8 {get; set;}
    public list<Invoice__c> invList9 {get; set;}
    public list<Invoice__c> invList10 {get; set;}
    public list<Invoice__c> invList11 {get; set;}
    public list<Invoice__c> invList12 {get; set;}
    public list<Invoice__c> invList13 {get; set;}
    public list<Invoice__c> invList14 {get; set;}
    public list<Invoice__c> invList15 {get; set;}
    public list<Invoice__c> invList16 {get; set;}
    public list<Invoice__c> invList17 {get; set;}
    public list<Invoice__c> invList18 {get; set;}
    public list<Invoice__c> invList19 {get; set;}  
    
    public String showFlow {get; set;}
    public String showSwitch {get; set;}
    
    public Integer numAccts {get; set;}
    
public arReportExt(ApexPages.StandardController c){
    showFlow='false';
    showSwitch='true';
    
    showIL0block ='false';
    showIL1block ='false';
    showIL2block ='false';
    showIL3block ='false';
    showIL4block ='false';
    showIL5block ='false';
    showIL6block ='false';
    showIL7block ='false';
    showIL8block ='false';
    showIL9block ='false';
    showIL10block ='false';
    showIL11block ='false';
    showIL12block ='false';
    showIL13block ='false';
    showIL14block ='false';
    showIL15block ='false';
    showIL16block ='false';
    showIL17block ='false';
    showIL18block ='false';
    showIL19block ='false';
    
    showIL0 ='true';
    showIL1 ='true';
    showIL2 ='true';
    showIL3 ='true';
    showIL4 ='true';
    showIL5 ='true';
    showIL6 ='true';
    showIL7 ='true';
    showIL8 ='true';
    showIL9 ='true';
    showIL10 ='true';
    showIL11 ='true';
    showIL12 ='true';
    showIL13 ='true';
    showIL14 ='true';
    showIL15 ='true';
    showIL16 ='true';
    showIL17 ='true';
    showIL18 ='true';
    showIL19 ='true';  
    
    Account nullList = new Account();
    aList=[SELECT id, name FROM Account WHERE (Current_Past_Due__c= true) ORDER BY name ASC];
        numAccts= aList.size();
        integer blanksNeeded = 20-numAccts;
        integer bn = 0;
        while(bn<blanksNeeded){
        aList.add(nullList);
        bn++;
        }
             
    iList=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c 
          FROM Invoice__c WHERE (invoiceAccountID__c=:ApexPages.currentPage().getParameters().get('Id')) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC];
          
    if(numAccts>0) { String acctID0 = aList[0].Id; String acctID0fix = acctID0.left(15); 
        invList0=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
                  (invoiceAccountID__c=:acctID0fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL0block='true'; } 
    if(numAccts>1) { String acctID1 = aList[1].Id; String acctID1fix = acctID1.left(15); 
        invList1=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
                  (invoiceAccountID__c=:acctID1fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC];showIL1block='true'; }
    if(numAccts>2) { String acctID2 = aList[2].Id; String acctID2fix = acctID2.left(15); 
        invList2=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
                  (invoiceAccountID__c=:acctID2fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC];showIL2block='true'; }
    if(numAccts>3){ String acctID3 = aList[3].Id; String acctID3fix = acctID3.left(15);
    invList3=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
                (invoiceAccountID__c=:acctID3fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC];showIL3block='true';}
    if(numAccts>4){ string acctID4 = aList[4].Id; string acctID4fix = acctID4.left(15);
    invList4=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID4fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL4block='true';}                     
    if(numAccts>5){ string acctID5 = aList[5].Id; string acctID5fix = acctID5.left(15);
    invList5=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID5fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL5block='true';}    
    if(numAccts>6){ string acctID6 = aList[6].Id; string acctID6fix = acctID6.left(15);
    invList6=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID6fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL6block='true';}    
    if(numAccts>7){ string acctID7 = aList[7].Id; string acctID7fix = acctID7.left(15);
    invList7=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID7fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL7block='true';}    
    if(numAccts>8){ string acctID8 = aList[8].Id; string acctID8fix = acctID8.left(15);
    invList8=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID8fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL8block='true';}             
    if(numAccts>9){ string acctID9 = aList[9].Id; string acctID9fix = acctID9.left(15);
    invList9=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID9fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL9block='true';}       
    
    if(numAccts>10){ string acctID10 = aList[10].Id; string acctID10fix = acctID10.left(15);
    invList10=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID10fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL10block='true';}       
    if(numAccts>11){ string acctID11 = aList[11].Id; string acctID11fix = acctID11.left(15);
    invList11=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID11fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC];showIL11block='true';}
    if(numAccts>12){ string acctID12 = aList[12].Id; string acctID12fix = acctID12.left(15);
    invList12=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID12fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC];showIL12block='true';}
    if(numAccts>13){ string acctID13 = aList[13].Id; string acctID13fix = acctID13.left(15);
    invList13=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID13fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC];showIL13block='true';}
    if(numAccts>14){ string acctID14 = aList[14].Id; string acctID14fix = acctID14.left(15);
    invList14=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID14fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC];  showIL14block='true';}                    
    if(numAccts>15){ string acctID15 = aList[15].Id; string acctID15fix = acctID15.left(15);
    invList15=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID15fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL15block='true';}    
    if(numAccts>16){ string acctID16 = aList[16].Id; string acctID16fix = acctID16.left(15);
    invList16=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID16fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL16block='true';}    
    if(numAccts>17){ string acctID17 = aList[17].Id; string acctID17fix = acctID17.left(15);
    invList17=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID17fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL17block='true';}    
    if(numAccts>18){ string acctID18 = aList[18].Id; string acctID18fix = acctID18.left(15);
    invList18=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID18fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC]; showIL18block='true';}            
    if(numAccts>19){ string acctID19 = aList[19].Id; string acctID19fix = acctID19.left(15);
    invList19=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c FROM Invoice__c WHERE 
             (invoiceAccountID__c=:acctID19fix) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC];  showIL19block='true';}
                                
     
 }

    public void switchRender0(){ if (showIL0 =='false'){showIL0='true';} else {showIL0='false';}}
    public void switchRender1(){ if (showIL1 =='false'){showIL1='true';} else {showIL1='false';}} 
    public void switchRender2(){ if (showIL2 =='false'){showIL2='true';} else {showIL2='false';}}
    public void switchRender3(){ if (showIL3 =='false'){showIL3='true';} else {showIL3='false';}}
    public void switchRender4(){ if (showIL4 =='false'){showIL4='true';} else {showIL4='false';}}
    public void switchRender5(){ if (showIL5 =='false'){showIL5='true';} else {showIL5='false';}}
    public void switchRender6(){ if (showIL6 =='false'){showIL6='true';} else {showIL6='false';}}
    public void switchRender7(){ if (showIL7 =='false'){showIL7='true';} else {showIL7='false';}}
    public void switchRender8(){ if (showIL8 =='false'){showIL8='true';} else {showIL8='false';}}
    public void switchRender9(){ if (showIL9 =='false'){showIL9='true';} else {showIL9='false';}}
    public void switchRender10(){ if (showIL10 =='false'){showIL10='true';} else {showIL10='false';}}
    public void switchRender11(){ if (showIL11 =='false'){showIL11='true';} else {showIL11='false';}} 
    public void switchRender12(){ if (showIL12 =='false'){showIL12='true';} else {showIL12='false';}}
    public void switchRender13(){ if (showIL13 =='false'){showIL13='true';} else {showIL13='false';}}
    public void switchRender14(){ if (showIL14 =='false'){showIL14='true';} else {showIL14='false';}}
    public void switchRender15(){ if (showIL15 =='false'){showIL15='true';} else {showIL15='false';}}
    public void switchRender16(){ if (showIL16 =='false'){showIL16='true';} else {showIL16='false';}}
    public void switchRender17(){ if (showIL17 =='false'){showIL17='true';} else {showIL17='false';}}
    public void switchRender18(){ if (showIL18 =='false'){showIL18='true';} else {showIL18='false';}}
    public void switchRender19(){ if (showIL19 =='false'){showIL19='true';} else {showIL19='false';}} 
    
    
    
    public void showFlowT() {
    showFlow='true';
    showSwitch='false';
    }
    public void showFlowF() {
    showFlow='false';
    showSwitch='true';
    }







}