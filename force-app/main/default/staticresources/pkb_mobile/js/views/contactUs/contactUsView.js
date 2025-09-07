define([
  'jquery',
  'underscore',
  'backbone',
  'pkbUtils',
  'pkbLiveAgent',
  'models/contactUsModel',
  'views/contactUs/contactUsFormView',
  'views/contactUs/contactUsResultsView',
  'views/kArticleDetailView'], function ($, _, Backbone, utilsObj, pkbLAObj, formModel, contactUsFormView, contactUsResultsView,KArticleDetailView){

  var contactUsView = Backbone.View.extend({

    el: "#homeContainer",
    utils: new utilsObj,
    pkbLA: new pkbLAObj,

    initialize: function () {
      this.appView = this.options.appView;
      this.afterSumit = this.appView.router.afterSumit;
      this.localData = new formModel();
      this.localData.on("submitSuccess", this.submitSuccess, this);
      this.localData.on("errorSubmit", this.errorSubmit, this);
      this.localData.bind("displayUploadInProgress", this.displayUploadInProgress, this);
      if ( typeof this.appView.router.qString == 'string' && $.trim(this.appView.router.qString).length > 0  ){
        this.localData.set({
          questionBody: this.appView.router.qString
        });
      }
      this.renderAskForm();
      this.utils.initBox();
    },

    render: function(section,chain){
    	if ( section == undefined ) this.renderAskForm();
    	else if ( section == "hPlease" ) this.renderResultsList(chain);
    },

    renderSiView: function(state,chain,kId){
    	if ( this.kaDetail != undefined ){
    		this.kaDetail.$el.empty();
    		this.kaDetail.$el.off();
    	}

    	this.kaDetail = new KArticleDetailView({
            kArticleId: kId,
            router: this.options.router,
            source : this.afterSumit,
            isContactFlow : true
        });
    	this.kaDetail.on("readyToRender",this.renderSiViewReady,this);

      	this.kaDetail.on("showUserDataFormSiView",this.displayUserDataForm,this);

      this.$el.find(".preSearchTitle").hide();
      this.$el.find("#recommendedList").empty();
    	this.$el.find("#resultsList").empty();
    },

    renderSiViewReady: function(){

    	this.$el.find("#resultsList").html( this.kaDetail.render().$el.html() );
      //footer
      //$('#footer').remove();
    },

    renderAskForm: function (){
      if ( this.formView == undefined ){
    	  this.formView = new contactUsFormView({
    	        appView: this.options.appView,
    	        router: this.options.router,
    	        parent: this
    	      });
      }else{
      	this.formView.$el.empty();
      	this.formView.$el.off();
      	this.formView.renderAgain();
      }
    },

    /**  First Time Ask button is pressed (only fires up in that scenario) **/
    renderResultsList: function(val){
    	//clear any articleDetailView attached
        if ( this.kaDetail != undefined ){
          this.kaDetail.$el.empty();
          this.kaDetail.$el.off();
          this.kaDetail = undefined;
        }

    	  this.$el.find("#resultsList").empty().off();
	      var route = "contactFlow/"+this.afterSumit+"/hPlease/"+val+"/"+this.appView.router.filters;
    	  this.appView.router.navigate(route,false);

	      if ( this.rView != undefined){
	    	  this.rView.$el.empty();
	    	  this.rView.off();
	      }
	      this.localData.set({ 'questionBody' : val });
	      this.rView = new contactUsResultsView({
	        appView	: this.appView,
	        router	: this.options.router,
	        parent	: this
	      });
    },

    /** ACTION - cancel question **/
    cancelContact: function (e) {
      this.cleanup();
      history.back();
    },

    /** ACTION - submit question data **/
    continueAction : function (e) {
      this.formView.storeFormData();
    },

    /** ACTION - submit question and case data **/
    submitData: function () {
      this.localData.submitData();
    },


    /** DISPLAY - upload in progress loader **/
    displayUploadInProgress : function (){
      tpl = _.template($("#template-contactUs-UploadInProgress").html());
      this.utils.modalStyle = "small";
      this.utils.openBox({content: tpl});
      this.utils.modalStyle = "normal";
      $('#closeMBOX').hide();
    },


    /** DISPLAY - case data form **/
    displayUserDataForm: function () {

      cookieName  = this.options.appView.router.setupModel.get('contactDetailsCookieName');
      contactDetails = this.utils.readCookie(cookieName);
      storeDetails = new Object();
      if (contactDetails != undefined)
        $.each(contactDetails.split(';'), function (i,e){
            fieldList = e.split(':');
            storeDetails[fieldList[0]]=fieldList[1];
        })
      tpl = _.template($("#template-contactUs-CaseData").html());
      caseTypes = this.appView.router.setupModel.getCaseTypes();
      var html = tpl({
                      'qStr' : this.qStr,
                      'types': caseTypes,
                      'type' : (this.options.router.afterSumit != undefined ? this.options.router.afterSumit : "n"),
                      'storeDetails' : storeDetails
                    });

      this.utils.openBox({content: html});
      //bind events to modalBox content
      var that = this;
      $("#sendBtn").bind("click", function (e) {
          that.submitQuestion();
      });

      $("#cancelDialog").bind("click", function (e) {
          that.utils.closeBox();
      });

      /** reset live agent object**/

      this.liveAgentEnabled = this.options.router.setupModel.isLiveAgentEnabled();
      if ( this.liveAgentEnabled){
          this.pkbLA.initSFDC_LA(this.options.router.setupModel);
          this.pkbLA.removeScript();
          this.pkbLA.includeScript();
      }
    },

    /** ACTION - cancel case form**/
    cancelContact: function () {
        this.cleanup();
        history.back();
    },

    /**   VALIDATIONS   **/
    inputCheck: function (fieldName, maxLength) {
      //form field  userName
      trimmed = $('#' + fieldName).val().trim();
      errorStr = '';
      if (trimmed.length == 0) {
        errorStr = fieldName +  pkb2_LANG.get('error_all_fields_required')+'<br/>';
        errors = true;
      } else if (trimmed.length >= 1000) {
        errorStr += fieldName + pkb2_LANG.get.get('error_search_string_length').replace('NNN','1000');
        errors = true;
      }
      return errorStr;
    },

    validateSearch: function () {

      errors = false;
      $('#errorMsg').hide();
      $('#errorMsg').html('');
      //form field  userName
      trimmed = $('#userName').val().trim();
      errorStr = this.inputCheck('userName', 1000);
      errorStr = errorStr + this.inputCheck('lastName', 1000);
      errorStr = errorStr + this.inputCheck('userEmail', 100);

      //validate case type
      if ($('#userDataForm select').val().length == 0){
        errorStr = errorStr + pkb2_LANG.get('error_topic_empty');
      }

      if (errorStr.length > 0) {
        //we have to show the general error message, the separated messages are still calculated
        errorStr =  pkb2_LANG.get('error_all_fields_required') ;
        this.showError(errorStr);
      }

      return (errorStr.length > 0);
    },

    showError: function (msg) {

      $('#errorMsg').html(msg);
      $('#errorMsg').show();
    },

    /**  Send Email Flow **/
    submitQuestion: function () {

      if (!this.validateSearch()) {

        this.localData.set('firstName', $('#userName').val());
        this.localData.set('lastName', $('#lastName').val());
        this.localData.set('email', $('#userEmail').val());
        this.localData.set('reqType', $('#userDataForm select').val());

        this.submitData();
      }
    },


 /** CALLBACK - event triggerd from model **/
    submitSuccess : function (data){

      //store details in cookie
      cookieName  = this.options.appView.router.setupModel.get('contactDetailsCookieName');
      cookieValue = 'firstName:'+this.localData.get('firstName') +
                    ';lastName:'+this.localData.get('lastName') +
                    ';email:'+this.localData.get('email');
      this.utils.createCookie(cookieName,cookieValue);
      //clean localData
      this.localData.set( this.localData.defaults());
      this.options.appView.router.qString = '';

      switch (this.afterSumit){
        case 'chat':this.startliveAgentChat(data.contactDetails);
                    break;
        case 'call':this.utils.closeBox();
                    this.startSuportCall(data.caseNumber);
                    this.backToLandingPage();
                    break;
        default:  this.caseSubmitedSuccess();
      }
    },

    /** CALLBACK - event triggerd from model **/
    errorSubmit: function (msg) {
      $('#errorMsg').html(msg);
      $('#errorMsg').show();
    },


    /** CALLBACK - submit success for just case **/
    caseSubmitedSuccess : function (){
       tpl = _.template($("#template-contactUs-SubmitionSuccess").html());
       this.utils.modalStyle = "small";
       this.utils.openBox({content: tpl});
       this.utils.modalStyle = "normal";
      $('#closeMBOX').hide();
      //bind events to modalBox content
      var self = this;
      $("#closeContactUsSuccessfull").bind("click", function (e) {
          self.utils.closeBox();
          self.backToLandingPage();
      });
    },


    /**  Start live Agent chatFlow **/
    startliveAgentChat: function (contactData){

      tpl = _.template($("#template-contactUs-launchLiveAgentChat").html());
      this.utils.modalStyle = "small";
      this.utils.openBox({content: tpl});
      this.utils.modalStyle = "normal";
      $('#closeMBOX').hide();

      // bind event
      chatBtnId = this.appView.router.setupModel.get('LA_chatButtonId');//
      organizationId = this.appView.router.setupModel.get('organizationId');//
      deploymentId = this.appView.router.setupModel.get('LA_deploymentId');//
      salesforceliveagentURL = this.appView.router.setupModel.get('LA_chatServerURL');//

      var self = this;
      $("#liveagent_button_online").bind("click", function (e) {
        self.utils.closeBox();
        liveagent.startChatWithWindow(chatBtnId,'_self');
        //liveagent.startChat(chatBtnId);
      });
      $("#liveagent_button_offline").bind("click", function (e) {
        self.utils.closeBox();
        self.backToLandingPage();
      });



      this.pkbLA.bindStatus('liveagent_button_online','liveagent_button_offline');
      this.pkbLA.bindContactData(contactData);
     // this.pkbLA.initAgent();

      liveagent.init(salesforceliveagentURL, deploymentId, organizationId);

      //Auto join chat functionality
      var a = window.setInterval(function(){

    	  if ( $('#liveagent_button_online').css("display") != "none" ){
    		  clearInterval(a);
    		  $('#liveagent_button_online').trigger("click");
    	  }

    	  if ( $('#liveagent_button_offline').css("display") != "none" ){
    		  clearInterval(a);
    	  }
      },100);
    },

    /**  Start live Agent chatFlow **/
    startSuportCall: function (caseNumber){
      var self = this;
    	pkb_mobile_proxy.getPhoneCallAvailable( function(data){
    	self.cleanContactUsFlow();
    	if ( data.available == "true" ){
          numberToCall = data.number;
          ctiString = self.appView.router.setupModel.get('CTIDetails');
          if (typeof pkb2_ctiCONTSTANTS == 'object' )
              numberToCall = pkb2_ctiCONTSTANTS.get(numberToCall,ctiString,caseNumber)
          /*
          if (ctiString != ''){
            if (self.utils.deviceIsIPhone()){
               numberToCall += ctiString.replace(/\[P\]/g,pkb2_ctiCONTSTANTS.get('iphone_pause')).replace(/\[W\]/g,pkb2_ctiCONTSTANTS.get('iphone_wait')).replace(/\[CN\]/g,caseNumber);
            }
            if (self.utils.deviceIsAndroid()){
               numberToCall = ctiString.replace(/\[P\]/g,',').replace(/\[W\]/g,';').replace(/\[CN\]/g,caseNumber);
            }
          }*/
    	window.location="tel:"+numberToCall+"";
    	}else{
    		alert(pkb2_LANG.get('outside_business_hours'));
    	}
    	});
    },

    backToLandingPage : function (){
        this.cleanup();
        this.appView.contactUsView = undefined;
    	this.cleanContactUsFlow();
        this.appView.router.navigate('home',true);
    },

    cleanContactUsFlow: function(){
    	this.appView.router.filters = this.appView.router.filters.split("/")[0]+"/";
    	for ( var index in this.appView.selectedOptions ){
    		if ( index > 0 ){
    			this.appView.selectedOptions[index] = {
                        'rootName'		: undefined,
                        'dataCategory'	: undefined,
                        'rootPath'		: 'undefined:undefined',
                        'label'			: undefined
                    };
    		}
    	}
    },

    cleanup: function () {

      if (typeof this.contactUsFormView == 'object' && typeof this.contactUsFormView.cleanup == 'function')
        this.contactUsFormView.cleanup();

      if (typeof this.rView == 'object' && typeof this.rView.cleanup == 'function')
        this.rView.cleanup();

      this.undelegateEvents();
      $(this.el).empty();
    },

    resetData: function(){
    	this.localData.set(this.localData.defaults());
    }

});
return contactUsView;
});
