public class PreAppEncodeIdTriggerHandler{

     //Method to update base64 encoded Preapplicant Id
    public void updatePreAppEncodedId(){
      list<PreApplicants__c> lstToUpdatePreApplicant = new list<PreApplicants__c>();
      //CGPH_Profile_Custom_Settings__c cgphSettings = CGPH_Profile_Custom_Settings__c.getInstance();
      
      string strEncodeId='';
      string preFixZeros = '000';
      //strEncodeId = cgphSettings.Encrypted_ID_Suffix__c;
      for(sObject preApplicant : trigger.new)
      {
      	// check that if New_ID_Reset_Email__c is set then increment the suffix and update the id

        string strSuffix = (string)preApplicant.get('Encrypted_ID_Suffix__c');
        if( strSuffix == null || strSuffix == '' ) {
            strSuffix = '0001';
        } else {
         	if(preApplicant.get('New_ID_Reset_Email__c') == true ) // Increment Suffix if ID Reset
       	  {
       			integer iSuffix = Integer.valueOf(strSuffix);
       		  iSuffix++;
			      if( iSuffix < 10 ) {
			        preFixZeros = '000';
            }else if( iSuffix < 100 )  {
              preFixZeros = '00';
            }else if( iSuffix < 1000 ) {
              preFixZeros = '0';
            }
			      strSuffix = preFixZeros + string.valueof(iSuffix); 
          }
       	}
   		  
        if((((preApplicant.get('PreApplicant_Encoded_Id__c') == null) || (preApplicant.get('New_ID_Reset_Email__c') == true )) && Trigger.isupdate) )
        {            	
          string preAppID = (string)preApplicant.get('Id') + strSuffix;
          system.debug('@@ preAppID in trigger'); 
          Blob beforeblob = Blob.valueOf(preAppID);
          String strEncodedId = EncodingUtil.base64Encode(beforeblob);
          preApplicant.put('PreApplicant_Encoded_Id__c',strEncodedId);
          //preApplicant.put('New_ID_Reset_Email_Date__c',Date.today()); these are done by workflow
          //preApplicant.put('New_ID_Reset_Email__c',false);
          preApplicant.put('Encrypted_ID_Suffix__c',strSuffix);
        }
             
	      if(trigger.isInsert)
	      {
			    string preAppID = (strEncodeId != '' && strEncodeId != null) ?  ((string)preApplicant.get('Id') + strEncodeId) : (string)preApplicant.get('Id') + '0001';
			    Blob beforeblob = Blob.valueOf(preAppID);
			    String strEncodedId = EncodingUtil.base64Encode(beforeblob);
	        	
			    PreApplicants__c objApplicant = new PreApplicants__c();
			    objApplicant.id = (string)preApplicant.get('Id');
			    objApplicant.PreApplicant_Encoded_Id__c = strEncodedId;
          objApplicant.Encrypted_ID_Suffix__c = strSuffix;
							
			    lstToUpdatePreApplicant.add(objApplicant);
	      }
      }
      
      try{
        if(lstToUpdatePreApplicant != null && lstToUpdatePreApplicant.size() > 0 && trigger.isInsert){
          update lstToUpdatePreApplicant;
        }
      }catch(DMLException ex){
        system.debug('::DMLException::==='+ex.getMessage()+'===::Line Number::==='+ex.getLineNumber()+'===::Type::==='+ex.getTypeName());
      }
    }
}