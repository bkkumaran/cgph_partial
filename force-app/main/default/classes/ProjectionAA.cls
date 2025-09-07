public class ProjectionAA {
    Public String Month1 {get; set;}
    Public String Month2 {get; set;}
    Public String Month3 {get; set;}
    Public String Month4 {get; set;}
    Public String Month5 {get; set;}
    Public String Month6 {get; set;}
    
    public Integer Intro1 {get; set;}
    public Integer Intro2 {get; set;}
    public Integer Intro3 {get; set;}
    public Integer Intro4 {get; set;}
    public Integer Intro5 {get; set;}
    public Integer Intro6 {get; set;}

    public Integer Outreach1 {get; set;}
    public Integer Outreach2 {get; set;}
    public Integer Outreach3 {get; set;}
    public Integer Outreach4 {get; set;}
    public Integer Outreach5 {get; set;}
    public Integer Outreach6 {get; set;}
    
    public Integer FullApps1 {get; set;}
    public Integer FullApps2 {get; set;}
    public Integer FullApps3 {get; set;}
    public Integer FullApps4 {get; set;}
    public Integer FullApps5 {get; set;}
    public Integer FullApps6 {get; set;}

    public Integer Tracker1 {get; set;}
    public Integer Tracker2 {get; set;}
    public Integer Tracker3 {get; set;}
    public Integer Tracker4 {get; set;}
    public Integer Tracker5 {get; set;}
    public Integer Tracker6 {get; set;}

    public Integer Ready1 {get; set;}
    public Integer Ready2 {get; set;}
    public Integer Ready3 {get; set;}
    public Integer Ready4 {get; set;}
    public Integer Ready5 {get; set;}
    public Integer Ready6 {get; set;}
    
    public Integer Cert1 {get; set;}
    public Integer Cert2 {get; set;}
    public Integer Cert3 {get; set;}
    public Integer Cert4 {get; set;}
    public Integer Cert5 {get; set;}
    public Integer Cert6 {get; set;}
    
    public ProjectionAA(){
        Date today = date.today();
        Integer TodayMonth = today.month();
        Integer TodayYear = today.year();
    
        Date Month1start = date.newInstance(today.year(), today.month(), 1);
        Date Month2start = Month1Start.addMonths(1);
        Date Month3start = Month2Start.addMonths(1);
        Date Month4start = Month3Start.addMonths(1);
        Date Month5start = Month4Start.addMonths(1);
        Date Month6start = Month5Start.addMonths(1);
        Date Month7start = Month6Start.addMonths(1);
        Date Month1end = Month2start.addDays(-1);
        Date Month2end = Month3start.addDays(-1);
        Date Month3end = Month4start.addDays(-1);
        Date Month4end = Month5start.addDays(-1);
        Date Month5end = Month6start.addDays(-1);
        Date Month6end = Month7start.addDays(-1);
        
        Month1 = monthText(Month1start.month())+(Month1start.year()-2000);
        Month2 = monthText(Month2start.month())+(Month2start.year()-2000);
        Month3 = monthText(Month3start.month())+(Month3start.year()-2000);
        Month4 = monthText(Month4start.month())+(Month4start.year()-2000);
        Month5 = monthText(Month5start.month())+(Month5start.year()-2000);
        Month6 = monthText(Month6start.month())+(Month6start.year()-2000);
        
        Intro1 = getIntroCount(Month1start,Month1end);
        Intro2 = getIntroCount(Month2start,Month2end);
        Intro3 = getIntroCount(Month3start,Month3end);
        Intro4 = getIntroCount(Month4start,Month4end);
        Intro5 = getIntroCount(Month5start,Month5end);
        Intro6 = getIntroCount(Month6start,Month6end);
        
        Outreach1 = getOutreachCount(Month1start,Month1end);
        Outreach2 = getOutreachCount(Month2start,Month2end);
        Outreach3 = getOutreachCount(Month3start,Month3end);
        Outreach4 = getOutreachCount(Month4start,Month4end);
        Outreach5 = getOutreachCount(Month5start,Month5end);
        Outreach6 = getOutreachCount(Month6start,Month6end);
        
        FullApps1 = getFullAppsCount(Month1start,Month1end);
        FullApps2 = getFullAppsCount(Month2start,Month2end);
        FullApps3 = getFullAppsCount(Month3start,Month3end);
        FullApps4 = getFullAppsCount(Month4start,Month4end);
        FullApps5 = getFullAppsCount(Month5start,Month5end);
        FullApps6 = getFullAppsCount(Month6start,Month6end);
        
        Tracker1 = getTrackerCount(Month1start,Month1end);
        Tracker2 = getTrackerCount(Month2start,Month2end);
        Tracker3 = getTrackerCount(Month3start,Month3end);
        Tracker4 = getTrackerCount(Month4start,Month4end);
        Tracker5 = getTrackerCount(Month5start,Month5end);
        Tracker6 = getTrackerCount(Month6start,Month6end);
        
        Ready1 = getReadyCount(Month1start,Month1end);
        Ready2 = getReadyCount(Month2start,Month2end);
        Ready3 = getReadyCount(Month3start,Month3end);
        Ready4 = getReadyCount(Month4start,Month4end);
        Ready5 = getReadyCount(Month5start,Month5end);
        Ready6 = getReadyCount(Month6start,Month6end);
        
        Cert1 = getCertCount(Month1start,Month1end);
        Cert2 = getCertCount(Month2start,Month2end);
        Cert3 = getCertCount(Month3start,Month3end);
        Cert4 = getCertCount(Month4start,Month4end);
        Cert5 = getCertCount(Month5start,Month5end);
        Cert6 = getCertCount(Month6start,Month6end);
        

    }

//INTRO CALL DATE
    Integer getIntroCount(Date s, Date e){
        List <Development_Checklist__c> xList = [
            Select ID
            from Development_Checklist__c
            WHERE Target_Intro_Call_Date__c >= :s AND Target_Intro_Call_Date__c <= :e ];
        Integer count = xList.size();
        return count;
        }
        
//OUTREACH BEGINS
    Integer getOutreachCount(Date s, Date e){
        List <Outreach_Timeline__c> xList = [
            Select ID
            from Outreach_Timeline__c
            WHERE Outreach_Start_Date__c >= :s AND Outreach_Start_Date__c <= :e ];
        Integer count = xList.size();
        return count;
        }

//FULL APPS TO SEND
    Integer getFullAppsCount(Date s, Date e){
        List <Outreach_Timeline__c> xList = [
            Select ID
            from Outreach_Timeline__c
            WHERE Full_Apps_Sent_Date__c >= :s AND Full_Apps_Sent_Date__c <= :e ];
        Integer count = xList.size();
        return count;
        }

//APPLICANTS TO TRACKER
    Integer getTrackerCount(Date s, Date e){
        List <Outreach_Timeline__c> xList = [
            Select ID
            from Outreach_Timeline__c
            WHERE Applicants_To_Tracker_Date__c >= :s AND Applicants_To_Tracker_Date__c <= :e ];
        Integer count = xList.size();
        return count;
        }

//READY FOR CERTIFICATION
    Integer getReadyCount(Date s, Date e){
        List <Outreach_Timeline__c> xList = [
            Select ID
            from Outreach_Timeline__c
            WHERE LL_Dev_Approval_Date__c >= :s AND LL_Dev_Approval_Date__c <= :e ];
        Integer count = xList.size();
        return count;
        }

//CERTIFICATIONS
    Integer getCertCount(Date s, Date e){
        List <Outreach_Timeline__c> xList = [
            Select ID
            from Outreach_Timeline__c
            WHERE Certification_Date__c >= :s AND Certification_Date__c <= :e ];
        Integer count = xList.size();
        return count;
        }
        
                        
//convert numerical month into text month    
    String monthText(Integer m){
        String mText = '';
    
        switch on m {
            when 1 {  
            mText = 'JAN';
            }   
            when 2 {
            mText = 'FEB';
            }
            when 3 {
            mText = 'MAR';
            }
            when 4 {
            mText = 'APR';
            }
            when 5 {
            mText = 'MAY';
            }
            when 6 {
            mText = 'JUN';
            }
            when 7 {
            mText = 'JUL';
            }
            when 8 {
            mText = 'AUG';
            }
            when 9 {
            mText = 'SEP';
            }
            when 10 {
            mText = 'OCT';
            }
            when 11 {
            mText = 'NOV';
            }
            when 12 {
            mText = 'DEC';
            }
            when else {
            mText='XXX';
            }
        }
    
    return mText;
    
    }

}