public class getIPext {

Public String ip {get; set;}

    public getIPext(ApexPages.StandardController controller) {
    
    ip = ApexPages.currentPage().getHeaders().get('X-Salesforce-SIP');

    }

}