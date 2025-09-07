public with sharing class TrainAAExt {
    public String modId {get; set;}
    public String e {get; set;}
    public List<Article_Link__c> listA {get; set;}
    public List<Article_Link__c> listB {get; set;}
    public List<Article_Link__c> listC {get; set;}
    public List<Article_Link__c> listD {get; set;}
    public List<Article_Link__c> listE {get; set;}
    public List<Article_Link__c> listF {get; set;}
    public List<Article_Link__c> listG {get; set;}
    public List<Article_Link__c> listH {get; set;}
    public List<Article_Link__c> listI {get; set;}
    public List<Article_Link__c> listJ {get; set;}
    public List<Article_Link__c> listK {get; set;}
    public List<Article_Link__c> listL {get; set;}
    public List<Article_Link__c> listM {get; set;}
    public List<Article_Link__c> listN {get; set;}
    public List<Article_Link__c> listO {get; set;}
    public List<Article_Link__c> listP {get; set;}
    public Integer sizeA {get; set;}
    public Integer sizeB {get; set;}
    public Integer sizeC {get; set;}
    public Integer sizeD {get; set;}
    public Integer sizeE {get; set;}
    public Integer sizeF {get; set;}
    public Integer sizeG {get; set;}
    public Integer sizeH {get; set;}
    public Integer sizeI {get; set;}
    public Integer sizeJ {get; set;}
    public Integer sizeK {get; set;}
    public Integer sizeL {get; set;}
    public Integer sizeM {get; set;}
    public Integer sizeN {get; set;}
    public Integer sizeO {get; set;}
    public Integer sizeP {get; set;}
    
    Public String showYN {get; set;}
  
    public TrainAAExt(ApexPages.StandardController controller) {
        modId = apexpages.currentpage().getparameters().get('id');
        e = apexpages.currentpage().getparameters().get('e');
        showYN = 'N';
        listA = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 1 ORDER BY Order_Num_Calc__c ASC];
        listB = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 2 ORDER BY Order_Num_Calc__c ASC];
        listC = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 3 ORDER BY Order_Num_Calc__c ASC];
        listD = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 4 ORDER BY Order_Num_Calc__c ASC];
        listE = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 5 ORDER BY Order_Num_Calc__c ASC];
        listF = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 6 ORDER BY Order_Num_Calc__c ASC];
        listG = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 7 ORDER BY Order_Num_Calc__c ASC];
        listH = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 8 ORDER BY Order_Num_Calc__c ASC];
        listI = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 9 ORDER BY Order_Num_Calc__c ASC];
        listJ = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 10 ORDER BY Order_Num_Calc__c ASC];
        listK = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 11 ORDER BY Order_Num_Calc__c ASC];
        listL = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 12 ORDER BY Order_Num_Calc__c ASC];
        listM = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 13 ORDER BY Order_Num_Calc__c ASC];
        listN = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 14 ORDER BY Order_Num_Calc__c ASC];
        listO = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 15 ORDER BY Order_Num_Calc__c ASC];
        listP = [SELECT id, name, Article_Link__c, Article_Status__c, Link_Order__c, Status_Num_Calc__c, Notes__c, Subcategory__c
        FROM Article_Link__c WHERE Training_Module__c = :modId AND Subcategory_Num_Calc__c = 16 ORDER BY Order_Num_Calc__c ASC];

        sizeA = listA.size();
        sizeB = listB.size();
        sizeC = listC.size();
        sizeD = listD.size();
        sizeE = listE.size();
        sizeF = listF.size();
        sizeG = listG.size();
        sizeH = listH.size();
        sizeI = listI.size();
        sizeJ = listJ.size();
        sizeK = listK.size();
        sizeL = listL.size();
        sizeM = listM.size();
        sizeN = listN.size();
        sizeO = listO.size();
        sizeP = listP.size();
    }   
        public void saveAll(){
        update listA;
        update listB;
        update listC;
        update listD;
        update listE;
        update listF;
        update listG;
        update listH;
        update listI;
        update listJ;
        update listK;
        update listL;
        update listM;
        update listN;
        update listO;
        update listP;
        showYN = 'Y';
            }
}