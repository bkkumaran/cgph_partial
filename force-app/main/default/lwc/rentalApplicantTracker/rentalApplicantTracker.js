import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import { RefreshEvent } from 'lightning/refresh';
import Id from '@salesforce/user/Id';

import getOutreachTrackingByProperty from '@salesforce/apex/OutreachControllerLWC.getOutreachTrackingByProperty';
import getOutreachTrackingBySingleProperty from '@salesforce/apex/OutreachControllerLWC.getOutreachTrackingBySingleProperty';
import saveOutreachTrackings from '@salesforce/apex/OutreachControllerLWC.saveOutreachTrackings';
import saveSingleOutreachTracking from '@salesforce/apex/OutreachControllerLWC.saveSingleOutreachTracking';
import cancelUnitAssignment from '@salesforce/apex/OutreachControllerLWC.cancelUnitAssignment';
import confirmApplicantRemoval from '@salesforce/apex/OutreachControllerLWC.confirmApplicantRemoval';
import isGroupProperty from '@salesforce/apex/OutreachControllerLWC.isGroupProperty';

// Object and Field references
import OUTREACH_TRACKING_OBJECT from '@salesforce/schema/Outreach_Tracking__c';
import TRACKER_STATUS_FIELD from '@salesforce/schema/Outreach_Tracking__c.Tracker_Status__c';
import SF_PRIORITY_FIELD from '@salesforce/schema/Outreach_Tracking__c.SF_Priority__c';
import CGPH_DETERMINATION_FIELD from '@salesforce/schema/Outreach_Tracking__c.CGPH_Determination__c';

export default class RentalApplicantTrackerMockup extends NavigationMixin(LightningElement) {
    @api developmentName;
    @api propertyId; // Property ID to fetch data for
    @api recordId;

    @track cardTitle = 'Applicant Tracker'; // Default title
    // TODO: Replace with actual property ID for testing
    testPropertyId = 'a0J1N00001cc8Nt'; // Replace with your actual property ID

    @track propertyGroups = [];
    @track error = null;
    @track outreachTrackingData = null;

    // Render key to force template re-render
    @track dataRefreshKey = 0;

    // Sorting state
    @track sortField = null;
    @track sortDirection = 'asc';
    
    // User permissions and field editability (matching Visualforce logic)
    userId = Id;
    @track isUserCGPHStaff = true; // Default to true for now - should be determined by user profile/role
    @track isUserLandlordDeveloper = true; // Default to true - should be determined by user profile/role
    
    // Properties to hold record type info
    @track outreachTrackingRecordTypeId;
    
    // Dynamic dropdown options populated from Salesforce data
    @track statusOptions = [];
    @track priorityOptions = [];
    @track approvalOptions = [];
    @track determinationOptions = [];

    @track baseNameProperty;
    @track developmentIdForInventory; // Store development ID for inventory navigation
    @track isSinglePropertyMode = false;  // True when zoomed in on one property
    @track zoomOutDevelopmentId = null;   // Development ID to return to on zoom out

    // Getter for card title (matching OutreachTrackerStaff.page pattern)
    get cardTitleFormatted() {
        return this.baseNameProperty ? `${this.baseNameProperty} Applicant Tracker` : 'Applicant Tracker';
    }

    // Wire to get object info (needed for picklist values)
    @wire(getObjectInfo, { objectApiName: OUTREACH_TRACKING_OBJECT })
    wiredObjectInfo({ error, data }) {
        if (data) {
            console.log('Object info received:', data);
            // Get the default record type ID (first one, or Master if available)
            const recordTypes = data.recordTypeInfos;
            const recordTypeIds = Object.keys(recordTypes);
            
            // Look for Master record type first, otherwise use the first one
            let selectedRecordTypeId = recordTypeIds.find(id => 
                recordTypes[id].name === 'Master' || recordTypes[id].master
            ) || recordTypeIds[0];
            
            this.outreachTrackingRecordTypeId = selectedRecordTypeId;
            console.log('Selected record type ID:', selectedRecordTypeId);
        } else if (error) {
            console.error('Error fetching object info:', error);
        }
    }
    
    // Wire to get Status picklist values
    @wire(getPicklistValues, { 
        recordTypeId: '$outreachTrackingRecordTypeId', 
        fieldApiName: TRACKER_STATUS_FIELD 
    })
    wiredStatusPicklistValues({ error, data }) {
        console.log('wiredStatusPicklistValues called with:', {
            recordTypeId: this.outreachTrackingRecordTypeId,
            fieldApiName: TRACKER_STATUS_FIELD,
            data: data,
            error: error
        });
        
        if (data) {
            console.log('Status picklist values received:', data);
            this.statusOptions = data.values.map(item => ({
                label: item.label,
                value: item.value
            }));
            console.log('Updated statusOptions:', this.statusOptions);
        } else if (error) {
            console.error('Error fetching status picklist values:', error);
            this.statusOptions = [...this._defaultStatusOptions];
            console.log('Using default statusOptions:', this.statusOptions);
        } else {
            console.log('Status picklist wire called but no data or error yet');
        }
    }

    customParam1;
    customParam2;
    
    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            // Get URL parameters
            this.recordId = currentPageReference.state?.c__recordId || null;
            const devId = currentPageReference.state?.c__devId || null;
            this.isSinglePropertyMode = !!devId;
            this.zoomOutDevelopmentId = devId;
            this.propertyId = this.recordId ? this.recordId : this.propertyId;
            console.log('Record ID from attribute:', this.recordId);
            console.log('Property ID from attribute:', this.propertyId);
            console.log('Single property mode:', this.isSinglePropertyMode);
            console.log('Zoom out development ID:', this.zoomOutDevelopmentId);
        }
    }
    
    // Wire to get Priority picklist values
    // @wire(getPicklistValues, { 
    //     recordTypeId: '$outreachTrackingRecordTypeId', 
    //     fieldApiName: SF_PRIORITY_FIELD 
    // })
    // wiredPriorityPicklistValues({ error, data }) {
    //     if (data) {
    //         console.log('Priority picklist values received:', data);
    //         this.priorityOptions = data.values.map(item => ({
    //             label: item.label,
    //             value: item.value
    //         }));
    //     } else if (error) {
    //         console.error('Error fetching priority picklist values:', error);
    //         this.priorityOptions = [...this._defaultPriorityOptions];
    //     }
    // }
    
    // // Wire to get CGPH Determination picklist values
    // @wire(getPicklistValues, { 
    //     recordTypeId: '$outreachTrackingRecordTypeId', 
    //     fieldApiName: CGPH_DETERMINATION_FIELD 
    // })
    // wiredDeterminationPicklistValues({ error, data }) {
    //     if (data) {
    //         console.log('CGPH Determination picklist values received:', data);
    //         const options = data.values.map(item => ({
    //             label: item.label,
    //             value: item.value
    //         }));
    //         // Use same values for both approval and determination dropdowns
    //         this.approvalOptions = [...options];
    //         this.determinationOptions = [...options];
    //     } else if (error) {
    //         console.error('Error fetching CGPH determination picklist values:', error);
    //         this.approvalOptions = [...this._defaultApprovalOptions];
    //         this.determinationOptions = [...this._defaultDeterminationOptions];
    //     }
    // }

    // Transform Salesforce data to component format
    async transformDataToPropertyGroups(data) {
        if (!data || typeof data !== 'object') {
            this.propertyGroups = [];
            return;
        }

        const groups = [];
        let groupIndex = 0;

        // Convert each property in the data map to a property group
        // Use for...of to allow async/await
        for (const propertyKey of Object.keys(data)) {
            const listWrapper = data[propertyKey];
            if (!listWrapper || !listWrapper.otList) continue;

            // Get property name from first record or use a default
            const firstRecord = listWrapper.otList[0];
            const baseName = firstRecord?.Outreach_Tracker_Property_Name__c ||
                            firstRecord?.Property_Address__c ||
                            `Property ${String.fromCharCode(65 + groupIndex)}`;

            console.log('first record: '+JSON.stringify(firstRecord));

            console.log('###########################################################################');
            console.log('Base Name: ', firstRecord?.Service_File__r?.HOMEtracker__Property__r?.Development_address__r.Name);
            console.log('###########################################################################');

            // Set baseNameProperty to the Development name (matching OutreachTrackerStaff.page line 288)
            // This will be used as the card title
            if (!this.baseNameProperty) {
                this.baseNameProperty = firstRecord?.Service_File__r?.HOMEtracker__Property__r?.Development_address__r?.Name || 'Property';
            }

            // Get the Property record ID for navigation
            const propertyRecordId = firstRecord?.Property_Id__c || null;

            // Get the Development ID for inventory navigation
            const developmentId = firstRecord?.Service_File__r?.HOMEtracker__Property__r?.Development_address__r?.Id || null;

            // Call Apex method to check if this is a group property
            // This queries HOMEtracker__Property__c directly for accurate data
            let isGroupPropertyValue = false;
            try {
                if (propertyRecordId) {
                    isGroupPropertyValue = await isGroupProperty({ propertyId: propertyRecordId });
                    console.log('Property Record ID:', propertyRecordId);
                    console.log('Is Group Property (from Apex):', isGroupPropertyValue);
                }
            } catch (error) {
                console.error('Error checking group property status:', error);
                // Fall back to checking the field value from the record
                isGroupPropertyValue = !!firstRecord?.Service_File__r?.HOMEtracker__Property__r?.Group_Property__c;
                console.log('Is Group Property (fallback from record):', isGroupPropertyValue);
            }

            // Get bedroom count and rent information
            const rent = firstRecord?.Property_Rent_or_List_Price__c;
            const bedrooms = firstRecord?.Service_File__r?.HOMEtracker__Property__r?.HOMEtracker__Number_of_Bedrooms__c;

            // Get income level
            const incomeLevel = firstRecord?.Service_File__r?.HOMEtracker__Property__r?.Income_Level__c || '';

            // Get max application fee
            const maxApplicationFee = firstRecord?.Service_File__r?.HOMEtracker__Property__r?.Max_Application_Fee__c ||
                                     firstRecord?.Property_Unit__r?.Max_Application_Fee__c ||
                                     firstRecord?.Max_Application_Fee__c;

            // Get tracker order for sorting
            // Property_Id__c formula: use parent's ID for group properties, otherwise property's own ID
            // So for sorting, use parent's Tracker_Order__c for group properties, otherwise property's Tracker_Order__c
            const trackerOrder = firstRecord?.Service_File__r?.HOMEtracker__Property__r?.Group_Property_Parent__r?.Tracker_Order__c ||
                                firstRecord?.Service_File__r?.HOMEtracker__Property__r?.Tracker_Order__c;

            console.log(`Tracker_Order__c for property ${baseName}: ${trackerOrder}`);

            // Build property name based on whether it's a group property
            let propertyName = baseName;
            if (isGroupPropertyValue) {
                // For group properties, add bedroom and rent info
                const bedroomText = bedrooms ? `${bedrooms}BR` : '';
                const rentText = rent ? `$${rent}` : '';
                const additionalInfo = [bedroomText, rentText].filter(Boolean).join(', ');
                propertyName = additionalInfo ? `${baseName} - Group Property (${additionalInfo})` : `${baseName} - Group Property`;
            } else {
                // For individual properties, add bedrooms, income level, and rent
                // Format: "{baseName} - {bedrooms} BR {incomeLevel} - ${rent}"
                // Format "Moderate" as "Mod"
                let incomeLevelDisplay = incomeLevel;
                if (incomeLevel === 'Moderate') {
                    incomeLevelDisplay = 'Mod';
                }

                const bedroomText = bedrooms ? `${bedrooms} BR` : '';
                const incomeLevelText = incomeLevelDisplay || '';
                const rentText = rent ? `$${rent}` : '';

                // Build the property name parts
                const parts = [baseName];

                // Add bedrooms and income level together if available
                const bedroomIncomeText = [bedroomText, incomeLevelText].filter(Boolean).join(' ');
                if (bedroomIncomeText) {
                    parts.push(bedroomIncomeText);
                }

                // Add rent if available
                if (rentText) {
                    parts.push(rentText);
                }

                propertyName = parts.join(' - ');
            }

            console.table(listWrapper.otList);

            const applicants = listWrapper.otList.map(ot => this.transformOutreachTrackingToApplicant(ot));
            console.table(applicants);

            groups.push({
                id: propertyKey,
                uniqueKey: `${propertyKey}-${this.dataRefreshKey}`,
                name: propertyName,
                applicants: applicants,
                isGroupProperty: isGroupPropertyValue,
                propertyRecordId: propertyRecordId,
                maxApplicationFee: maxApplicationFee,
                trackerOrder: trackerOrder,
                developmentId: developmentId
            });

            groupIndex++;
        }

        // Sort properties by Tracker_Order__c first (ascending), then by Name (ascending)
        // Properties with Tracker_Order__c come first, then properties without it
        console.log('=== BEFORE SORTING ===');
        groups.forEach(g => console.log(`Property: ${g.name}, Tracker Order: ${g.trackerOrder}`));

        groups.sort((a, b) => {
            const aHasOrder = a.trackerOrder != null && a.trackerOrder !== undefined;
            const bHasOrder = b.trackerOrder != null && b.trackerOrder !== undefined;

            // If both have tracker order, sort by tracker order
            if (aHasOrder && bHasOrder) {
                return a.trackerOrder - b.trackerOrder;
            }

            // If only one has tracker order, that one comes first
            if (aHasOrder && !bHasOrder) {
                return -1;
            }
            if (!aHasOrder && bHasOrder) {
                return 1;
            }

            // If neither has tracker order, sort by name
            return (a.name || '').localeCompare(b.name || '');
        });

        console.log('=== AFTER SORTING ===');
        groups.forEach(g => console.log(`Property: ${g.name}, Tracker Order: ${g.trackerOrder}`));

        this.propertyGroups = groups;

        // Get development name and ID from first record
        let developmentName = '';
        let developmentIdFromRecord = '';
        if (groups.length > 0 && groups[0].applicants.length > 0) {
            const firstApplicant = groups[0].applicants[0];
            developmentName = firstApplicant.__originalRecord?.Service_File__r?.HOMEtracker__Property__r?.Development_address__r?.Name || '';
            developmentIdFromRecord = firstApplicant.__originalRecord?.Service_File__r?.HOMEtracker__Property__r?.Development_address__r?.Id || '';
        }

        // Store development ID for inventory button
        if (developmentIdFromRecord) {
            this.developmentIdForInventory = developmentIdFromRecord;
        }

        // Update card title with development name
        if (developmentName) {
            this.cardTitle = `${developmentName} Applicant Tracker`;
        } else {
            this.cardTitle = 'Applicant Tracker';
        }

        // Update page title with development name
        if (developmentName) {
            document.title = `${developmentName} Tracker`;
        } else {
            document.title = 'Applicant Tracker';
        }
    }
    
    // Transform individual Outreach_Tracking__c record to applicant format
    transformOutreachTrackingToApplicant(ot) {
        console.log('Type of ot.SF_Priority__c:', typeof ot.SF_Priority__c);
        console.log('Out tracking record:', JSON.stringify(ot));
        const applicant = {
            id: ot.Id,
            unitType: this.buildUnitTypeString(ot),
            //status: this.mapTrackerStatusToStatus(ot.Tracker_Status__c) || 'Hidden',
            status: ot.Tracker_Status__c,
            unit: ot.Property_Unit__r?.Name || ot.Property_Unit__r?.Unit_Number__c || ot.Unit__c || '',
            //priority: ot.SF_Priority__c || this.mapPriorityCalc(ot.Priority_Calc__c),
            priority: ot.SF_Priority__c,
            applicantName: ot.Applicant_Name__c || '',
            peopleInHousehold: ot.Household_Size__c || 0,
            email: ot.Applicant_Email__c,
            phone: ot.Applicant_Phone__c,
            dateCGPHAdded: this.formatDate(ot.Date_CGPH_Added_Name__c),
            dateMarkedPrimary: this.formatDate(ot.Date_Marked_Primary__c),
            //approvalDenial: ot.CGPH_Determination__c || 'Pending',
            approvalDenial: ot.Landlord_Developer_Determination__c,
            //approveDenyDate: this.formatDate(ot.CGPH_Approval_Denial_Date__c),
            approveDenyDate: this.formatDate(ot.Landlord_Developer_Determination_Date__c),
            notes: ot.Landlord_Developer_Notes__c,
            // notesTruncated: this.truncateNotes(ot.Landlord_Developer_Notes__c, 100),
            // hasMoreNotes: this.hasMoreNotes(ot.Landlord_Developer_Notes__c, 100),
            approvedForFullReview: this.isApprovedForFullReview(ot),
            approvedForFullReviewText: this.isApprovedForFullReview(ot) ? 'Yes' : 'No',
            fullReviewCGPHBegan: this.formatDate(ot.Date_Eligibility_Review_Began__c),
            readyDate: this.formatDate(ot.Date_Ready_for_Eligibility_Review__c),
            //cgphDetermination: ot.CGPH_Determination__c || 'Pending',
            cgphDetermination: ot.CGPH_Determination__c,
            dateOfDetermination: this.formatDate(ot.CGPH_Approval_Denial_Date__c),

            // Flagged applicant indicators (matching Visualforce functionality)
            isFlaggedForOutreach: ot.Service_File__r?.Pre_Applicant__r?.Flagged_for_Outreach__c || false,
            flaggedOutreachNotes: ot.Service_File__r?.Pre_Applicant__r?.Flagged_for_Outreach_Notes__c || '',
            preApplicantId: ot.Service_File__r?.Pre_Applicant__r?.Id || '',

            // Record IDs for navigation
            serviceFileId: ot.Service_File__c || '',
            propertyIdForReport: ot.Property_Id__c || '',

            // Unit assignment properties
            hasSpecificUnit: ot.Property_Unit__c != null,
            isGroupProperty: ot.Service_File__r?.HOMEtracker__Property__r?.Group_Property__c || false,
            propertyUnitId: ot.Property_Unit__c,
            developmentId: ot.Service_File__r?.HOMEtracker__Property__r?.Development_address__r?.Id,
            groupPropertyId: ot.Property_Id__c,
            // canAssignUnit: (ot.Service_File__r?.HOMEtracker__Property__r?.Group_Property__c &&
            //                ot.Landlord_Developer_Determination__c === 'Approved' &&
            //                ot.Property_Unit__c == null),
            canAssignUnit: ot.Service_File__r?.HOMEtracker__Property__r?.Group_Property__c,

            // Removal confirmation properties
            isRemoved: ot.Tracker_Status__c === 'Removed',
            moveToRemovedReport: ot.Move_to_Removed_Report__c || false,

            // Store original SF record for updates
            __originalRecord: ot
        };

        console.log('Transformed applicant record:', applicant.Name);
        console.log('Applicant ready date:', applicant.readyDate);
        console.log('*-*-*-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-*');
        console.log('is Group Property:', applicant.isGroupProperty);
        console.log('*-*-*-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-**-*');
        
        // Add dynamic styling classes
        applicant.rowCssClass = this.getRowCssClass(applicant);
        applicant.textCssClass = this.getTextCssClass(applicant);
        
        return applicant;
    }
    
    // Get CSS class for row background color based on Tracker_Status__c and Landlord_Developer_Determination__c
    getRowCssClass(applicant) {
        const status = applicant.status;
        const approvalDenial = applicant.approvalDenial;
        // Treat both "Approved" and "Approved Conditionally" as approved for styling
        const isApproved = approvalDenial === 'Approved' || approvalDenial === 'Approved Conditionally';
        const baseClass = 'editable-row';
        
        let statusClass = '';
        switch(status) {
            case 'Primary':
                statusClass = isApproved ? 'status-primary-approved' : 'status-primary';
                break;
            case 'Backup':
                statusClass = isApproved ? 'status-backup-approved' : 'status-backup';
                break;
            case 'Hidden':
                statusClass = isApproved ? 'status-hidden-approved' : 'status-hidden';
                break;
            case 'Flagged':
                statusClass = isApproved ? 'status-flagged-approved' : 'status-flagged';
                break;
            case 'Removed':
                statusClass = isApproved ? 'status-removed-approved' : 'status-removed';
                break;
            default:
                statusClass = '';
        }
        
        return `${baseClass} ${statusClass}`.trim();
    }
    
    // Get CSS class for text styling based on Landlord_Developer_Determination__c (following Visualforce logic)
    getTextCssClass(applicant) {
        const determination = applicant.approvalDenial;
        const status = applicant.status;

        // In Visualforce, all approved applicants get blue text (except removed which gets white)
        // Treat both "Approved" and "Approved Conditionally" as approved for styling
        if (determination === 'Approved' || determination === 'Approved Conditionally') {
            if (status === 'Removed') {
                return ''; // White text handled by status-removed-approved CSS class
            } else {
                return 'approved-text'; // Blue text for all other approved applicants
            }
        }

        return ''; // No special text styling for non-approved
    }
    
    // Field editability methods (matching Visualforce permissions)
    
    // Check if a field is editable based on user role and field type
    isFieldEditable(fieldName) {
        // CGP&H Staff editable fields (matching Visualforce <apex:inlineEditSupport>)
        const cgphEditableFields = [
            'status',              // Tracker_Status__c
            'dateCGPHAdded',      // Date_CGPH_Added_Name__c  
            'dateMarkedPrimary',  // Date_Marked_Primary__c
            'readyDate'          // Service_File__c.Ready_for_Full_Income_Cert_Date__c
        ];
        
        // Landlord/Developer editable fields (matching Visualforce <apex:inlineEditSupport>)
        const landlordEditableFields = [
            'approvalDenial',     // Landlord_Developer_Determination__c
            'approveDenyDate'     // Landlord_Developer_Determination_Date__c
        ];
        
        // Notes field requires special flow - making it read-only for now
        // (In Visualforce it links to a separate flow for editing)
        
        if (this.isUserCGPHStaff && cgphEditableFields.includes(fieldName)) {
            return true;
        }
        
        if (this.isUserLandlordDeveloper && landlordEditableFields.includes(fieldName)) {
            return true;
        }
        
        return false; // All other fields are read-only
    }
    
    // Get the disabled attribute for input fields
    getFieldDisabled(fieldName) {
        return !this.isFieldEditable(fieldName);
    }
    
    // Getter methods for template use (field disabled state - OPPOSITE of editable)
    get isUnitTypeDisabled() { return !this.isFieldEditable('unitType'); }
    get isStatusDisabled() { return !this.isFieldEditable('status'); }
    get isUnitDisabled() { return !this.isFieldEditable('unit'); }
    get isPriorityDisabled() { return !this.isFieldEditable('priority'); }
    get isApplicantNameDisabled() { return !this.isFieldEditable('applicantName'); }
    get isPeopleInHouseholdDisabled() { return !this.isFieldEditable('peopleInHousehold'); }
    get isEmailDisabled() { return !this.isFieldEditable('email'); }
    get isPhoneDisabled() { return !this.isFieldEditable('phone'); }
    get isDateCGPHAddedDisabled() { return !this.isFieldEditable('dateCGPHAdded'); }
    get isDateMarkedPrimaryDisabled() { return !this.isFieldEditable('dateMarkedPrimary'); }
    get isApprovalDenialDisabled() { return !this.isFieldEditable('approvalDenial'); }
    get isApproveDenyDateDisabled() { return !this.isFieldEditable('approveDenyDate'); }
    get isNotesDisabled() { return !this.isFieldEditable('notes'); }
    // get isApprovedForFullReviewDisabled() { return !this.isFieldEditable('approvedForFullReview'); }
    get isReadyDateDisabled() { return !this.isFieldEditable('readyDate'); }
    get isFullReviewCGPHBeganDisabled() { return !this.isFieldEditable('fullReviewCGPHBegan'); }
    get isCgphDeterminationDisabled() { return !this.isFieldEditable('cgphDetermination'); }
    get isDateOfDeterminationDisabled() { return !this.isFieldEditable('dateOfDetermination'); }
    
    // Error message getter for safe error display
get errorMessage() {
    if (!this.error) return '';
    
    if (this.error.body && this.error.body.message) {
        return this.error.body.message;
    } else if (this.error.message) {
        return this.error.message;
    } else if (typeof this.error === 'string') {
        return this.error;
    }
    
    return 'An unknown error occurred';
}

    // Update CSS classes for a specific applicant after field changes
    updateApplicantStyling(recordId) {
        // Create a new array to trigger reactivity
        const updatedPropertyGroups = [...this.propertyGroups];
        
        updatedPropertyGroups.forEach(propertyGroup => {
            propertyGroup.applicants.forEach(applicant => {
                if (applicant.id === recordId) {
                    // Recalculate CSS classes based on current field values
                    applicant.rowCssClass = this.getRowCssClass(applicant);
                    applicant.textCssClass = this.getTextCssClass(applicant);
                }
            });
        });
        
        // Update the property groups to trigger re-render
        this.propertyGroups = updatedPropertyGroups;
    }
    
    // Helper methods for data transformation
    buildUnitTypeString(ot) {
        const unitInfo = ot.Property_Unit__r?.Unit_Number__c || ot.Unit__c || '';
        const rent = ot.Property_Rent_or_List_Price__c;
        if (rent) {
            return `${unitInfo} for $${rent}`;
        }
        return unitInfo || 'Unit information not available';
    }
    
    mapTrackerStatusToStatus(trackerStatus) {
        const statusMap = {
            'Applied': 'Applied',
            'Under Review': 'Under Review', 
            'Approved': 'Approved',
            'Denied': 'Denied',
            'Waitlisted': 'Waitlisted'
        };
        return statusMap[trackerStatus] || 'Applied';
    }
    
    mapPriorityCalc(priorityCalc) {
        if (priorityCalc <= 3) return 'High';
        if (priorityCalc <= 6) return 'Medium';
        return 'Low';
    }
    
    isApprovedForFullReview(ot) {
        return ot.Date_Eligibility_Review_Began__c || ot.Date_Ready_for_Eligibility_Review__c;
    }
    
    formatDate(dateValue) {
        if (!dateValue) return '';
        try {
            return new Date(dateValue).toISOString().split('T')[0];
        } catch (e) {
            return dateValue;
        }
    }
    
    // Fallback hardcoded data (keep as backup if no propertyId provided)
    _hardcodedPropertyGroups = [
        {
            id: 'property-a',
            name: 'Property A - Luxury Tower East',
            applicants: [
                {
                    id: 'a1',
                    unitType: '1 bedroom units for $2,500',
                    status: 'Primary',
                    unit: 'A101',
                    priority: 'High',
                    applicantName: 'Sarah Johnson (Primary + Approved)',
                    peopleInHousehold: 2,
                    email: 'sarah.j@email.com',
                    phone: '(555) 123-4567',
                    dateCGPHAdded: '2025-01-15',
                    dateMarkedPrimary: '2025-01-16',
                    approvalDenial: 'Approved',
                    approveDenyDate: '2025-01-20',
                    notes: '',
                    approvedForFullReview: true,
                    approvedForFullReviewText: 'Yes',
                    fullReviewCGPHBegan: '2025-01-21',
                    cgphDetermination: 'Approved',
                    dateOfDetermination: '2025-01-25',
                    // Flagged data for testing
                    isFlaggedForOutreach: false,
                    flaggedOutreachNotes: '',
                    preApplicantId: 'pre1'
                },
                {
                    id: 'a2',
                    unitType: '2 bedroom units for $3,200',
                    status: 'Backup',
                    unit: 'A205',
                    priority: 'Medium',
                    applicantName: 'Michael Roberto (Backup + Approved - Warning!)',
                    peopleInHousehold: 3,
                    email: 'mike.a@gmail.com',
                    phone: '(555) 987-6543',
                    dateCGPHAdded: '2025-01-10',
                    dateMarkedPrimary: '2025-01-12',
                    approvalDenial: 'Approved',
                    approveDenyDate: '2025-01-18',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: '',
                    // Flagged data for testing - this applicant is flagged
                    isFlaggedForOutreach: true,
                    flaggedOutreachNotes: 'Previous rental history shows late payments and property damage concerns',
                    preApplicantId: 'pre2'
                },
                {
                    id: 'a3',
                    unitType: '1 bedroom units for $2,500',
                    status: 'Hidden',
                    unit: 'A301',
                    priority: 'High',
                    applicantName: 'Lisa Marie (Hidden)',
                    peopleInHousehold: 1,
                    email: 'lisa.t@yahoo.com',
                    phone: '(555) 345-6789',
                    dateCGPHAdded: '2025-01-08',
                    dateMarkedPrimary: '2025-01-09',
                    approvalDenial: 'Denied',
                    approveDenyDate: '2025-01-18',
                    notes: '',
                    approvedForFullReview: true,
                    approvedForFullReviewText: 'Yes',
                    fullReviewCGPHBegan: '2025-01-19',
                    cgphDetermination: 'Approved',
                    dateOfDetermination: '2025-01-24',
                    // Flagged data for testing
                    isFlaggedForOutreach: false,
                    flaggedOutreachNotes: '',
                    preApplicantId: 'pre3'
                }
            ]
        },
        {
            id: 'property-b',
            name: 'Property B - Garden View Apartments',
            applicants: [
                {
                    id: 'b1',
                    unitType: '1 bedroom units for $2,800',
                    status: 'Approved',
                    unit: 'B301',
                    priority: 'High',
                    applicantName: 'Jennifer Marie ',
                    peopleInHousehold: 1,
                    email: 'jen.d@outlook.com',
                    phone: '(555) 456-7890',
                    dateCGPHAdded: '2025-01-08',
                    dateMarkedPrimary: '2025-01-09',
                    approvalDenial: 'Approved',
                    approveDenyDate: '2025-01-15',
                    notes: '',
                    approvedForFullReview: true,
                    approvedForFullReviewText: 'Yes',
                    fullReviewCGPHBegan: '2025-01-16',
                    cgphDetermination: 'Approved',
                    dateOfDetermination: '2025-01-22'
                },
                {
                    id: 'b2',
                    unitType: '2 bedroom units for $3,500',
                    status: 'Under Review',
                    unit: 'B105',
                    priority: 'Medium',
                    applicantName: 'Robert Kim',
                    peopleInHousehold: 2,
                    email: 'rob.k@email.com',
                    phone: '(555) 234-5678',
                    dateCGPHAdded: '2025-01-12',
                    dateMarkedPrimary: '2025-01-14',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                },
                {
                    id: 'b3',
                    unitType: '1 bedroom units for $2,800',
                    status: 'Waitlisted',
                    unit: 'B207',
                    priority: 'Low',
                    applicantName: 'Amanda Rodriguez',
                    peopleInHousehold: 1,
                    email: 'amanda.r@mail.com',
                    phone: '(555) 567-8901',
                    dateCGPHAdded: '2025-01-05',
                    dateMarkedPrimary: '',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                }
            ]
        },
        {
            id: 'property-c',
            name: 'Property C - Downtown Loft Complex',
            applicants: [
                {
                    id: 'c1',
                    unitType: 'Studio units for $2,100',
                    status: 'Waitlisted',
                    unit: 'C150',
                    priority: 'Low',
                    applicantName: 'David Christopher',
                    peopleInHousehold: 1,
                    email: 'david.m@edu.com',
                    phone: '(555) 321-0987',
                    dateCGPHAdded: '2025-01-12',
                    dateMarkedPrimary: '',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                },
                {
                    id: 'c2',
                    unitType: '2 bedroom units for $3,800',
                    status: 'Denied',
                    unit: 'C275',
                    priority: 'Medium',
                    applicantName: 'Amanda Elizabeth',
                    peopleInHousehold: 4,
                    email: 'amanda.e@home.net',
                    phone: '(555) 654-3210',
                    dateCGPHAdded: '2025-01-05',
                    dateMarkedPrimary: '2025-01-06',
                    approvalDenial: 'Denied',
                    approveDenyDate: '2025-01-18',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Denied',
                    dateOfDetermination: '2025-01-18'
                },
                {
                    id: 'c3',
                    unitType: 'Studio units for $2,100',
                    status: 'Applied',
                    unit: 'C180',
                    priority: 'High',
                    applicantName: 'James William',
                    peopleInHousehold: 1,
                    email: 'james.c@tech.com',
                    phone: '(555) 789-0123',
                    dateCGPHAdded: '2025-01-14',
                    dateMarkedPrimary: '2025-01-15',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                }
            ]
        },
        {
            id: 'property-d',
            name: 'Property D - Riverside Towers',
            applicants: [
                {
                    id: 'd1',
                    unitType: '3 bedroom units for $4,200',
                    status: 'Under Review',
                    unit: 'D401',
                    priority: 'High',
                    applicantName: 'Maria Elena',
                    peopleInHousehold: 5,
                    email: 'maria.g@family.com',
                    phone: '(555) 111-2222',
                    dateCGPHAdded: '2025-01-10',
                    dateMarkedPrimary: '2025-01-11',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: true,
                    approvedForFullReviewText: 'Yes',
                    fullReviewCGPHBegan: '2025-01-17',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                },
                {
                    id: 'd2',
                    unitType: '2 bedroom units for $3,600',
                    status: 'Applied',
                    unit: 'D205',
                    priority: 'Medium',
                    applicantName: 'Kevin Park Smith',
                    peopleInHousehold: 3,
                    email: 'kevin.p@work.org',
                    phone: '(555) 333-4444',
                    dateCGPHAdded: '2025-01-13',
                    dateMarkedPrimary: '',
                    approvalDenial: 'Pending',
                    approveDenyDate: '',
                    notes: '',
                    approvedForFullReview: false,
                    approvedForFullReviewText: 'No',
                    fullReviewCGPHBegan: '',
                    cgphDetermination: 'Pending',
                    dateOfDetermination: ''
                },
                {
                    id: 'd3',
                    unitType: '1 bedroom units for $2,900',
                    status: 'Approved',
                    unit: 'D102',
                    priority: 'High',
                    applicantName: 'Rachel Anne',
                    peopleInHousehold: 2,
                    email: 'rachel.w@live.com',
                    phone: '(555) 555-6666',
                    dateCGPHAdded: '2025-01-07',
                    dateMarkedPrimary: '2025-01-08',
                    approvalDenial: 'Approved',
                    approveDenyDate: '2025-01-16',
                    notes: '',
                    approvedForFullReview: true,
                    approvedForFullReviewText: 'Yes',
                    fullReviewCGPHBegan: '2025-01-17',
                    cgphDetermination: 'Approved',
                    dateOfDetermination: '2025-01-23'
                }
            ]
        }
    ];

    @track isLoading = false;
    @track nextPropertyLetter = 'E';
    @track isFlowOpen = false;
    @track flowInputs;
    flowApiName = 'OT_Find_Available_Properties_By_Development';

    // Notes Modal State
    // @track isNotesModalOpen = false;
    // @track selectedNotes = '';
    // @track selectedApplicantName = '';
    // @track selectedApplicantId = '';

    // Component lifecycle
    async connectedCallback() {
        console.log('connectedCallback called');
        console.log('Current URL:', window.location.href);
        //get url
        console.log('Property ID from attribute:', this.propertyId);

        // Initialize dropdown options with defaults first
        this.setDefaultDropdownOptions();
        
        // For testing: use hardcoded test property ID if no propertyId is provided
        if (!this.propertyId) {
            // Uncomment the line below to test with real Salesforce data
            this.propertyId = this.testPropertyId;
            
            // Comment out the line below when testing with real data
            // this.propertyGroups = this._hardcodedPropertyGroups;
            // return;
        }
        
        // Load data from Salesforce if propertyId is provided
        if (this.propertyId) {
            await this.loadOutreachTrackingData();
        } else {
            // Use hardcoded sample data as fallback
            this.propertyGroups = this._hardcodedPropertyGroups;
            // Apply styling to hardcoded data
            this.applyDynamicStylingToPropertyGroups();
            this.setDefaultDropdownOptions();
        }
    }
    
    // Load outreach tracking data from Salesforce
    async loadOutreachTrackingData(showLoading = true) {
        try {
            if (showLoading) {
                this.isLoading = true;
            }
            this.error = null;

            // Clear existing data to ensure reactivity
            this.propertyGroups = [];

            // Increment refresh key to force template re-render
            this.dataRefreshKey++;

            console.log('Loading data for property ID:', this.propertyId);
            console.log('Data refresh key:', this.dataRefreshKey);

            const data = this.isSinglePropertyMode
                ? await getOutreachTrackingBySingleProperty({ propertyId: this.propertyId })
                : await getOutreachTrackingByProperty({ propertyId: this.propertyId });

            console.log('Raw data returned from Apex:', JSON.stringify(data));

            // Log each property to check if it's a group property
            console.log('=== PROPERTY GROUP CHECK ===');
            Object.keys(data).forEach((propertyKey, index) => {
                const listWrapper = data[propertyKey];
                if (listWrapper && listWrapper.otList && listWrapper.otList.length > 0) {
                    const firstRecord = listWrapper.otList[0];
                    const isGroupProperty = !!firstRecord?.Service_File__r?.HOMEtracker__Property__r?.Group_Property__c;
                    const propertyName = firstRecord?.Outreach_Tracker_Property_Name__c || 'Unknown';
                    console.log(`Property ${index + 1}: "${propertyName}"`);
                    console.log(`  - Property Key: ${propertyKey}`);
                    console.log(`  - Is Group Property: ${isGroupProperty}`);
                    console.log(`  - Group_Property__c value: ${firstRecord?.Service_File__r?.HOMEtracker__Property__r?.Group_Property__c}`);
                    console.log(`  - Property ID: ${firstRecord?.Property_Id__c}`);
                    console.log(`  - Number of applicants: ${listWrapper.otList.length}`);
                    console.log(`  - Sample applicant record:`, JSON.stringify(firstRecord));
                }
            });
            console.log('=== END PROPERTY GROUP CHECK ===');
            
            if (data) {
                console.log('Outreach Tracking Data received:', data);
                console.table(data);
                this.outreachTrackingData = data;
                //this.populateDropdownOptions(data);
                await this.transformDataToPropertyGroups(data);
                console.log('Property groups updated with', this.propertyGroups.length, 'properties');
            } else {
                console.log('No data returned from Apex method');
                this.propertyGroups = [];
                this.setDefaultDropdownOptions();
            }
            
        } catch (error) {
            console.error('Error loading outreach tracking data:', error);
            this.error = error;
            this.propertyGroups = [];
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Failed to load data: ' + (error.body?.message || error.message),
                variant: 'error'
            }));
        } finally {
            if (showLoading) {
                this.isLoading = false;
            }
        }
    }
    
    // Populate dropdown options from Salesforce data
    populateDropdownOptions(data) {
        const statusValues = new Set();
        const priorityValues = new Set();
        const approvalValues = new Set();
        const determinationValues = new Set();
        
        // Extract unique values from all records
        Object.keys(data).forEach(propertyKey => {
            const listWrapper = data[propertyKey];
            if (listWrapper && listWrapper.otList) {
                listWrapper.otList.forEach(ot => {
                    // Status options from Tracker_Status__c
                    if (ot.Tracker_Status__c) {
                        console.log('Found Tracker_Status__c:', ot.Tracker_Status__c);
                        statusValues.add(ot.Tracker_Status__c);
                    }
                    
                    // Priority options from SF_Priority__c 
                    if (ot.SF_Priority__c) {
                        console.log('Found SF_Priority__c:', ot.SF_Priority__c);
                        priorityValues.add(ot.SF_Priority__c);
                    }
                    
                    // Approval/Denial options from CGPH_Determination__c
                    if (ot.CGPH_Determination__c) {
                        console.log('Found CGPH_Determination__c:', ot.CGPH_Determination__c);
                        approvalValues.add(ot.CGPH_Determination__c);
                        determinationValues.add(ot.CGPH_Determination__c);
                    }
                });
            }
        });
        
        // Convert Sets to dropdown option arrays
        this.statusOptions = this.createDropdownOptions(statusValues);
        this.priorityOptions = this.createDropdownOptions(priorityValues);
        console.table(this.priorityOptions);
        this.approvalOptions = this.createDropdownOptions(approvalValues);
        this.determinationOptions = this.createDropdownOptions(determinationValues);
        
        console.log('Populated dropdown options:', {
            status: this.statusOptions,
            priority: this.priorityOptions,
            approval: this.approvalOptions,
            determination: this.determinationOptions
        });
    }
    
    // Create dropdown options from unique values
    createDropdownOptions(uniqueValues) {
        const allValues = new Set();

        // Add unique values from data
        uniqueValues.forEach(value => {
            if (value !== null && value !== undefined) {
                // Convert to string and trim
                const stringValue = String(value).trim();
                if (stringValue) {
                    allValues.add(stringValue);
                }
            }
        });

        // Convert to dropdown option format and sort
        return Array.from(allValues)
            .sort()
            .map(value => ({ label: value, value: value }));
    }
    
    // Set default dropdown options when no data is available
    setDefaultDropdownOptions() {
        this.statusOptions = [...this._defaultStatusOptions];
        this.priorityOptions = [...this._defaultPriorityOptions];
        this.approvalOptions = [...this._defaultApprovalOptions];
        this.determinationOptions = [...this._defaultDeterminationOptions];
        
        console.log('Set default dropdown options');
    }
    
    // Apply dynamic styling to all applicants in property groups
    applyDynamicStylingToPropertyGroups() {
        this.propertyGroups.forEach(property => {
            property.applicants.forEach(applicant => {
                // Ensure flagged properties exist for sample data
                if (applicant.isFlaggedForOutreach === undefined) {
                    applicant.isFlaggedForOutreach = false;
                    applicant.flaggedOutreachNotes = '';
                    applicant.preApplicantId = '';
                }
                
                applicant.rowCssClass = this.getRowCssClass(applicant);
                applicant.textCssClass = this.getTextCssClass(applicant);
            });
        });
    }

    // Default/fallback options if no data is available
    _defaultStatusOptions = [
        { label: 'Applied', value: 'Applied' },
        { label: 'Under Review', value: 'Under Review' },
        { label: 'Approved', value: 'Approved' },
        { label: 'Denied', value: 'Denied' },
        { label: 'Waitlisted', value: 'Waitlisted' }
    ];

    _defaultPriorityOptions = [
        { label: 'High', value: 'High' },
        { label: 'Medium', value: 'Medium' },
        { label: 'Low', value: 'Low' }
    ];

    _defaultApprovalOptions = [
        // { label: 'Pending', value: 'Pending' },
        { label: 'Approved', value: 'Approved' },
        { label: 'Denied', value: 'Denied' }
    ];

    _defaultDeterminationOptions = [
        { label: 'Approved', value: 'Approved' },
        { label: 'Denied', value: 'Denied' },
        { label: 'Pending', value: 'Pending' }
    ];

    async handleFieldChange(event) {
        const applicantId = event.target.dataset.id;
        const propertyId = event.target.dataset.property;
        const field = event.target.dataset.field;
        const value = event.target.type === 'checkbox' ? event.target.checked : event.target.value;

        // Check if user has permission to edit this field (matching Visualforce permissions)
        if (!this.isFieldEditable(field)) {
            console.warn(`User does not have permission to edit field: ${field}`);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Permission Denied',
                message: `You do not have permission to edit the ${field} field`,
                variant: 'warning'
            }));
            return;
        }

        // Find the applicant to get original record and name
        const propertyIndex = this.propertyGroups.findIndex(prop => prop.id === propertyId);
        if (propertyIndex === -1) return;

        const applicantIndex = this.propertyGroups[propertyIndex].applicants.findIndex(app => app.id === applicantId);
        if (applicantIndex === -1) return;

        const applicant = this.propertyGroups[propertyIndex].applicants[applicantIndex];
        const applicantName = applicant.applicantName;

        // Save to Salesforce if we have original record and propertyId (not using fallback data)
        if (this.propertyId && applicant.__originalRecord) {
            // Create a temporary updated applicant for calculating auto-populated fields
            const tempApplicant = { ...applicant };
            tempApplicant[field] = value;

            // Automatic date population when Tracker_Status__c changes
            if (field === 'status') {
                const currentDate = new Date().toISOString().split('T')[0]; // Format: YYYY-MM-DD

                // Auto-populate Date_CGPH_Added_Name__c if blank and status is Primary or Backup
                if ((value === 'Primary' || value === 'Backup') && !applicant.dateCGPHAdded) {
                    tempApplicant.dateCGPHAdded = currentDate;
                }

                // Auto-populate Date_Marked_Primary__c if blank and status is Primary
                if (value === 'Primary' && !applicant.dateMarkedPrimary) {
                    tempApplicant.dateMarkedPrimary = currentDate;
                }
            }

            await this.saveFieldToSalesforce(applicant, field, value, tempApplicant);

            // Show success message
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: `${field} updated successfully for ${applicantName}`,
                variant: 'success'
            }));

            // Dispatch RefreshEvent to refresh the component and display updated values
            console.log('Dispatching refresh event after field change...');
            this.dispatchEvent(new RefreshEvent());
            console.log('Refresh event dispatched');
        } else {
            // For local-only changes (fallback data), update the local state
            const updatedPropertyGroups = [...this.propertyGroups];
            const localApplicant = updatedPropertyGroups[propertyIndex].applicants[applicantIndex];

            localApplicant[field] = value;

            // Special handling for checkbox display text
            if (field === 'approvedForFullReview') {
                localApplicant.approvedForFullReviewText = value ? 'Yes' : 'No';
            }

            // Automatic date population when Tracker_Status__c changes
            if (field === 'status') {
                const currentDate = new Date().toISOString().split('T')[0]; // Format: YYYY-MM-DD

                // Auto-populate Date_CGPH_Added_Name__c if blank and status is Primary or Backup
                if ((value === 'Primary' || value === 'Backup') && !localApplicant.dateCGPHAdded) {
                    localApplicant.dateCGPHAdded = currentDate;
                }

                // Auto-populate Date_Marked_Primary__c if blank and status is Primary
                if (value === 'Primary' && !localApplicant.dateMarkedPrimary) {
                    localApplicant.dateMarkedPrimary = currentDate;
                }
            }

            if (field === 'approvalDenial') {
                // Allow unit assignment for both "Approved" and "Approved Conditionally"
                localApplicant.canAssignUnit =
                    localApplicant.isGroupProperty && (value === 'Approved' || value === 'Approved Conditionally') && !localApplicant.hasSpecificUnit;
            }

            // Update CSS classes immediately if status or approval fields changed
            if (field === 'status' || field === 'approvalDenial') {
                localApplicant.rowCssClass = this.getRowCssClass(localApplicant);
                localApplicant.textCssClass = this.getTextCssClass(localApplicant);
            }

            this.propertyGroups = updatedPropertyGroups;

            // Show success message for local-only changes (fallback data)
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: `${field} updated successfully for ${applicantName}`,
                variant: 'success'
            }));
        }
    }
    
    // Save individual field changes to Salesforce
    async saveFieldToSalesforce(applicant, field, value, updatedApplicant) {
       //try {
            const originalRecord = applicant.__originalRecord;
            let fieldMapping = this.mapFieldToSalesforceField(field, value);
            
            // Handle automatic date updates when status changes
            if (field === 'status') {
                const additionalUpdates = {};
                
                // Check if Date_CGPH_Added_Name__c was auto-populated
                if ((value === 'Primary' || value === 'Backup') && 
                    updatedApplicant.dateCGPHAdded && 
                    !applicant.__originalRecord.Date_CGPH_Added_Name__c) {
                    additionalUpdates.Date_CGPH_Added_Name__c = updatedApplicant.dateCGPHAdded;
                }
                
                // Check if Date_Marked_Primary__c was auto-populated
                if (value === 'Primary' && 
                    updatedApplicant.dateMarkedPrimary && 
                    !applicant.__originalRecord.Date_Marked_Primary__c) {
                    additionalUpdates.Date_Marked_Primary__c = updatedApplicant.dateMarkedPrimary;
                }
                
                // Merge additional updates with the main field mapping
                fieldMapping = { ...fieldMapping, ...additionalUpdates };
            }
            
            const recordToUpdate = {
                Id: originalRecord.Id,
                ...fieldMapping
            };
            
            console.log('Saving record to Salesforce:', JSON.stringify(recordToUpdate, null, 2));
            console.log('Field mapping:', JSON.stringify(fieldMapping, null, 2));
            
            // Try the alternative single record method first
            try {
                const recordString = JSON.stringify(recordToUpdate);
                console.log('Calling saveSingleOutreachTracking with:', recordString);
                const result = await saveSingleOutreachTracking({ recordData: recordString });
                console.log('Single record save result:', result);
            } catch (singleError) {
                console.log('Single record method failed, trying array method:', singleError);
                
                // Fallback to array method
                const recordsToUpdate = [recordToUpdate];
                console.log('Records array:', JSON.stringify(recordsToUpdate, null, 2));
                await saveOutreachTrackings({ updates: recordsToUpdate });
            }
            
            // Update the original record in memory to keep it in sync
            this.updateOriginalRecord(originalRecord.Id, fieldMapping);
            
            // Update CSS classes if status or approval fields changed (affects colors)
            if (field === 'status' || field === 'approvalDenial') {
                this.updateApplicantStyling(originalRecord.Id);
            }
            
        //} 
        
         // catch (error) {
        //     console.error('Error saving to Salesforce:', error);
        //     console.error('Error details:', JSON.stringify(error));
            
        //     let errorMessage = 'Failed to save changes to Salesforce';
        //     if (error.body && error.body.message) {
        //         errorMessage += ': ' + error.body.message;
        //     } else if (error.message) {
        //         errorMessage += ': ' + error.message;
        //     }
            
        //     this.dispatchEvent(new ShowToastEvent({
        //         title: 'Error',
        //         message: errorMessage,
        //         variant: 'error'
        //     }));
        // }
    }
    
    // Map component field to Salesforce field
    mapFieldToSalesforceField(field, value) {
        const fieldMapping = {
            'status': { 'Tracker_Status__c': value },
            'priority': { 'SF_Priority__c': value },
            'applicantName': { 'Applicant_Name__c': value },
            'peopleInHousehold': { 'Household_Size__c': value },
            'email': { 'Applicant_Email__c': value },
            'phone': { 'Applicant_Phone__c': value },
            'dateCGPHAdded': { 'Date_CGPH_Added_Name__c': value },
            'dateMarkedPrimary': { 'Date_Marked_Primary__c': value },
            'approvalDenial': { 'Landlord_Developer_Determination__c': value },
            'approveDenyDate': { 'Landlord_Developer_Determination_Date__c': value },
            'notes': { 'Landlord_Developer_Notes__c': value },
            'readyDate': { 'Service_File__c.Ready_for_Full_Income_Cert_Date__c': value },
            'fullReviewCGPHBegan': { 'Date_Eligibility_Review_Began__c': value },
            'cgphDetermination': { 'CGPH_Determination__c': value },
            'dateOfDetermination': { 'CGPH_Approval_Denial_Date__c': value }
        };

        return fieldMapping[field] || {};
    }
    
    // Update the original record in memory
    updateOriginalRecord(recordId, fieldMapping) {
        this.propertyGroups.forEach(propertyGroup => {
            propertyGroup.applicants.forEach(applicant => {
                if (applicant.__originalRecord && applicant.__originalRecord.Id === recordId) {
                    // Create a new mutable copy of the original record
                    const updatedOriginalRecord = { ...applicant.__originalRecord };
                    
                    // Apply the field updates to the mutable copy
                    Object.keys(fieldMapping).forEach(sfField => {
                        updatedOriginalRecord[sfField] = fieldMapping[sfField];
                    });
                    
                    // Replace the original record with the updated mutable copy
                    applicant.__originalRecord = updatedOriginalRecord;
                }
            });
        });
    }

    handleInventoryClick() {
        // Navigate to PropertyInventoryStaff_R Visualforce page with development ID
        if (!this.developmentIdForInventory) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Development ID not available',
                variant: 'error'
            }));
            return;
        }

        // Dynamically construct the Visualforce page URL based on current org
        // Get current domain and convert to VF domain format
        const currentUrl = window.location.hostname;
        let vfDomain;

        if (currentUrl.includes('.sandbox.lightning.force.com')) {
            // Sandbox Lightning: mydomain--sandboxname.sandbox.lightning.force.com -> mydomain--sandboxname--c.sandbox.vf.force.com
            vfDomain = currentUrl.replace('.sandbox.lightning.force.com', '--c.sandbox.vf.force.com');
        } else if (currentUrl.includes('.lightning.force.com')) {
            // Production Lightning: mydomain.lightning.force.com -> mydomain--c.vf.force.com
            vfDomain = currentUrl.replace('.lightning.force.com', '--c.vf.force.com');
        } else if (currentUrl.includes('.sandbox.my.salesforce.com')) {
            // Sandbox My domain: mydomain--sandboxname.sandbox.my.salesforce.com -> mydomain--sandboxname--c.sandbox.vf.force.com
            const domainPrefix = currentUrl.split('.sandbox.my.salesforce.com')[0];
            vfDomain = `${domainPrefix}--c.sandbox.vf.force.com`;
        } else if (currentUrl.includes('.my.salesforce.com')) {
            // Production My domain: mydomain.my.salesforce.com -> mydomain--c.vf.force.com
            const domainPrefix = currentUrl.split('.my.salesforce.com')[0];
            vfDomain = `${domainPrefix}--c.vf.force.com`;
        } else if (currentUrl.includes('--c.sandbox.visualforce.com')) {
            // Already on sandbox VF: mydomain--c.sandbox.visualforce.com -> mydomain--c.sandbox.vf.force.com
            vfDomain = currentUrl.replace('--c.sandbox.visualforce.com', '--c.sandbox.vf.force.com');
        } else if (currentUrl.includes('--c.visualforce.com')) {
            // Already on production VF: mydomain--c.visualforce.com -> mydomain--c.vf.force.com
            vfDomain = currentUrl.replace('--c.visualforce.com', '--c.vf.force.com');
        } else {
            // Fallback to production URL if we can't determine the domain
            vfDomain = 'cgph--c.vf.force.com';
            console.warn('Could not determine VF domain, using production URL');
        }

        const vfPageUrl = `https://${vfDomain}/apex/PropertyInventoryStaff_R?id=${this.developmentIdForInventory}`;
        console.log('Opening VF page:', vfPageUrl);

        // Open in new window/tab
        window.open(vfPageUrl, '_blank');
    }

    handleRemovedClick() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Removed Applicants',
            message: 'This would show previously removed applicants',
            variant: 'info'
        }));
    }

    handleContactClick() {
        this.dispatchEvent(new ShowToastEvent({
            title: 'Development Contact',
            message: 'Contact: John Smith, Development Manager\nPhone: (555) 999-0000\nEmail: john.smith@luxuryapartments.com',
            variant: 'info'
        }));
    }

    handleAddProperty(event) {
        const propertyId = event.target.dataset.property;
        this.dispatchEvent(new ShowToastEvent({
            title: 'Add Property',
            message: `This would add a new property similar to ${propertyId}`,
            variant: 'info'
        }));
    }

    handleRemoveProperty(event) {
        const propertyId = event.target.dataset.property;
        
        // Find property name for confirmation message
        const property = this.propertyGroups.find(p => p.id === propertyId);
        const propertyName = property ? property.name : propertyId;
        
        // Remove the property from the array
        this.propertyGroups = this.propertyGroups.filter(prop => prop.id !== propertyId);
        
        this.dispatchEvent(new ShowToastEvent({
            title: 'Property Removed',
            message: `${propertyName} has been successfully removed`,
            variant: 'success'
        }));
    }

    handleAddNewProperty() {
        const newPropertyId = `property-${this.nextPropertyLetter.toLowerCase()}`;
        const newProperty = {
            id: newPropertyId,
            name: `Property ${this.nextPropertyLetter} - New Development`,
            applicants: []
        };

        this.propertyGroups = [...this.propertyGroups, newProperty];
        
        // Increment the next property letter
        this.nextPropertyLetter = String.fromCharCode(this.nextPropertyLetter.charCodeAt(0) + 1);
        
        this.dispatchEvent(new ShowToastEvent({
            title: 'Success',
            message: `New property ${newProperty.name} added successfully`,
            variant: 'success'
        }));
    }

    async handleRefresh() {
        if (this.propertyId) {
            // Reload data from Salesforce
            await this.loadOutreachTrackingData();
            
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Data refreshed successfully from Salesforce',
                variant: 'success'
            }));
        } else {
            // Simulate refresh for sample data
            this.isLoading = true;
            setTimeout(() => {
                this.isLoading = false;
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success',
                    message: 'Sample data refreshed successfully',
                    variant: 'success'
                }));
            }, 1000);
        }
    }

    handleZoomIn(event) {
        const propertyId = event.currentTarget.dataset.propertyId;
        const devId = event.currentTarget.dataset.developmentId;
        if (!propertyId || !devId) {
            console.error('Zoom in missing IDs — propertyId:', propertyId, 'devId:', devId);
            return;
        }
        const url = new URL(window.location.href);
        url.searchParams.set('c__recordId', propertyId);
        url.searchParams.set('c__devId', devId);
        window.location.href = url.toString();
    }

    handleZoomOut() {
        if (!this.zoomOutDevelopmentId) {
            console.error('No development ID available for zoom out');
            return;
        }
        const url = new URL(window.location.href);
        url.searchParams.set('c__recordId', this.zoomOutDevelopmentId);
        url.searchParams.delete('c__devId');
        window.location.href = url.toString();
    }

        handleNavigateToProperty(event) {
        const propertyRecordId = event.currentTarget.dataset.propertyRecordId;
        console.log('Navigating to property record ID:', JSON.stringify(propertyRecordId));

        if (!propertyRecordId) {
            console.error('No property record ID provided for navigation');
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Property record ID not available',
                variant: 'error'
            }));
            return;
        }

        // Always navigate to HOMEtracker__Property__c record page
        // This matches the Visualforce page behavior
        // Generate the URL and open in a new tab
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: propertyRecordId,
                objectApiName: 'HOMEtracker__Property__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
}   

    // Unit Assignment Methods

    /**
     * Handle unit assignment button click
     * Opens unit selection modal for approved group property applicants
     */
    handleAssignUnit(event) {
        const applicantId = event.target.dataset.applicantId;

        // Find the applicant record
        const applicant = this.findApplicantById(applicantId);
        if (!applicant) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Applicant record not found',
                variant: 'error'
            }));
            return;
        }

        // Validate applicant is eligible for unit assignment
        if (!applicant.canAssignUnit) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Not Eligible',
                message: 'Unit assignment is only available for approved group property applicants without a specific unit',
                variant: 'warning'
            }));
            return;
        }

        if (!applicant.developmentId || !applicant.groupPropertyId) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Missing Data',
                message: 'Cannot launch unit assignment flow because required property information is missing.',
                variant: 'error'
            }));
            return;
        }

        this.flowInputs = [
            { name: 'varDevID', type: 'String', value: applicant.developmentId },
            { name: 'varID', type: 'String', value: applicant.id },
            { name: 'varPropID', type: 'String', value: applicant.groupPropertyId },
            { name: 'varType', type: 'String', value: 'u' }
        ];
        this.isFlowOpen = true;
    }

    handleFlowStatus(event) {
        const { status } = event.detail;
        if (status === 'FINISHED') {
            this.isFlowOpen = false;
            this.flowInputs = null;
            // Dispatch refresh event to ensure all data is up to date
            this.dispatchEvent(new RefreshEvent());
        } else if (status === 'PAUSED') {
            this.isFlowOpen = false;
            this.flowInputs = null;
            // Dispatch refresh event to ensure all data is up to date
            this.dispatchEvent(new RefreshEvent());
        }
    }

    handleFlowClose() {
        this.isFlowOpen = false;
        this.flowInputs = null;
    }
    
    /**
     * Handle cancel unit assignment (return to group property)
     */
    async handleCancelUnitAssignment(event) {
        const applicantId = event.target.dataset.applicantId;
        
        const applicant = this.findApplicantById(applicantId);
        if (!applicant) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Applicant record not found',
                variant: 'error'
            }));
            return;
        }
        
        // Confirm the cancellation
        const confirmMessage = `Cancel unit assignment for ${applicant.applicantName}? This will return them to the group property association.`;
        
        if (!confirm(confirmMessage)) {
            return;
        }
        
        try {
            // Call Apex method to cancel the assignment
            const result = await cancelUnitAssignment({
                outreachTrackingId: applicantId
            });

            // Show success message
            this.dispatchEvent(new ShowToastEvent({
                title: 'Assignment Cancelled',
                message: result,
                variant: 'success'
            }));

            // Dispatch refresh event to ensure all data is up to date
            this.dispatchEvent(new RefreshEvent());

        } catch (error) {
            console.error('Error in handleCancelUnitAssignment:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Cancellation Failed',
                message: 'Failed to cancel unit assignment: ' + (error.body?.message || error.message),
                variant: 'error'
            }));
        }
    }
    
    /**
     * Helper method to find applicant by ID across all property groups
     */
    findApplicantById(applicantId) {
        for (const propertyGroup of this.propertyGroups) {
            const found = propertyGroup.applicants.find(applicant => applicant.id === applicantId);
            if (found) {
                return found;
            }
        }
        return null;
    }

    /**
     * Handle confirm removal button click
     * Confirms removal of an applicant with "Removed" status and moves them to the removal report
     */
    async handleConfirmRemoval(event) {
        const applicantId = event.target.dataset.applicantId;

        // Find the applicant record
        const applicant = this.findApplicantById(applicantId);
        if (!applicant) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Applicant record not found',
                variant: 'error'
            }));
            return;
        }

        // Validate applicant has "Removed" status
        if (applicant.status !== 'Removed') {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Invalid Status',
                message: 'Only applicants with "Removed" status can be confirmed for removal.',
                variant: 'warning'
            }));
            return;
        }

        // Confirm the removal action with the user
        const confirmMessage = `Are you sure you want to move ${applicant.applicantName} to the removal report? This will remove them from the tracker.`;

        if (!confirm(confirmMessage)) {
            return;
        }

        try {
            // Call Apex method to confirm the removal
            const result = await confirmApplicantRemoval({
                outreachTrackingId: applicantId
            });

            // Show success message
            this.dispatchEvent(new ShowToastEvent({
                title: 'Removal Confirmed',
                message: result,
                variant: 'success'
            }));

            // Dispatch refresh event to ensure all data is up to date
            this.dispatchEvent(new RefreshEvent());

        } catch (error) {
            console.error('Error in handleConfirmRemoval:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Confirmation Failed',
                message: 'Failed to confirm removal: ' + (error.body?.message || error.message),
                variant: 'error'
            }));
        }
    }

    // Sorting Methods

    /**
     * Handle sorting when a table header is clicked
     */
    handleSort(event) {
        const fieldName = event.currentTarget.dataset.fieldname;
        const propertyId = event.currentTarget.dataset.propertyId;

        if (!fieldName || !propertyId) {
            console.warn('Missing fieldname or propertyId:', { fieldName, propertyId });
            return;
        }

        // Toggle sort direction if same field, otherwise set to ascending
        if (this.sortField === fieldName) {
            this.sortDirection = this.sortDirection === 'asc' ? 'desc' : 'asc';
        } else {
            this.sortField = fieldName;
            this.sortDirection = 'asc';
        }

        this.sortData(propertyId, fieldName, this.sortDirection);
    }

    /**
     * Sort the data for a specific property
     */
    sortData(propertyId, fieldName, direction) {
        console.log(`Sorting ${fieldName} in ${direction} order for property ${propertyId}`);

        const propertyIndex = this.propertyGroups.findIndex(prop => prop.id === propertyId);
        if (propertyIndex === -1) return;

        // Create a new array to trigger reactivity
        const updatedPropertyGroups = [...this.propertyGroups];
        const applicants = [...updatedPropertyGroups[propertyIndex].applicants];

        // Sort the applicants
        applicants.sort((a, b) => {
            const aVal = this.getFieldValue(a, fieldName);
            const bVal = this.getFieldValue(b, fieldName);

            if (fieldName === 'priority') {
                console.log(`Comparing priorities: ${aVal} (${typeof aVal}) vs ${bVal} (${typeof bVal})`);
            }

            let result = 0;

            // Handle different data types
            if (this.isDateField(fieldName)) {
                result = this.compareDates(aVal, bVal);
            } else if (this.isNumericField(fieldName)) {
                result = this.compareNumbers(aVal, bVal);
            } else {
                result = this.compareStrings(aVal, bVal);
            }

            if (fieldName === 'priority') {
                console.log(`Comparison result: ${result}`);
            }

            return direction === 'desc' ? -result : result;
        });

        updatedPropertyGroups[propertyIndex].applicants = applicants;
        this.propertyGroups = updatedPropertyGroups;
    }

    /**
     * Get field value from applicant object
     */
    getFieldValue(applicant, fieldName) {
        const fieldMap = {
            'unit': applicant.unit || '',
            'priority': applicant.priority || '',
            'applicantName': applicant.applicantName || '',
            'peopleInHousehold': applicant.peopleInHousehold || 0,
            'dateCGPHAdded': applicant.dateCGPHAdded || '',
            'dateMarkedPrimary': applicant.dateMarkedPrimary || '',
            'approvalDenial': applicant.approvalDenial || '',
            'approveDenyDate': applicant.approveDenyDate || '',
            // 'approvedForFullReview': applicant.approvedForFullReview || false,
            'readyDate': applicant.readyDate || '',
            'fullReviewCGPHBegan': applicant.fullReviewCGPHBegan || '',
            'cgphDetermination': applicant.cgphDetermination || '',
            'dateOfDetermination': applicant.dateOfDetermination || ''
        };

        return fieldMap[fieldName] !== undefined ? fieldMap[fieldName] : '';
    }

    /**
     * Check if field is a date field
     */
    isDateField(fieldName) {
        return [
            'dateCGPHAdded',
            'dateMarkedPrimary',
            'approveDenyDate',
            'readyDate',
            'fullReviewCGPHBegan',
            'dateOfDetermination'
        ].includes(fieldName);
    }

    /**
     * Check if field is numeric
     */
    isNumericField(fieldName) {
        return ['peopleInHousehold', 'priority'].includes(fieldName);
    }

    /**
     * Compare dates
     */
    compareDates(a, b) {
        if (!a && !b) return 0;
        if (!a) return -1;
        if (!b) return 1;

        const dateA = new Date(a);
        const dateB = new Date(b);
        return dateA.getTime() - dateB.getTime();
    }

    /**
     * Compare numbers
     */
    compareNumbers(a, b) {
        const numA = parseFloat(a) || 0;
        const numB = parseFloat(b) || 0;
        return numA - numB;
    }

    /**
     * Compare strings (case insensitive)
     */
    compareStrings(a, b) {
        const strA = String(a || '').toLowerCase();
        const strB = String(b || '').toLowerCase();
        return strA.localeCompare(strB);
    }


    // Computed properties for each sortable field's icon visibility and direction

    // Unit field
    get isUnitSorted() { return this.sortField === 'unit'; }
    get unitSortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // Priority field
    get isPrioritySorted() { return this.sortField === 'priority'; }
    get prioritySortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // Applicant Name field
    get isApplicantNameSorted() { return this.sortField === 'applicantName'; }
    get applicantNameSortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // People in Household field
    get isPeopleInHouseholdSorted() { return this.sortField === 'peopleInHousehold'; }
    get peopleInHouseholdSortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // Date CGPH Added field
    get isDateCGPHAddedSorted() { return this.sortField === 'dateCGPHAdded'; }
    get dateCGPHAddedSortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // Date Marked Primary field
    get isDateMarkedPrimarySorted() { return this.sortField === 'dateMarkedPrimary'; }
    get dateMarkedPrimarySortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // Approval Denial field
    get isApprovalDenialSorted() { return this.sortField === 'approvalDenial'; }
    get approvalDenialSortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // Approve Deny Date field
    get isApproveDenyDateSorted() { return this.sortField === 'approveDenyDate'; }
    get approveDenyDateSortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // Approved for Full Review field
    // get isApprovedForFullReviewSorted() { return this.sortField === 'approvedForFullReview'; }
    // get approvedForFullReviewSortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // Ready Date field
    get isReadyDateSorted() { return this.sortField === 'readyDate'; }
    get readyDateSortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // Full Review CGPH Began field
    get isFullReviewCGPHBeganSorted() { return this.sortField === 'fullReviewCGPHBegan'; }
    get fullReviewCGPHBeganSortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // CGPH Determination field
    get isCgphDeterminationSorted() { return this.sortField === 'cgphDetermination'; }
    get cgphDeterminationSortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    // Date of Determination field
    get isDateOfDeterminationSorted() { return this.sortField === 'dateOfDetermination'; }
    get dateOfDeterminationSortIcon() { return this.sortDirection === 'asc' ? 'utility:arrowup' : 'utility:arrowdown'; }

    /**
     * Handle navigation to Outreach Tracking record page in a new tab
     */
    handleNavigateToRecord(event) {
        const recordId = event.currentTarget.dataset.recordId;

        if (!recordId) {
            console.error('No record ID provided for navigation');
            return;
        }

        // Generate the URL and open in a new tab
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: 'Outreach_Tracking__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
    }

    /**
     * Handle navigation to Service File record page in a new tab
     */
    handleNavigateToServiceFile(event) {
        const serviceFileId = event.currentTarget.dataset.serviceFileId;

        if (!serviceFileId) {
            console.error('No Service File ID provided for navigation');
            return;
        }

        // Generate the URL and open in a new tab
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__recordPage',
            attributes: {
                recordId: serviceFileId,
                objectApiName: 'Service_File__c',
                actionName: 'view'
            }
        }).then(url => {
            window.open(url, '_blank');
        });
    }

    /**
     * Handle navigation to Report with Pre-Applicant and Property filters
     */
    handleNavigateToReport(event) {
        const preApplicantId = event.currentTarget.dataset.preApplicantId;
        const propertyId = event.currentTarget.dataset.propertyId;

        if (!preApplicantId || !propertyId) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: 'Pre-Applicant ID or Property ID not available',
                variant: 'error'
            }));
            return;
        }

        // Dynamically construct the report URL based on current org
        const currentDomain = window.location.hostname;
        let lightningDomain;

        if (currentDomain.includes('.sandbox.lightning.force.com')) {
            // Sandbox: keep as-is
            lightningDomain = currentDomain;
        } else if (currentDomain.includes('.lightning.force.com')) {
            // Production: keep as-is
            lightningDomain = currentDomain;
        } else if (currentDomain.includes('.sandbox.my.salesforce.com')) {
            // Sandbox My Domain: convert to Lightning
            const domainPrefix = currentDomain.split('.sandbox.my.salesforce.com')[0];
            lightningDomain = `${domainPrefix}.sandbox.lightning.force.com`;
        } else if (currentDomain.includes('.my.salesforce.com')) {
            // Production My Domain: convert to Lightning
            const domainPrefix = currentDomain.split('.my.salesforce.com')[0];
            lightningDomain = `${domainPrefix}.lightning.force.com`;
        } else if (currentDomain.includes('--c.sandbox.vf.force.com')) {
            // Sandbox VF: convert to Lightning
            const domainPrefix = currentDomain.replace('--c.sandbox.vf.force.com', '');
            lightningDomain = `${domainPrefix}.sandbox.lightning.force.com`;
        } else if (currentDomain.includes('--c.vf.force.com')) {
            // Production VF: convert to Lightning
            const domainPrefix = currentDomain.replace('--c.vf.force.com', '');
            lightningDomain = `${domainPrefix}.lightning.force.com`;
        } else {
            // Fallback to production
            lightningDomain = 'cgph.lightning.force.com';
            console.warn('Could not determine Lightning domain, using production URL');
        }

        const reportUrl = `https://${lightningDomain}/lightning/r/Report/00OUq000004iXM9MAM/view?queryScope=userFolders&fv0=${preApplicantId}&fv1=${propertyId}`;
        console.log('Opening report URL:', reportUrl);

        // Open in new window/tab
        window.open(reportUrl, '_blank');
    }

    /**
     * Notes Modal Methods
     */

    /**
     * Truncate notes to specified character limit
     */
    // truncateNotes(notes, maxLength) {
    //     if (!notes) return '';
    //     if (notes.length <= maxLength) return notes;
    //     return notes.substring(0, maxLength);
    // }

    /**
     * Check if notes exceed the character limit
     */
    // hasMoreNotes(notes, maxLength) {
    //     if (!notes) return false;
    //     return notes.length > maxLength;
    // }

    /**
     * Handle click on notes cell to open modal
     */
    // handleNotesClick(event) {
    //     const applicantId = event.currentTarget.dataset.applicantId;
    //     const applicantName = event.currentTarget.dataset.applicantName;

    //     if (!applicantId) {
    //         console.error('No applicant ID provided for notes modal');
    //         return;
    //     }

        // Find the applicant record
        // const applicant = this.findApplicantById(applicantId);
        // if (!applicant) {
        //     console.error('Applicant not found:', applicantId);
        //     return;
        // }

        // Set modal state
    //     this.selectedApplicantId = applicantId;
    //     this.selectedApplicantName = applicantName || 'Applicant';
    //     this.selectedNotes = applicant.notes || '';
    //     this.isNotesModalOpen = true;
    // }

    /**
     * Close notes modal
     */
    // handleNotesModalClose() {
    //     this.isNotesModalOpen = false;
    //     this.selectedApplicantId = '';
    //     this.selectedApplicantName = '';
    //     this.selectedNotes = '';
    // }
}