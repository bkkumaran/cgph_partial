public with sharing class MRprojExt {
    Public List<Monitoring_Project_Unit__c> Projects {get; set;}
    Public String muniId {get; set;}
    Public String xx {get; set;}
    Public String yy {get; set;}
    Public Integer ProjectCount {get; set;}

    public MRprojExt(ApexPages.StandardController controller) {
    muniId = apexpages.currentpage().getparameters().get('id');
    xx = apexpages.currentpage().getparameters().get('xx');
    yy = apexpages.currentpage().getparameters().get('yy');
    Projects = [SELECT
        Name,
        Id,
        MR_Development__r.Id,
        MR_Development__r.Monitoring_Notes__c,
        MR_Muni_Name_Calc__c,
        MR_County__c,
        MR_Project_Type__c,
        MR_Block_Lot_Street__c,
        MR_Project_Status__c,
        MR_Controls_Date__c,
        MR_Length_of_Controls__c,
        MR_Length_of_Controls_Format__c,
        MR_Length_of_Controls_Text__c,
        MR_Administrative_Agent_Info__c,
        MR_Contribution__c,
        MR_Unit_Type__c,
        MR_Total_Affordable_Units__c,
        MR_Unit_Notes__c,
        MR_Eff_Very_Low__c,
        MR_1_Br_Very_Low__c,
        MR_2_Br_Very_Low__c,
        MR_3_Br_Very_Low__c,
        MR_4_Br_Very_Low__c,
        MR_Eff_Low__c,
        MR_1_Br_Low__c,
        MR_2_Br_Low__c,
        MR_3_Br_Low__c,
        MR_4_BR_Low__c,
        MR_Eff_Moderate__c,
        MR_1_Br_Moderate__c,
        MR_2_Br_Moderate__c,
        MR_3_Br_Moderate__c,
        MR_4_BR_Moderate__c,
        MR_Monitoring_Notes__c,
        MR_Project_Number__c
        FROM
        Monitoring_Project_Unit__c
        WHERE
        MR_Municipality__r.Id = :muniId
        ORDER BY
        MR_Project_Number__c
        ASC];
    ProjectCount = Projects.size();

    }

}