public class OutreachListAAcont {
    Public List<HOMETracker__Property__c> propList {get; set;}
    Public String result {get; set;}
    public Map<Integer,List<String>> mapProps {get; set;}
    
    
    public OutreachListAAcont(){
        //initialize variables
        Integer mapKeyInt = 0;
        mapProps = new Map<Integer,List<String>>();
        Integer appListTotalSize = 0;
        Integer appListInvSize = 0;
        Integer appListSubSize= 0;
        String propId = '';
        String propType = '';
        String appsAllIDs = '';
        String appsInvIDs = '';
        String appsSubIDs = '';
        String groupCheck = '';
        Integer unitCount = 0;
        String result = '';

        //ALL APPLICANTS
        //get list of all curent applicants associated with properties 
            List<Outreach_Tracking__c> appsListTotal = [
                SELECT id, Service_File__r.HOMEtracker__Property__r.id
                FROM Outreach_Tracking__c
                WHERE Include_On_Tracker__c = true
                ORDER BY Service_File__r.Id ASC
                ];
        //ALL APPLICANTS
        //add ids of all current applicants to string
        for(Outreach_Tracking__c a : appsListTotal ){
           appsAllIDs = appsAllIDs + a.Service_File__r.HOMEtracker__Property__r.id + ', ';
           }
        
        // APPLICANTS INVITED TO SUBMIT
        List<Outreach_Tracking__c> appsListInv = [
                SELECT id, Service_File__r.HOMEtracker__Property__r.id
                FROM Outreach_Tracking__c
                WHERE Include_On_Tracker__c = true AND
                    Service_File__r.Application_Workflow_Status__c = 'Invited - Waiting to Submit'
                ORDER BY Service_File__r.Id ASC
                ];
        // APPLICANTS INVITED TO SUBMIT
        //add ids of all current applicants to string
        for(Outreach_Tracking__c b : appsListInv ){
           appsInvIDs = appsInvIDs + b.Service_File__r.HOMEtracker__Property__r.id + ', ';
           }
        
        //GET ALL PROPERTIES
        propList = [
            SELECT
                Id,
                Name,
                Development_Address__r.Name,
                Development_Address__r.Id,
                Development_Address__r.Primary_Case_manager__r.name,
                RecordType.Name,
                Group_Property__c,
                Group_Property_Parent__c,
                Group_Property_Parent__r.Id,
                Current_Outreach_Timeline__r.Next_Step__c,
                Development_Address__r.Outreach_Applicant_Strategy__c,
                Primary_Outreach_Coordintor__c,
                Primary_Outreach_Coordintor__r.Name
            FROM HOMETracker__Property__c
            WHERE
            Active_Property__c = true
            AND Current_Outreach_Timeline__r.Next_Step__c != 'DONE'
            ORDER BY Development_Address__r.Primary_Case_manager__r.name asc, Development_Address__r.Name ASC, Inventory_Sort__c ASC
            ];
            
        //get all group property parent ids
        for(HOMEtracker__Property__c g : propList){
            IF(g.Group_Property__c == true || g.Group_Property_Parent__c == NULL){
            } ELSE {
            groupCheck = groupcheck + g.Group_Property_Parent__r.Id + ', ';
            }
        }
         
       
        //loop over all propeties
        for(HOMEtracker__Property__c x : propList){
            mapKeyInt = mapKeyInt + 1;
            propType = '';
            unitCount=1;
            result='';
            
            //Determine correct property ID (group property = use group property Id, unit in group property = use group property Id, single unit = use unit Id
            // propType: 0 = group property, 1 = part of group, 2 = single
            IF(x.Group_Property__c == true){
                propType = 'Group Property';
                propId = x.id;
            } ELSE {
            IF(x.Group_Property_Parent__c == NULL){
                propType = 'Single Unit';
                propId = x.id;
            } ELSE {
                propType = 'Part of Group';
                propId = x.Group_Property_Parent__r.Id;
            }
            }
           
            //ALL APPLICANTS
            //count number of times ID is found in list of IDs
            appListTotalSize = 0;
            appListTotalSize = appsAllIDs.CountMatches(propId.left(15));
            
            // APPLICANTS INVITED TO SUBMIT
            // count number of times ID is found in list of IDs
            appListInvSize = 0;
            appListInvSize = appsInvIDs.CountMatches(propId.left(15));
            
            // APPLICANTS WHO SUBMITTED
            // Total applicants minus Applicants invited only
            appListSubSize = appListTotalSize-appListInvSize;
            
            // number of child group units
            IF(x.Group_Property__c == true){
            unitCount = groupCheck.CountMatches(propId.left(15));
            } ELSE {
            unitCount = 1;
            }
            
            //determine if additional applicants are needed
            result = determinationGet(unitCount, appListTotalSize, x.Development_Address__r.Outreach_Applicant_Strategy__c);
            
            //Add columns of text to the chart. Add another s# for each piece of data in the method below (AddStringToMap)
            mapProps.put(mapKeyInt,AddStringToMap(
                /*[0]*/ x.Development_Address__r.Name,  
                /*[1]*/ x.Development_Address__r.Id,    
                /*[2]*/ x.Name,                         
                /*[3]*/ x.id,
                /*[4]*/ x.RecordType.Name,
                /*[5]*/ propType,
                /*[6]*/ String.valueOf(appListTotalSize),
                /*[7]*/ String.valueOf(appListInvSize),
                /*[8]*/ String.valueOf(appListSubSize),
                /*[9]*/ String.valueOf(unitCount),
                /*[10]*/ result,
                /*[11]*/ x.Development_Address__r.Outreach_Applicant_Strategy__c,
                /*[12]*/ x.Development_Address__r.Primary_Case_manager__r.Name
                
                ));
            }

    }

    Public String determinationGet(Integer u, Integer a, String s){  //u = units a = total applicants s = strategy
        String r = '';
        
        IF (u == 0) { r = 'No Units'; } ELSE {
        IF (a == 0) { r = 'No Applicants'; } ELSE {
        IF (s == 'Aggressive') {
            switch on u {
                when 1 { if (a < 10) { r = 'More Needed'; } ELSE { r = 'OK'; } }
                when 2 { if (a < 12) { r = 'More Needed'; } ELSE { r = 'OK'; } }
                when 3 { if (a < 15) { r = 'More Needed'; } ELSE { r = 'OK'; } }
                when 4 { if (a < 20) { r = 'More Needed'; } ELSE { r = 'OK'; } }
                when 5 { if (a < 20) { r = 'More Needed'; } ELSE { r = 'OK'; } }
                when 6 { if (a < 20) { r = 'More Needed'; } ELSE { r = 'OK'; } }
                when 7 { if (a < 25) { r = 'More Needed'; } ELSE { r = 'OK'; } }
                when 8 { if (a < 25) { r = 'More Needed'; } ELSE { r = 'OK'; } }
                when 9 { if (a < 25) { r = 'More Needed'; } ELSE { r = 'OK'; } }
                when 10 { if (a < 25) { r = 'More Needed'; } ELSE { r = 'OK'; } }
                when else { if (a < 30) { r = 'More Needed'; } ELSE { r = 'OK'; } }
                }
            } ELSE {
            IF (s == 'Minimal') {
            IF( a < u ){r = 'More Needed';} ELSE {r = 'OK';}
            } ELSE {
            IF( (a < (u * 3)) && (a < 30)){r = 'More Needed';} ELSE {r = 'OK';}
            }
            }
            }    
        }    
        return r;
    }
    Public List<String> AddStringToMap(
            String s0,
            String s1,
            String s2,
            String s3,
            String s4,
            String s5,
            String s6,
            String s7,
            String s8,
            String s9,
            String s10,
            String s11,
            String s12
            ){
        IF(s0 == NULL){s0 = '-';}
        IF(s1 == NULL){s1 = '-';}
        IF(s2 == NULL){s2 = '-';}
        IF(s3 == NULL){s3 = '-';}
        IF(s4 == NULL){s4 = '-';}
        IF(s5 == NULL){s5 = '-';}
        IF(s6 == NULL){s6 = '-';}
        IF(s7 == NULL){s7 = '-';}
        IF(s8 == NULL){s8 = '-';}
        IF(s9 == NULL){s9 = '-';}
        IF(s10 == NULL){s10 = '-';}
        IF(s11 == NULL){s11 = 'Standard';}
        IF(s12 == NULL){s12 = '-';}
        List<String> rString = new List<String>{s0,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12};
        return rString;
        }

}