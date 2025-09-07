public class AvailableApplicantsExt {
    public List<Outreach_Tracking__c> listApplicants {get; set;}
    public List<Outreach_Tracking__c> listInvited {get; set;}
    public List<HOMEtracker__Property__c> listUnits {get; set;}
    public HOMETRACKER__Property__c property {get; set;}
    public HOMETRACKER__Property__c property2 {get; set;}
    public Integer countApplicants {get; set;}
    public Integer countInvited {get; set;}
    public Integer countSubmitted {get; set;}
    public Integer countUnits {get; set;}   
    public String finalID {get; set;}
    public String uType {get; set;}
    public String urlType {get; set;}
    public String aShow {get; set;}
    
    public AvailableApplicantsExt(ApexPages.StandardController controller) {
        property = (HOMETracker__Property__c )controller.getRecord();
        urlType = apexpages.currentpage().getparameters().get('t');
        aShow = apexpages.currentpage().getparameters().get('a');
        
        property2 = [SELECT id, Group_Property_Parent__r.Id from HOMEtracker__Property__c WHERE id = :property.Id LIMIT 1];
                
        finalID = '';
        uType='x';
        listUnits = NULL;
        countApplicants=0;
        countInvited=0;
        countSubmitted=0;
        countUnits=0;
        
        // If property is a group property //
        IF(urlType == 'g' ){
            finalID = property2.Id;
            uType='g';
            listUnits = [SELECT 
                                id,
                                Group_Property_Parent__r.Id,
                                Group_Property_Parent__c 
                         FROM
                                HOMEtracker__Property__c
                         WHERE
                                Group_Property_Parent__r.Id = :finalID AND
                                Current_Outreach_Timeline__r.Next_Step__c != 'DONE'
                        ];
            IF (listUnits.size() == 0) {
                countUnits=0;
                listUnits = NULL;
                } ELSE {
                countUnits = listUnits.size();
                }
        } ELSE {
        
        // If property is a Single Unit not in Group Property //
        IF(urlType == 's'){
            finalID = property2.Id;
            uType='s';
            listUnits = NULL;
        } ELSE {
            
        // If property is a Unit in Group Property //
            finalID = property2.Group_Property_Parent__r.Id;
            uType='pg';
            listUnits = NULL;
        }
        }
        
        // TOTAL APPLICANTS //
        listApplicants = [
                SELECT id
                FROM Outreach_Tracking__c
                WHERE Service_File__r.HOMEtracker__Property__r.Id = :finalID AND Include_On_Tracker__c = true
            ];
        
        IF (listApplicants.size() == 0) {
            countApplicants=0;
            listApplicants = NULL;
        } ELSE {
            countApplicants = listApplicants.size();
        }
        
        
        // APPLICANTS INVITED TO SUBMIT //
        listInvited = [
                SELECT id
                FROM Outreach_Tracking__c
                WHERE Service_File__r.HOMEtracker__Property__r.Id = :finalID AND
                    Include_On_Tracker__c = true AND
                    Service_File__r.Application_Workflow_Status__c = 'Invited - Waiting to Submit'                    
            ];
        
        IF (listInvited.size() == 0) {
            countInvited=0;
            listInvited = NULL;
        } ELSE {
            countInvited = listInvited.size();
        }
        
        //APPLICANTS WHO SUBMITTED (calculated)//
        countSubmitted = countApplicants - countInvited;

        
    
        
        
        
        
        
    }
}