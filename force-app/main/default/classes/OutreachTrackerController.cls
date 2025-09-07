public class OutreachTrackerController {
    Public HOMETracker__Property__c dev {get; set;}
    Public List<Outreach_Tracking__c> result {get; set;}
    Public String devID {get; set;}
    
    public OutreachTrackerController(){
        
        devID= apexpages.currentpage().getparameters().get('d');
        
        dev= [SELECT
              id,
              Name,
              Google_Tracker_Link__c,
              Primary_Case_manager__c,
              Primary_Case_manager__r.FirstName,
              Primary_Case_manager__r.LastName,
              Primary_Case_manager__r.Email,
              Publish_Outreach_Tracker__c,
              Publish_Property_Inventory__c,
              Outreach_Contact__r.FirstName,
              Outreach_Contact__r.LastName,
              Outreach_Contact__r.email
              FROM HOMEtracker__Property__c WHERE id=:devID];
    }
    public Map<String,ListWrapper> getotByProperty(){
        
        result = 
            [SELECT Id,
             Name,
             Property_Id__c,
             Property_Address__c,
             Unit__c,
             Property_Rent_or_List_Price__c,
             SF_Priority__c,
             Priority_Calc__c,
             Applicant_Name__c,
             Applicant_Email__c,
             Applicant_Phone__c,
             Household_Size__c,
             Date_CGPH_Added_Name__c,
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
             Service_File__r.Priority__c
             FROM Outreach_Tracking__c
             WHERE Service_File__r.HOMETracker__Property__r.Include_on_Tracker__c=true AND
             Include_On_Tracker__c = true AND
             Service_File__r.HOMETracker__Property__r.Development_address__r.Id = :devID
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
    
    
}