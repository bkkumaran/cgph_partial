public class unpaidListExt {
    public List<Invoice__c> uList{get;set;}
    public String showFlow {get; set;}
    public String showSwitch {get; set;}

    public unpaidListExt(ApexPages.StandardController c){
    showFlow='false';
    showSwitch='true';
      uList=[SELECT id, name, Invoice_Date__c, Sent_Date__c, Invoice_Amount__c, Days_Unpaid__c, Purchase_Order__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c, PO_Date_Sent__c, Purchase_Order_URL__c, Invoice_Image_URL__c 
      FROM Invoice__c WHERE (invoiceAccountID__c=:ApexPages.currentPage().getParameters().get('AcctId')) AND (Invoice_Paid__c=FALSE) ORDER BY Name DESC];
    }   
   
    public PageReference getURLstring() {
        return new PageReference('/apex/tabContract?Id=' + (ApexPages.currentPage().getParameters().get('Id')) + '&AcctId=' + (ApexPages.currentPage().getParameters().get('AcctId')));
    }
    
//    public String pDueClass(Integer pd){
//        String pdRowClass;
//        if(pd < 31) { pdRowClass = 'pDue90';} 
//        if(pd > 30 && pd < 61) { pdRowClass = 'pDue30';}
//        if(pd > 60 && pd < 91) { pdRowClass = 'pDue60';}
//        if(pd > 90 && pd < 121) { pdRowClass = 'pDue90';}
//        if(pd > 120) { pdRowClass = 'pDue120';}
//    return pdRowClass;
//    }
    
    public void showFlowT() {
    showFlow='true';
    showSwitch='false';
    }
    public void showFlowF() {
    showFlow='false';
    showSwitch='true';
    }
}