public class ProposalTrackExt {

public List<Opportunity> OverList {get; set;}
public List<Opportunity> OppList {get; set;}
public List<Opportunity> RenList {get; set;}
public Integer OppCount {get; set;}
public Integer RenCount {get; set;}
public Integer OverCount {get; set;}
Public Integer OppTotCount {get; set;}
    
    public ProposalTrackExt(ApexPages.StandardController controller) {

    OverList = [SELECT Id, Name, Next_Follow_Up_Date__c, Next_Step_Staff__c, Completion_Date__c, Completion_Deadline__c, RFP_Docs_Signed__c, Bid_Due_Time__c, RFP_Docs__c, CloseDate, RFP_Bid__c, Pricing_Notes__c, Days_Until_Close_Date__c, Proposal_Draft__c, Pricing_Finalized__c, NextStep, Type, Primary_CGPH_Staffer_Involved__c FROM Opportunity WHERE StageName = 'Proposal In Progress' AND CloseDate < TODAY ORDER BY CloseDate ASC];
    OverCount = OverList.size();
    
    OppList = [SELECT Id, Name, Next_Step_Staff__c, Next_Follow_Up_Date__c, Completion_Date__c, Completion_Deadline__c, RFP_Docs_Signed__c, Bid_Due_Time__c, RFP_Docs__c, CloseDate, RFP_Bid__c, Pricing_Notes__c, Days_Until_Close_Date__c, Proposal_Draft__c, Pricing_Finalized__c, NextStep, Type, Primary_CGPH_Staffer_Involved__c FROM Opportunity WHERE StageName = 'Proposal In Progress' AND CloseDate >= TODAY ORDER BY CloseDate ASC];
    OppCount = OppList.size();

    RenList = [SELECT Id, Name, Next_Step_Staff__c, Next_Follow_Up_Date__c, Completion_Date__c, Completion_Deadline__c, RFP_Docs_Signed__c, Bid_Due_Time__c, RFP_Docs__c, CloseDate, RFP_Bid__c, Pricing_Notes__c, Days_Until_Close_Date__c, Proposal_Draft__c, Pricing_Finalized__c, NextStep, Type, Primary_CGPH_Staffer_Involved__c FROM Opportunity WHERE StageName = 'Renewal in Advance' ORDER BY Name ASC];
    RenCount = RenList.size();

    OppTotCount = OppCount + OverCount;
    }
    
       public PageReference save() {
       update OppList;
      return ApexPages.CurrentPage();
    }

       public PageReference saveR() {
       update RenList;
      return ApexPages.CurrentPage();
    }

}