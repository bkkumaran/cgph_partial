public class InvoiceSlipAmounts {
    
    public List<Invoice__c> listInv {get; set;}
    public List<Decimal> listSlipValues {get; set;}
    public List<Decimal> listDiff {get; set;}
    
    public InvoiceSlipAmounts() {
      
        List<Invoice_Entry__c> listSlip = new List<Invoice_Entry__c>();
        
        listInv = [
            SELECT Id, Name, Invoice_Amount__c
            FROM Invoice__c 
            WHERE 
	            Invoice_Date__c > 2024-12-31 AND
            	Inv_In_Progress__c = false
            ORDER BY Name ASC
            LIMIT 10
        ];
        
        listSlip = [
          	SELECT Id, Amount__c, Invoice_Record__r.Id
            FROM Invoice_Entry__c
            WHERE On_Invoice__c = true
            ORDER BY Invoice_Record__c ASC, Date__c ASC
            
        ];
        
        List<Decimal> listSlipValues = new List<Decimal>();
        Decimal amount = 0.00;
        
        for (Invoice__c i : listInv){
            
            for(Invoice_Entry__c s : listSlip){
                if(s.Invoice_Record__r.Id == i.Id){
                    amount = amount + s.Amount__c;
                }
                listSlipValues.add(amount);
                amount = 0;
            }
        }
            
            
        List<Decimal> listDiff = new List<Decimal>();
        Decimal diff = 0.00; 
        
        Integer x = 0;
            
		while (x < listInv.size()){
			diff = listInv[x].Invoice_Amount__c + listSlipValues[x];
            listDiff.add(diff);
            x++;
        }
        
        
        
      
    }

}