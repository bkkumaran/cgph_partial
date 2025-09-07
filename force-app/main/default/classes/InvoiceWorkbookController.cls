public class InvoiceWorkbookController {

    public class setupWrapper{
        public String setupName {get; set;}
        public Integer slipCount {get; set;}
        
        public setupWrapper(String name, Integer count){
            setupName = name;
            slipCount = count;
        }
    }
	
    Public Date invDate {get; set;}
    public List<setupWrapper> setupList { get; set; }
    
    
    public InvoiceWorkbookController() {
    
    CGPH_General__c cs = CGPH_General__c.getOrgDefaults();
    invDate = cs.Invoicing_Date__c;
    String limitString = ApexPages.currentPage().getParameters().get('limit');
    Integer limitNum = Integer.valueOf(limitString);
    
	 List<TS_Contract__c> activeSetups = [
            SELECT Id, Name
         	FROM TS_Contract__c
         	WHERE ActiveTS__c = true
         	Order BY Name
         	LIMIT :limitNum
        ];
        
     setupList = new List<setupWrapper>();   
        
    for (TS_Contract__c s : activeSetups) {
        	Integer slipCount = calcNum(s.Id);
            setupList.add(new setupWrapper(s.Name, slipCount));
        }
        
    }

    public Integer calcNum(String sID){

	//In Progress Invoices
		List<Invoice__c> InProgress = [
            SELECT Id
            FROM Invoice__c
            WHERE
            	TimeSlipsContract__r.Id = :sID AND
            	Inv_In_Progress__c = true
        ];
        Integer cInProgress = InProgress.size();
         IF(cInProgress == 0) { InProgress = NULL;}
        
    //Pending Slips on Invoicing Setup
        List<Invoice_Entry__c> PendingSlip = [
            SELECT Id
            FROM Invoice_Entry__c
            WHERE
                Invoice_Setup__c = :sID AND
                Invoice_Record__c = '' AND
                Date__C <= :invDate AND
                Do_Not_Bill__c = false
                ];
                
         Integer cPendingSlip = PendingSlip.size();
         IF(cPendingSlip == 0) { PendingSlip = NULL;}

        Integer countTotal = cPendingSlip + cInProgress;
		

        return countTotal;
    }

}