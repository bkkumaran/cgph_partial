public class getApp{

        public List<HOMEtracker__Service_File__c> getSF() {
        return [SELECT Name, PHA__Application_Submitted__c
                FROM
                HOMEtracker__Service_File__c
                WHERE
                PHA__Application_Status__c = 'Document Review' AND
                Application_Workflow_Status__c !='Application Received - Backup Ready for Full Income Certification' AND
                Application_Workflow_Status__c !='Application Received - Full Income Certification In Progress' AND
                Application_Workflow_Status__c !='Application Received - Ready for Peer Review' AND
                Application_Workflow_Status__c !='Application Received - Peer Review In Progress' AND
                Application_Workflow_Status__c !='Application Received - Peer Review Completed' AND
                (NOT HOMEtracker__Applicant__r.Name LIKE '%Test%')
                ORDER BY
                PHA__Application_Submitted__c ASC
                LIMIT 1];
        }
        
        public List<HOMEtracker__Service_File__c> getLWplus() {
        return [SELECT Name, PHA__Application_Submitted__c
                FROM
                HOMEtracker__Service_File__c
                WHERE
                PHA__Application_Status__c = 'Document Review' AND
                Application_Workflow_Status__c !='Application Received - Backup Ready for Full Income Certification' AND
                Application_Workflow_Status__c !='Application Received - Full Income Certification In Progress' AND
                Application_Workflow_Status__c !='Application Received - Ready for Peer Review' AND
                Application_Workflow_Status__c !='Application Received - Peer Review In Progress' AND
                Application_Workflow_Status__c !='Application Received - Peer Review Completed' AND
                (NOT HOMEtracker__Applicant__r.Name LIKE '%Test%')
                AND PHA__Application_Submitted__c = LAST_WEEK
                ORDER BY
                PHA__Application_Submitted__c ASC];
        }
        public List<HOMEtracker__Service_File__c> getLWminus() {
        return [SELECT Name, PHA__Application_Submitted__c
                FROM
                HOMEtracker__Service_File__c
                WHERE
                (Ineligibility__c = true OR
                Certified__c = true) AND
                (NOT HOMEtracker__Applicant__r.Name LIKE '%Test%')
                AND Cert_Or_Inelig_Date__c = LAST_WEEK
                ORDER BY
                Cert_Or_Inelig_Date__c ASC];
        }
        public List<HOMEtracker__Service_File__c> getBacklog() {
        return [SELECT Name, PHA__Application_Submitted__c
                FROM
                HOMEtracker__Service_File__c
                WHERE
                PHA__Application_Status__c = 'Document Review' AND
                Application_Workflow_Status__c !='Application Received - Backup Ready for Full Income Certification' AND
                Application_Workflow_Status__c !='Application Received - Full Income Certification In Progress' AND
                Application_Workflow_Status__c !='Application Received - Ready for Peer Review' AND
                Application_Workflow_Status__c !='Application Received - Peer Review In Progress' AND
                Application_Workflow_Status__c !='Application Received - Peer Review Completed' AND
                (NOT HOMEtracker__Applicant__r.Name LIKE '%Test%')
                ORDER BY
                PHA__Application_Submitted__c ASC];
        }
        
}