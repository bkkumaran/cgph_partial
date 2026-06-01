// Test Data Script for Unit Assignment User Story
// This script creates:
// 1. A group property
// 2. Multiple individual units linked to the group property
// 3. Applicant tracking records for testing unit assignment

// Step 1: Create the Group Property
HOMEtracker__Property__c groupProperty = new HOMEtracker__Property__c(
    Name = 'Sunset Gardens Group Property',
    HOMEtracker__Street_Address__c = '123 Main Street',
    HOMEtracker__City__c = 'Seattle',
    HOMEtracker__State__c = 'WA',
    HOMEtracker__Postal_Code__c = '98101',
    Group_Property__c = true,
    HOMEtracker__Property_Type__c = 'Rental',
    HOMEtracker__Number_of_Bedrooms__c = 2,
    HOMEtracker__Number_of_Bathrooms__c = 1,
    HOMEtracker__Monthly_Rent__c = 1500,
    HOMEtracker__Status__c = 'Available'
);
insert groupProperty;

System.debug('Group Property Created: ' + groupProperty.Id);

// Step 2: Create Individual Units linked to Group Property
List<HOMEtracker__Property__c> individualUnits = new List<HOMEtracker__Property__c>();

// Unit 1A
individualUnits.add(new HOMEtracker__Property__c(
    Name = 'Sunset Gardens Unit 1A',
    HOMEtracker__Street_Address__c = '123 Main Street, Unit 1A',
    HOMEtracker__City__c = 'Seattle',
    HOMEtracker__State__c = 'WA',
    HOMEtracker__Postal_Code__c = '98101',
    Group_Property__c = false,
    Group_Property_Parent__c = groupProperty.Id,
    HOMEtracker__Property_Type__c = 'Rental',
    HOMEtracker__Number_of_Bedrooms__c = 2,
    HOMEtracker__Number_of_Bathrooms__c = 1,
    HOMEtracker__Monthly_Rent__c = 1500,
    HOMEtracker__Status__c = 'Available'
));

// Unit 1B
individualUnits.add(new HOMEtracker__Property__c(
    Name = 'Sunset Gardens Unit 1B',
    HOMEtracker__Street_Address__c = '123 Main Street, Unit 1B',
    HOMEtracker__City__c = 'Seattle',
    HOMEtracker__State__c = 'WA',
    HOMEtracker__Postal_Code__c = '98101',
    Group_Property__c = false,
    Group_Property_Parent__c = groupProperty.Id,
    HOMEtracker__Property_Type__c = 'Rental',
    HOMEtracker__Number_of_Bedrooms__c = 2,
    HOMEtracker__Number_of_Bathrooms__c = 1,
    HOMEtracker__Monthly_Rent__c = 1500,
    HOMEtracker__Status__c = 'Available'
));

// Unit 2A
individualUnits.add(new HOMEtracker__Property__c(
    Name = 'Sunset Gardens Unit 2A',
    HOMEtracker__Street_Address__c = '123 Main Street, Unit 2A',
    HOMEtracker__City__c = 'Seattle',
    HOMEtracker__State__c = 'WA',
    HOMEtracker__Postal_Code__c = '98101',
    Group_Property__c = false,
    Group_Property_Parent__c = groupProperty.Id,
    HOMEtracker__Property_Type__c = 'Rental',
    HOMEtracker__Number_of_Bedrooms__c = 2,
    HOMEtracker__Number_of_Bathrooms__c = 1,
    HOMEtracker__Monthly_Rent__c = 1550,
    HOMEtracker__Status__c = 'Available'
));

// Unit 2B
individualUnits.add(new HOMEtracker__Property__c(
    Name = 'Sunset Gardens Unit 2B',
    HOMEtracker__Street_Address__c = '123 Main Street, Unit 2B',
    HOMEtracker__City__c = 'Seattle',
    HOMEtracker__State__c = 'WA',
    HOMEtracker__Postal_Code__c = '98101',
    Group_Property__c = false,
    Group_Property_Parent__c = groupProperty.Id,
    HOMEtracker__Property_Type__c = 'Rental',
    HOMEtracker__Number_of_Bedrooms__c = 1,
    HOMEtracker__Number_of_Bathrooms__c = 1,
    HOMEtracker__Monthly_Rent__c = 1350,
    HOMEtracker__Status__c = 'Available'
));

insert individualUnits;

System.debug('Individual Units Created: ' + individualUnits.size() + ' units');
for(HOMEtracker__Property__c unit : individualUnits) {
    System.debug('Unit: ' + unit.Name + ' - ID: ' + unit.Id);
}

// Step 3: Create Service Files (Applicants) for testing
List<HOMEtracker__Service_File__c> applicants = new List<HOMEtracker__Service_File__c>();

// Applicant 1 - John Smith
applicants.add(new HOMEtracker__Service_File__c(
    HOMEtracker__First_Name__c = 'John',
    HOMEtracker__Last_Name__c = 'Smith',
    HOMEtracker__Email__c = 'john.smith@example.com',
    HOMEtracker__Phone__c = '(206) 555-0101',
    HOMEtracker__Street_Address__c = '456 Oak Avenue',
    HOMEtracker__City__c = 'Seattle',
    HOMEtracker__State__c = 'WA',
    HOMEtracker__Zip_Code__c = '98102',
    HOMEtracker__Status__c = 'Approved',
    HOMEtracker__Property__c = groupProperty.Id
));

// Applicant 2 - Jane Johnson
applicants.add(new HOMEtracker__Service_File__c(
    HOMEtracker__First_Name__c = 'Jane',
    HOMEtracker__Last_Name__c = 'Johnson',
    HOMEtracker__Email__c = 'jane.johnson@example.com',
    HOMEtracker__Phone__c = '(206) 555-0102',
    HOMEtracker__Street_Address__c = '789 Pine Street',
    HOMEtracker__City__c = 'Seattle',
    HOMEtracker__State__c = 'WA',
    HOMEtracker__Zip_Code__c = '98103',
    HOMEtracker__Status__c = 'Approved',
    HOMEtracker__Property__c = groupProperty.Id
));

// Applicant 3 - Mike Davis
applicants.add(new HOMEtracker__Service_File__c(
    HOMEtracker__First_Name__c = 'Mike',
    HOMEtracker__Last_Name__c = 'Davis',
    HOMEtracker__Email__c = 'mike.davis@example.com',
    HOMEtracker__Phone__c = '(206) 555-0103',
    HOMEtracker__Street_Address__c = '321 Cedar Road',
    HOMEtracker__City__c = 'Seattle',
    HOMEtracker__State__c = 'WA',
    HOMEtracker__Zip_Code__c = '98104',
    HOMEtracker__Status__c = 'Approved',
    HOMEtracker__Property__c = groupProperty.Id
));

insert applicants;

System.debug('Applicants Created: ' + applicants.size() + ' applicants');
for(HOMEtracker__Service_File__c applicant : applicants) {
    System.debug('Applicant: ' + applicant.HOMEtracker__First_Name__c + ' ' + applicant.HOMEtracker__Last_Name__c + ' - ID: ' + applicant.Id);
}

// Step 4: Create Outreach Tracking records initially assigned to Group Property
List<Outreach_Tracking__c> outreachRecords = new List<Outreach_Tracking__c>();

// Outreach record for John Smith
outreachRecords.add(new Outreach_Tracking__c(
    Name = 'John Smith - Sunset Gardens',
    Applicant_Name__c = 'John Smith',
    Applicant_Email__c = 'john.smith@example.com',
    Applicant_Phone__c = '(206) 555-0101',
    Property_Unit__c = groupProperty.Id, // Initially assigned to group property
    Applicant_Stage__c = 'Approved',
    Tracker_Status__c = 'Active',
    Include_on_Tracker__c = true
));

// Outreach record for Jane Johnson
outreachRecords.add(new Outreach_Tracking__c(
    Name = 'Jane Johnson - Sunset Gardens',
    Applicant_Name__c = 'Jane Johnson',
    Applicant_Email__c = 'jane.johnson@example.com',
    Applicant_Phone__c = '(206) 555-0102',
    Property_Unit__c = groupProperty.Id, // Initially assigned to group property
    Applicant_Stage__c = 'Approved',
    Tracker_Status__c = 'Active',
    Include_on_Tracker__c = true
));

// Outreach record for Mike Davis
outreachRecords.add(new Outreach_Tracking__c(
    Name = 'Mike Davis - Sunset Gardens',
    Applicant_Name__c = 'Mike Davis',
    Applicant_Email__c = 'mike.davis@example.com',
    Applicant_Phone__c = '(206) 555-0103',
    Property_Unit__c = groupProperty.Id, // Initially assigned to group property
    Applicant_Stage__c = 'Approved',
    Tracker_Status__c = 'Active',
    Include_on_Tracker__c = true
));

insert outreachRecords;

System.debug('Outreach Tracking Records Created: ' + outreachRecords.size() + ' records');
for(Outreach_Tracking__c outreach : outreachRecords) {
    System.debug('Outreach: ' + outreach.Name + ' - ID: ' + outreach.Id);
}

// Step 5: Display summary for testing
System.debug('=== TEST DATA CREATION COMPLETE ===');
System.debug('Group Property ID: ' + groupProperty.Id + ' (Name: ' + groupProperty.Name + ')');
System.debug('Individual Units created: ' + individualUnits.size());
System.debug('Applicants created: ' + applicants.size());
System.debug('Outreach Tracking records created: ' + outreachRecords.size());

System.debug('=== TESTING INSTRUCTIONS ===');
System.debug('1. Navigate to the Group Property: ' + groupProperty.Name);
System.debug('2. Click the unit assignment link for any of the outreach tracking records');
System.debug('3. Verify you can see all ' + individualUnits.size() + ' individual units in the selection process');
System.debug('4. Select a specific unit and verify the Property_Unit__c field updates from the group property to the individual unit');

// Query to show initial state
System.debug('=== CURRENT OUTREACH TRACKING ASSIGNMENTS ===');
List<Outreach_Tracking__c> currentAssignments = [
    SELECT Id, Name, Property_Unit__c, Property_Unit__r.Name
    FROM Outreach_Tracking__c
    WHERE Property_Unit__c = :groupProperty.Id
];
for(Outreach_Tracking__c assignment : currentAssignments) {
    System.debug('Applicant: ' + assignment.Name + ' assigned to: ' + assignment.Property_Unit__r.Name);
}

System.debug('=== AVAILABLE INDIVIDUAL UNITS ===');
List<HOMEtracker__Property__c> availableUnits = [
    SELECT Id, Name, HOMEtracker__Street_Address__c, HOMEtracker__Monthly_Rent__c
    FROM HOMEtracker__Property__c
    WHERE Group_Property_Parent__c = :groupProperty.Id
    ORDER BY Name
];
for(HOMEtracker__Property__c unit : availableUnits) {
    System.debug('Unit: ' + unit.Name + ' (' + unit.HOMEtracker__Street_Address__c + ') - Rent: $' + unit.HOMEtracker__Monthly_Rent__c);
}