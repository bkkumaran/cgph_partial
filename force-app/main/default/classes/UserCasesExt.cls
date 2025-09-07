public class UserCasesExt {
    public String userID {get; set;}
    public List<case> listCases {get; set;}
    public String catPP {get; set;} /* 1 Prioritized Project */
    public String catAI {get; set;} /* Action item */
    public String catCP {get; set;} /* Contracts / Proposals */
    public String catNA {get; set;} /* Not Applicable */
    public String catND {get; set;} /* Needs Decision */
    public String catOR {get; set;} /* On Radar */
    public String catUE {get; set;} /* Upcoming Event */
    public String catXX {get; set;} /* none */
    public String catOT {get; set;} /* Other */
    
    public UserCasesExt(ApexPages.StandardController controller) {
    userID = controller.getId();
    
    listCases = [
        Select id, Subject, Priority_Num__c, Priority_Calc__c, Agenda_Category__c, Case_Category__c, Planned_Start_Date__c, Planned_End_Date__c, CreatedDate, Status, Flag__c
        FROM Case
        WHERE OwnerId = :userID AND Status='New'
        ORDER BY Agenda_Category__c ASC, Priority_Calc__c ASC, Subject ASC
        ];
        
    catPP = ApexPages.currentPage().getParameters().get('pp');
    IF (catPP == NULL) { catPP = '0'; }
    catAI = ApexPages.currentPage().getParameters().get('ai');
    IF (catAI == NULL) { catAI = '0'; }
    catCP = ApexPages.currentPage().getParameters().get('cp');
    IF (catCP == NULL) { catCP = '0'; }
    catNA = ApexPages.currentPage().getParameters().get('na');
    IF (catNA == NULL) { catNA = '0'; }
    catND = ApexPages.currentPage().getParameters().get('nd');
    IF (catND == NULL) { catND = '0'; }
    catOR = ApexPages.currentPage().getParameters().get('or');
    IF (catOR == NULL) { catOR = '0'; }
    catOT = ApexPages.currentPage().getParameters().get('ot');
    IF (catOT == NULL) { catOT = '0'; }
    catUE = ApexPages.currentPage().getParameters().get('ue');
    IF (catUE == NULL) { catUE = '0'; }
    catXX = ApexPages.currentPage().getParameters().get('xx');
    IF (catXX == NULL) { catXX = '0'; }
        
    
    }
    
    public pageReference save(){
        update listCases;
        PageReference pg = new PageReference(
            '/apex/UserCases?id='+userID+
            '&pp='+catPP+
            '&ai='+catAI+
            '&cp='+catCP+
            '&na='+catNA+
            '&nd='+catND+
            '&or='+catOR+
            '&ot='+catOT+
            '&ue='+catUE+
            '&xx='+catXX+
            '&core.apexpages.devmode.url=0'
            );
        pg.setRedirect(true);
        return pg;
        
    } 
    public pageReference cancel(){
        PageReference pg = new PageReference(
            '/apex/UserCases?id='+userID+
            '&pp='+catPP+
            '&ai='+catAI+
            '&cp='+catCP+
            '&na='+catNA+
            '&nd='+catND+
            '&or='+catOR+
            '&ot='+catOT+
            '&ue='+catUE+
            '&xx='+catXX+
            '&core.apexpages.devmode.url=0'
            );
        pg.setRedirect(true);
        return pg;
        
    } 

}