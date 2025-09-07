public class OutreachTrackerExt{
    Public HOMETracker__Property__c Dev {get; set;}
    Public String DevId {get; set;}
    Public List<Outreach_Tracking__c> result {get; set;}
    Public String h {get; set;}
    
    public OutreachTrackerExt(ApexPages.StandardController controller) {
        Dev = (HOMETracker__Property__c )controller.getRecord();
        h = apexpages.currentpage().getparameters().get('H');
    }
    
    public Map<String,ListWrapper> getotByProperty(){
        DevId = Dev.Id;
        
        
        result = 
            [SELECT Id,
             Name,
             Property_Id__c,
             Property_Address__c,
             Outreach_Tracker_Property_Name__c,
             Unit__c,
             Property_Unit__c,
             Property_Unit__r.Unit_Number__c,
             Property_Unit__r.Name,
             Property_Rent_or_List_Price__c,
             SF_Priority__c,
             Priority_Calc__c,
             Applicant_Name__c,
             Applicant_Email__c,
             Applicant_Phone__c,
             Household_Size__c,
             Date_CGPH_Added_Name__c,
             Date_Marked_Primary__c,
             Date_Eligibility_Review_Began__c,
             Date_Ready_for_Eligibility_Review__c,
             CGPH_Determination__c,
             CGPH_Approval_Denial_Date__c,
             Landlord_Developer_Tour__c,
             Landlord_Developer_Notes__c,
             Landlord_Developer_Determination_Date__c,
             Landlord_Developer_Determination__c,
             Landlord_Developer_Deadline__c,
             Landlord_Developer_App_Sent__c,
             Tracker_Status__c,
             Service_File__r.Priority__c,
             Service_File__r.HOMEtracker__Property__r.Group_Property__c,
             Service_File__r.HOMEtracker__Property__r.Development_address__r.Id,
             Service_File__r.Pre_Applicant__r.Id,
             Service_File__r.Pre_Applicant__r.Flagged_for_Outreach__c,
             Service_File__r.Pre_Applicant__r.Flagged_for_Outreach_Notes__c,
             Service_File__r.Pre_Applicant__r.Last_Certification_Date__c
             FROM Outreach_Tracking__c
             WHERE Service_File__r.HOMETracker__Property__r.Include_on_Tracker__c=true AND
             Include_On_Tracker__c = true AND
             Service_File__r.HOMETracker__Property__r.Development_address__r.Id = :DevId
             ORDER BY
             Priority_Calc__c ASC];
        
        // Group Outreach Tracking by Property
        Map<String,ListWrapper> otByProperty= new Map<String,ListWrapper>();
        for(Outreach_Tracking__c ot: result){
            if(null == ot.Property_Id__c) continue;
            ListWrapper var1 = otByProperty.get(ot.Property_Id__c);
            if(null == var1){
                otByProperty.put(ot.Property_Id__c, new ListWrapper(new List<Outreach_Tracking__c>()) );    
            }
            otByProperty.get(ot.Property_Id__c).otList.add(ot);
        }
        return otByProperty;
    }
    
    
    // List of Outreach Tracking and details  
    class ListWrapper {
        
        public List<Outreach_Tracking__c> otList{get; set;}
        
        public Integer numOfOTs{
            get{
                return otList.size();
            }
            set;
        }
        
        public Id firstOfList{
            get{
                return otList[0].Id;
            }
            set;
        }
        
        public ListWrapper(List<Outreach_Tracking__c> listOTs){
            
            otList= listOTs;
            
        }
        
    }
    
    public pageReference save(){
        update result;
        PageReference pg = new PageReference('/apex/OutreachTrackerStaff?id='+DevId);
        pg.setRedirect(true);
        return pg;
        
    }
    
}