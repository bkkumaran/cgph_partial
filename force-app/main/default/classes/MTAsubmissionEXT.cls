public class MTAsubmissionEXT {

    Public Program_Application__c programApp {get; set;}
    Public String appID {get; set;}

    public MTAsubmissionEXT(ApexPages.StandardController controller) {
        programApp = (Program_Application__c )controller.getRecord();
        appID = programApp.Id;
           }

        public PageReference save(){
                update programApp ;
                PageReference pg = new PageReference('/apex/MTAsubmission?Id='+appID);
                pg.setRedirect(true);
                return pg;
        }
    
        public PageReference cancel(){
                PageReference pg = new PageReference('/apex/MTAsubmission?Id='+appID);
                pg.setRedirect(true);
                return pg;
                }

}