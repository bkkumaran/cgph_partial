public class contInvoiceExt {

    public List<Invoice__c> invList {get; set;}
    public List<Invoice__c> invList2 {get; set;}
    public Integer invList2size {get; set;}

    public contInvoiceExt(ApexPages.StandardController controller) {
        invList = [SELECT Id, Name, Invoice_Image_URL__c, Invoice_Date__c, Invoice_Amount_ADJ__c, Invoice_Adjustment__c, Amount_AA__c, Amount_GS__c, Amount_HR__c, Receivables_Notes__c, Sent_Date__c, TSC_Text_Calc__c, Payment_Remaining__c, Invoice_Amount__c, Time_Paid_Unpaid__c, Days_Unpaid__c, Purchase_Order__c, Purchase_Order_URL__c, PO_Date_Sent__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c 
                   FROM Invoice__c
                   WHERE Salesforce_Contract__c=: ApexPages.currentPage().getParameters().get('Id') AND Inv_In_Progress__c = false
                   ORDER BY Name DESC];
        invList2 = [SELECT Id, Name, Invoice_Image_URL__c, Invoice_Date__c, Invoice_Amount_ADJ__c, Amount_AA__c, Amount_GS__c, Amount_HR__c, Receivables_Notes__c, Sent_Date__c, TSC_Text_Calc__c, Payment_Remaining__c, Invoice_Amount__c, Time_Paid_Unpaid__c, Days_Unpaid__c, Purchase_Order__c, Purchase_Order_URL__c, PO_Date_Sent__c, Invoice_A_R_Note_Date__c, Report_A_R_Notes__c 
                   FROM Invoice__c
                   WHERE Salesforce_Contract__c=: ApexPages.currentPage().getParameters().get('Id2') AND Inv_In_Progress__c = false AND Invoice_Paid__c = false
                   ORDER BY Name DESC];
        invList2size = invList2.size();
    }


}