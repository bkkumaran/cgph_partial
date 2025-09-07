public with sharing class OutreachControllerLWC {
    
    // Wrapper to group OTs by property
    public class ListWrapper {
        @AuraEnabled public List<Outreach_Tracking__c> otList { get; set; }
        @AuraEnabled public Integer numOfOTs {
            get {
                return otList != null ? otList.size() : 0;
            }
            private set;
        }
        @AuraEnabled public Id firstOfList {
            get {
                return (otList != null && !otList.isEmpty()) ? otList[0].Id : null;
            }
            private set;
        }
        
        public ListWrapper(List<Outreach_Tracking__c> listOTs) {
            this.otList = listOTs;
        }
    }
    
    /**
     * Query Outreach_Tracking__c records by Property Id
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, ListWrapper> getOutreachTrackingByProperty(Id propertyId) {
        if (propertyId == null) {
            return new Map<String, ListWrapper>();
        }
        
        List<Outreach_Tracking__c> results = [
            SELECT Id,
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
            WHERE Service_File__r.HOMEtracker__Property__r.Include_on_Tracker__c = true
              AND Include_On_Tracker__c = true
              AND Service_File__r.HOMEtracker__Property__r.Development_address__r.Id = :propertyId
            ORDER BY Priority_Calc__c ASC
        ];
        
        Map<String, ListWrapper> otByProperty = new Map<String, ListWrapper>();
        for (Outreach_Tracking__c ot : results) {
            if (ot.Property_Id__c == null) continue;
            
            if (!otByProperty.containsKey(ot.Property_Id__c)) {
                otByProperty.put(ot.Property_Id__c, new ListWrapper(new List<Outreach_Tracking__c>()));
            }
            otByProperty.get(ot.Property_Id__c).otList.add(ot);
        }
        
        return otByProperty;
    }
    
    /**
     * Save updates from LWC
     */
    @AuraEnabled
    public static String saveOutreachTrackings(List<Outreach_Tracking__c> updates) {
        try {
            System.debug('saveOutreachTrackings called with updates: ' + updates);
            System.debug('Updates size: ' + (updates != null ? updates.size() : 0));
            
            if (updates != null && !updates.isEmpty()) {
                for (Outreach_Tracking__c record : updates) {
                    System.debug('Record to update: ' + record);
                }
                update updates;
                System.debug('Records updated successfully');
                return 'Success';
            }
            return 'No records to update';
        } catch (Exception e) {
            System.debug('Error in saveOutreachTrackings: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error saving records: ' + e.getMessage());
        }
    }
    
    /**
     * Alternative method to save a single record
     */
    @AuraEnabled
    public static String saveSingleOutreachTracking(String recordData) {
        try {
            System.debug('saveSingleOutreachTracking called with data: ' + recordData);
            
            Outreach_Tracking__c record = (Outreach_Tracking__c) JSON.deserialize(recordData, Outreach_Tracking__c.class);
            System.debug('Deserialized record: ' + record);
            
            update record;
            System.debug('Record updated successfully');
            return 'Success';
        } catch (Exception e) {
            System.debug('Error in saveSingleOutreachTracking: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error saving record: ' + e.getMessage());
        }
    }
}