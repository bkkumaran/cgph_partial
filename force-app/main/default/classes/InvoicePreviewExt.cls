public with sharing class InvoicePreviewExt {
    
    Public List<Invoice_Entry__c> listIE {get; set;}
    Public List<Invoice_Entry__c> listIEdnb {get; set;}
    Public List<Invoice_Entry__c> listOld {get; set;}
    
    public Integer listSize {get; set;}
    public Integer listSizeDNB {get; set;}
    public Integer listOldSize {get; Set;}
    
    public Decimal sumTime {get; set;}
    public Decimal sumAmount {get; set;}
    
    public Decimal sumDNBtime {get; set;}
    public Decimal sumDNBamount {get; set;}
    
    public Decimal diffAmount {get; set;}
    public Decimal diffTime {get; set;}
    
    
    
    public InvoicePreviewExt(ApexPages.StandardController controller) {

        Invoice__c invRecord = (Invoice__c)controller.getRecord();
        Date invDate = invRecord.Invoice_Date__c;
        String invSetupId = invRecord.TimeSlipsContract__r.Id;
        
        sumTime = 0.0;
        Decimal sumTimeX = 0.0;
        sumAmount = 0.0;
        Decimal sumAmountX = 0.0;
        sumDNBtime = 0.0;
        sumDNBamount = 0.0;
        Decimal sumDNBtimeX = 0.0;
        Decimal sumDNBAmountX = 0.0;
        diffTime = 0.0;
        diffAmount = 0.0;
        
        listIE = [ SELECT
                  Id,
                  Name,
                  Invoice_Setup__c,
                  Do_Not_Bill__c,
                  Invoice_Setup__r.Id,
                  Invoice_Setup__r.Name,
                  Invoice_Reference__r.Name,
                  Invoice_Reference__c,
                  Billing_Term__r.Name,
                  Billing_Term__c,
                  Date_Initials__c,
                  Date__c,
                  Staff__r.Name,
                  Staff__c,
                  Description__c,
                  Time_Spent__c,
                  Hourly_Rate__c,
                  Amount__c,
                  Records_Check__c
                  FROM Invoice_Entry__c
                  WHERE Invoice_Record__c = :ApexPages.currentPage().getParameters().get('id')
                  ORDER BY Order__c ASC
                 ];
        listSize = listIE.size();
        
        IF (listSize == 0) {
            listIE = NULL;
        } ELSE {
     
        FOR( Invoice_Entry__c x : listIE) {
            IF(x.Time_Spent__c == NULL) {
               sumTimeX = 0.0; 
            } ELSE {
                sumTimeX = x.Time_Spent__c;
            }
            IF(x.Amount__c == NULL) {
               sumAmountX = 0.0; 
            } ELSE {
                sumAmountX = x.Amount__c;
            }
            sumTime = sumTime + sumTimeX;
            sumAmount = sumAmount + sumAmountX;
        }       
        }
        

        listOld = [ SELECT Id
            FROM Invoice_Entry__c
            WHERE (Invoice_Setup__c = :invSetupId) AND (Invoice_Record__c = '')  AND (Date__C <= :invDate) AND (Do_Not_Bill__c = false)
        ];
        
        listOldSize = listOld.size();
        
        IF (listSize == 0) {
            listOld = NULL;
        }
        
        
        listIEdnb = [ SELECT Id, Amount__c, Time_Spent__c, Do_Not_Bill__c
                  FROM Invoice_Entry__c
                  WHERE Invoice_Record__c = :ApexPages.currentPage().getParameters().get('id') AND Do_Not_Bill__c = true
                  ORDER BY Order__c ASC
                 ];
        
        listSizeDNB = listIEdnb.size();
        
        IF (listSizeDNB == 0) {
            listIEdnb = NULL;
        } ELSE {
     
        FOR( Invoice_Entry__c x : listIEdnb) {
            IF(x.Time_Spent__c == NULL) {
               sumDNBtimeX = 0.0; 
            } ELSE {
                sumDNBTimeX = x.Time_Spent__c;
            }
            IF(x.Amount__c == NULL) {
               sumDNBAmountX = 0.0; 
            } ELSE {
                sumDNBAmountX = x.Amount__c;
            }
            sumDNBTime = sumDNBTime + sumDNBTimeX;
            sumDNBAmount = sumDNBAmount + sumDNBAmountX;
        }       
        }

        diffTime = sumTime - sumDNBtime; 
        diffAmount = sumAmount - sumDNBamount; 
        
    }
}