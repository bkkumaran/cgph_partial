define([
    'jquery',
    'underscore',
    'backbone',
    'pkbUtils',
    'pkbLiveAgent'], function ($, _, Backbone, utilsObj, pkbLAObj) {

    var contactUsFooter = Backbone.View.extend({
        template: _.template($("#template-contactUs-footer").html()),
        utils: new utilsObj,
        pkbLA: new pkbLAObj,
        el: '#footer',
        events: {
            "click div#contactBtn" : "showContactUs",
            "click .chatBtn"    : "showContactUsAndChat",
            "click div#callBtn"    : "showContactUsAndCall"
        },

        initialize: function () {
        	this.render();
        },

        render: function () {
        	this.appView = this.options.appView;
            tRouter = this.appView.router;
            this.liveAgentEnabled = tRouter.setupModel.isLiveAgentEnabled();
            if (this.liveAgentEnabled){
                //this.pkbLA.removeScript();
            	//this.pkbLA.initSFDC_LA(tRouter.setupModel);
               // this.pkbLA.includeScript();
            }
        	$('body').css({ 'margin-bottom' : 101 });
            this.$el.html(this.template({'liveAgentEnabled' :this.liveAgentEnabled , 'callEnabled' : this.appView.router.setupModel.isSupportCallEnabled()}));
            this.$el.find('.contactUs_footer').addClass('footerBox');
            if (this.liveAgentEnabled){
               // this.pkbLA.bindStatus('liveagent_button_online_footer','liveagent_button_offline_footer');
               // this.pkbLA.initAgent();
            }

            this.solveLiveAgent();
            window.scrollTo(0,1);
        },

        showContactUs: function () {
        	this.appView.router.filters = this.appView.router.filters.split("/")[0]+"/";
            this.appView.router.navigate('contact/n/' + this.appView.router.filters, true);
        },

        showContactUsAndChat : function () {
            if (!this.appView.router.setupModel.isLiveAgentEnabled()) return;
            this.appView.router.filters = this.appView.router.filters.split("/")[0]+"/";
            this.appView.router.navigate('contact/chat/' + this.appView.router.filters, true);
        },

        showContactUsAndCall : function () {
            if (!this.appView.router.setupModel.isSupportCallEnabled()) return;
            this.appView.router.filters = this.appView.router.filters.split("/")[0]+"/";
            this.appView.router.navigate('contact/call/' + this.appView.router.filters, true);
        },

        cleanup: function(){
            this.undelegateEvents();
            $(this.el).empty().off();
        },

        solveLiveAgent : function(){

            setupData = tRouter.setupModel.attributes;

            $('<iframe></iframe>', {    id: 'myiframe',
                                        src : iframeSrcPath,
                                        style : ' height: 0px; border: none; '
                                    }).bind('load', function(event) {

                if (!this.contentWindow) {
                    return;
                }

                var scripWidthSrc = document.createElement('script');
                scripWidthSrc.type ='text/javascript';
                scripWidthSrc.src = setupData.LA_deploymentScriptURL;
                this.contentWindow.document.getElementsByTagName('head')[0].appendChild(scripWidthSrc);

                var scripWidthSrc2 = document.createElement('script');
                scripWidthSrc2.type ='text/javascript';
                scripWidthSrc2.src = resourcesPath+'/js/liveAgenHack.js';
                this.contentWindow.document.getElementsByTagName('head')[0].appendChild(scripWidthSrc2);

            }).appendTo('#container-iframe');

            this.sendConfigData(setupData);

        },
        /*
            this method sends the configuration data to the iframe who queries liveAgent
            if the iframe is not loaded , we will test every 500 ms untils the iframe is ready
            and we can start the liveAgent logic
        */
        sendConfigData : function(data){
            var self = this;
            self.data = data;

            if (    typeof window.frames['myiframe'] == "object" &&
                    typeof window.frames['myiframe'].initData == "function"){
                window.frames['myiframe'].initData(self.data);
            }else{
                setTimeout( function() {
                    self.sendConfigData(self.data);
                }, 500 );
            }
        }
    });

    return contactUsFooter;

});