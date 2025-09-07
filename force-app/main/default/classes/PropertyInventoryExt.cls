public class PropertyInventoryExt {
    Public HOMETracker__Property__c xDev {get; set;}
    Public String xDevID {get; set;}
    Public Date lastNameGivenDate {get; set;}
    Public Integer propertyApproval {get; set;}
    Public Date propertyApprovalDate {get; set;}
    
    
    public PropertyInventoryExt(PropertyInventoryController controller) {
        xDevID= apexpages.currentpage().getparameters().get('d');
        xDev= [SELECT id, Name FROM HOMEtracker__Property__c WHERE id=:xDevID LIMIT 1];


        
        List<HOMEtracker__Property__c> listLastNameGivenDate = [
            SELECT
                Id, Current_Primary_Applicant__r.Date_CGPH_Added_Name__c
            FROM 
                HOMEtracker__Property__c
            WHERE
                Development_address__r.Id = :xDevID AND
                Group_Property__c = False AND
                Current_Primary_Applicant__r.Applicant_Stage__c = 'Needs Property Approval' AND
                Current_Primary_Applicant__r.Date_CGPH_Added_Name__c != NULL
            ORDER BY
                Current_Primary_Applicant__r.Date_CGPH_Added_Name__c DESC
                LIMIT 1
                ];
                
        IF (listLastNameGivenDate.isEmpty()){
            lastNameGivenDate = NULL;
        } ELSE {
            lastNameGivenDate = listLastNameGivenDate[0].Current_Primary_Applicant__r.Date_CGPH_Added_Name__c;
        }
        
       
        
        
 /*      
    List<Outreach_Tracking__c> listLastNameGivenDate = [
            SELECT Id, Date_CGPH_Added_Name__c
            FROM Outreach_Tracking__c
            WHERE
            Service_File__r.HOMEtracker__Property__r.Development_Address__r.Id = :xDevID AND
            Tracker_Status__c = 'Primary'
            ORDER BY
            Date_CGPH_Added_Name__c DESC
                ];
    IF (listLastNameGivenDate.isEmpty()){
        lastNameGivenDate = NULL;
    } ELSE {
        lastNameGivenDate = listLastNameGivenDate[0].Date_CGPH_Added_Name__c;
    }
*/

/*   
    List<Outreach_Tracking__c> listPropertyApproval = [
            SELECT Id, Date_CGPH_Added_Name__c
            FROM Outreach_Tracking__c
            WHERE
            Service_File__r.HOMEtracker__Property__r.Development_Address__r.Id = :xDevID AND
            Applicant_Stage__c = 'Needs Property Approval' AND
            Date_CGPH_Added_Name__c != NULL
            ORDER BY
            Date_CGPH_Added_Name__c DESC
                ];  
*/
    List<HOMEtracker__Property__c> listPropertyApproval = [
        SELECT Id
        FROM HOMEtracker__Property__c
        WHERE
            Development_address__r.Id = :xDevId AND
            Group_Property__c = False AND
            Current_Primary_Applicant__r.Applicant_Stage__c = 'Needs Property Approval'
            ];           
            
      
      propertyApproval = listPropertyApproval.size();
      
                
    }

}