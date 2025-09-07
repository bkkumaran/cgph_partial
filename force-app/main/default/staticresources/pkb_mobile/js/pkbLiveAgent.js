define([
  'jquery',
  'underscore',
  'backbone'
], function($,_, Backbone){

	var pkbLiveAgent = function(){};

    _.extend(pkbLiveAgent.prototype, {


		initSFDC_LA  : function(setupData){
			//console.log('pkbLiveAgent : initSFDC_LA');
			this.chatBtnId = setupData.get('LA_chatButtonId');
            this.organizationId = setupData.get('organizationId');
            this.deploymentId = setupData.get('LA_deploymentId');
            this.salesforceliveagentURL = setupData.get('LA_chatServerURL');
            this.deploymentURL = setupData.get('LA_deploymentScriptURL');// 
            this.onlineStatus = '';
            this.offlineStatus = '';
		},


    	includeScript : function(){
			//console.log('pkbLiveAgent : includeScript');
            var script = document.createElement('script');
            script.src = this.deploymentURL;//'https://c.la1w1.salesforceliveagent.com/content/g/deployment.js';
            script.type = 'text/javascript';
            document.getElementsByTagName('head')[0].appendChild(script);
	
    	},

    	removeScript :function(){
			//console.log('pkbLiveAgent : removeScript');
            delete liveagent;
            liveAgentDeployment = false;
            window._laq = null;
    	},


    	bindStatus : function (onlineStatus, offlineStatus){
			//console.log('pkbLiveAgent : bindStatus '+onlineStatus+' off:'+offlineStatus);
            this.offlineStatus  = offlineStatus;
            this.onlineStatus = onlineStatus;
    		var self = this;

			if (!window._laq) { window._laq = []; }
                window._laq.push(function(){
                    liveagent.showWhenOnline(self.chatBtnId, document.getElementById(onlineStatus));
                    liveagent.showWhenOffline(self.chatBtnId, document.getElementById(offlineStatus));
                });
    	},

    	bindContactData : function (contactData){
			//console.log('pkbLiveAgent : bindContactData');

          liveagent.addCustomDetail('Case Id', contactData.CaseId).map('Case', 'Id', false,true,false); 
          liveagent.addCustomDetail('Case Number', contactData.CaseNumber).map('Case', 'Number', false, true,false); 
          
          liveagent.addCustomDetail('Case', contactData.CaseId).saveToTranscript('Case'); 

	      // Overrides the display name of the visitor in the agent console when enaged in a chat     
	      liveagent.setName(contactData.Name);      

    	},

    	initAgent : function (){
			self = this;
			if (typeof liveagent == "undefined"){
				setTimeout(function(p) {
                        self.initAgent();
                }, 500);
			}else{
				liveagent.init(this.salesforceliveagentURL, this.deploymentId, this.organizationId);
			}
			//liveagent.init(this.salesforceliveagentURL, this.deploymentId, this.organizationId);
    	},

        okToinclude : function (){
            isOk =(     (   this.offlineStatus != '') && 
                        (   this.onlineStatus != '' ) && 
                        ( $('#'+this.onlineStatus+' , #'+this.offlineStatus).size() >= 2 ));
            return isOk;
        
        }

    });
    return pkbLiveAgent;
});