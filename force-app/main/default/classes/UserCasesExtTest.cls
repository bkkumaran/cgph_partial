@istest
public class UserCasesExtTest {
private static testmethod void UserCasesExtTest() {
    
    String userID = UserInfo.getUserId();
    
    User me = [ select Id from User where Id = :userID Limit 1 ];

    ApexPages.currentPage().getParameters().put('id', userID );
		ApexPages.StandardController std = new ApexPages.StandardController(me);
	    UserCasesExt objUserCasesExtTest  = new UserCasesExt(std);
    	objUserCasesExtTest.save();
    	objUserCasesExtTest.cancel();

}    
}