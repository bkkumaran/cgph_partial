// Verification Script for Unit Assignment Test Data
// Run this script to verify the test data relationships and simulate unit assignment

// Query Group Properties
List<HOMEtracker__Property__c> groupProperties = [
    SELECT Id, Name, HOMEtracker__Street_Address__c, Group_Property__c
    FROM HOMEtracker__Property__c
    WHERE Group_Property__c = true
    AND Name LIKE '%Sunset Gardens%'
    ORDER BY Name
];

System.debug('=== GROUP PROPERTIES FOUND ===');
for(HOMEtracker__Property__c groupProp : groupProperties) {
    System.debug('Group Property: ' + groupProp.Name + ' (ID: ' + groupProp.Id + ')');

    // Query individual units for this group property
    List<HOMEtracker__Property__c> individualUnits = [
        SELECT Id, Name, HOMEtracker__Street_Address__c, HOMEtracker__Monthly_Rent__c,
               HOMEtracker__Number_of_Bedrooms__c, HOMEtracker__Status__c
        FROM HOMEtracker__Property__c
        WHERE Group_Property_Parent__c = :groupProp.Id
        ORDER BY Name
    ];

    System.debug('  Individual Units (' + individualUnits.size() + ' units):');
    for(HOMEtracker__Property__c unit : individualUnits) {
        System.debug('    - ' + unit.Name + ' | ' + unit.HOMEtracker__Street_Address__c + ' | ' +
                    unit.HOMEtracker__Number_of_Bedrooms__c + ' bed | $' + unit.HOMEtracker__Monthly_Rent__c +
                    ' | Status: ' + unit.HOMEtracker__Status__c);
    }

    // Query outreach tracking records assigned to this group property
    List<Outreach_Tracking__c> outreachRecords = [
        SELECT Id, Name, Applicant_Name__c, Applicant_Email__c, Property_Unit__c,
               Property_Unit__r.Name, Applicant_Stage__c, Tracker_Status__c
        FROM Outreach_Tracking__c
        WHERE Property_Unit__c = :groupProp.Id
        ORDER BY Name
    ];

    System.debug('  Outreach Tracking Records (' + outreachRecords.size() + ' records):');
    for(Outreach_Tracking__c outreach : outreachRecords) {
        System.debug('    - ' + outreach.Applicant_Name__c + ' | ' + outreach.Applicant_Email__c +
                    ' | Stage: ' + outreach.Applicant_Stage__c + ' | Assigned to: ' + outreach.Property_Unit__r.Name);
    }

    System.debug('');
}

// Simulate Unit Assignment Process
System.debug('=== SIMULATING UNIT ASSIGNMENT ===');
if(groupProperties.size() > 0) {
    Id groupPropertyId = groupProperties[0].Id;

    // Get available individual units
    List<HOMEtracker__Property__c> availableUnits = [
        SELECT Id, Name, HOMEtracker__Street_Address__c, HOMEtracker__Status__c
        FROM HOMEtracker__Property__c
        WHERE Group_Property_Parent__c = :groupPropertyId
        AND HOMEtracker__Status__c = 'Available'
        ORDER BY Name
    ];

    // Get outreach tracking records to assign
    List<Outreach_Tracking__c> recordsToAssign = [
        SELECT Id, Name, Applicant_Name__c, Property_Unit__c
        FROM Outreach_Tracking__c
        WHERE Property_Unit__c = :groupPropertyId
        ORDER BY Name
    ];

    System.debug('Available Units for Assignment: ' + availableUnits.size());
    System.debug('Applicants to Assign: ' + recordsToAssign.size());

    // Simulate assigning first applicant to first available unit
    if(availableUnits.size() > 0 && recordsToAssign.size() > 0) {
        HOMEtracker__Property__c selectedUnit = availableUnits[0];
        Outreach_Tracking__c applicantRecord = recordsToAssign[0];

        System.debug('BEFORE ASSIGNMENT:');
        System.debug('  Applicant: ' + applicantRecord.Applicant_Name__c);
        System.debug('  Currently assigned to: ' + groupProperties[0].Name + ' (Group Property)');
        System.debug('  Target unit: ' + selectedUnit.Name);

        // Update the Property_Unit__c to point to the individual unit
        applicantRecord.Property_Unit__c = selectedUnit.Id;
        update applicantRecord;

        // Query the updated record to verify
        Outreach_Tracking__c updatedRecord = [
            SELECT Id, Name, Applicant_Name__c, Property_Unit__c, Property_Unit__r.Name
            FROM Outreach_Tracking__c
            WHERE Id = :applicantRecord.Id
        ];

        System.debug('AFTER ASSIGNMENT:');
        System.debug('  Applicant: ' + updatedRecord.Applicant_Name__c);
        System.debug('  Now assigned to: ' + updatedRecord.Property_Unit__r.Name + ' (Individual Unit)');
        System.debug('  Assignment successful: ' + (updatedRecord.Property_Unit__c == selectedUnit.Id));

        // Show remaining applicants still on group property
        List<Outreach_Tracking__c> remainingOnGroup = [
            SELECT Id, Applicant_Name__c
            FROM Outreach_Tracking__c
            WHERE Property_Unit__c = :groupPropertyId
        ];

        System.debug('Remaining applicants on group property: ' + remainingOnGroup.size());
        for(Outreach_Tracking__c remaining : remainingOnGroup) {
            System.debug('  - ' + remaining.Applicant_Name__c);
        }
    }
}

System.debug('=== VERIFICATION COMPLETE ===');
System.debug('Test data is ready for unit assignment user story testing!');