// Cleanup Script for Unit Assignment Test Data
// Run this script to remove all test data created for unit assignment testing

System.debug('=== STARTING CLEANUP OF UNIT ASSIGNMENT TEST DATA ===');

// Find and delete outreach tracking records
List<Outreach_Tracking__c> outreachRecords = [
    SELECT Id, Name
    FROM Outreach_Tracking__c
    WHERE Name LIKE '%Sunset Gardens%'
];

if(outreachRecords.size() > 0) {
    delete outreachRecords;
    System.debug('Deleted ' + outreachRecords.size() + ' Outreach Tracking records');
} else {
    System.debug('No Outreach Tracking records found to delete');
}

// Find and delete service files (applicants)
List<HOMEtracker__Service_File__c> serviceFiles = [
    SELECT Id, HOMEtracker__First_Name__c, HOMEtracker__Last_Name__c
    FROM HOMEtracker__Service_File__c
    WHERE (HOMEtracker__First_Name__c = 'John' AND HOMEtracker__Last_Name__c = 'Smith' AND HOMEtracker__Email__c = 'john.smith@example.com')
    OR (HOMEtracker__First_Name__c = 'Jane' AND HOMEtracker__Last_Name__c = 'Johnson' AND HOMEtracker__Email__c = 'jane.johnson@example.com')
    OR (HOMEtracker__First_Name__c = 'Mike' AND HOMEtracker__Last_Name__c = 'Davis' AND HOMEtracker__Email__c = 'mike.davis@example.com')
];

if(serviceFiles.size() > 0) {
    delete serviceFiles;
    System.debug('Deleted ' + serviceFiles.size() + ' Service File records');
} else {
    System.debug('No Service File records found to delete');
}

// Find and delete individual unit properties first (to avoid reference issues)
List<HOMEtracker__Property__c> individualUnits = [
    SELECT Id, Name
    FROM HOMEtracker__Property__c
    WHERE Name LIKE 'Sunset Gardens Unit%'
];

if(individualUnits.size() > 0) {
    delete individualUnits;
    System.debug('Deleted ' + individualUnits.size() + ' individual unit properties');
} else {
    System.debug('No individual unit properties found to delete');
}

// Find and delete group property
List<HOMEtracker__Property__c> groupProperties = [
    SELECT Id, Name
    FROM HOMEtracker__Property__c
    WHERE Name LIKE 'Sunset Gardens Group Property%'
];

if(groupProperties.size() > 0) {
    delete groupProperties;
    System.debug('Deleted ' + groupProperties.size() + ' group properties');
} else {
    System.debug('No group properties found to delete');
}

System.debug('=== CLEANUP COMPLETE ===');
System.debug('All test data for unit assignment has been removed from the system.');