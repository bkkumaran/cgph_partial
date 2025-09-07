define([
  'jquery',
  'underscore',
  'backbone',
  'pkbUtils',
  'views/searchKAVList',
  'views/searchBar',
  'models/kArticleFeedbackModel',
  'views/filtersBar'], function ($, _, Backbone, utilsObj, searchResultView, searchBarView,feedBackModel, filterBarView) {

  var contactUsResults = Backbone.View.extend({

    el: "#homeContainer",

    utils: new utilsObj,

    template: _.template($("#template-contactUs-searchResults").html()),

    events: {
      "click #showUserDataForm" 	: "displayUserDataForm",
      "click #cancelBtn"			    : "cancelFlow",
      "click img.backBtn"			    : "goBack",
      "click #deflectFromResults"  	: "deflectAndRedirectHome"
    },

    initialize: function () {
      this.appView = this.options.appView;
      this.sResultsView = new searchResultView({
        appView: this.appView,
        filters: this.appView.router.filters,
        el: '#contactUsresultsList',
        source : 'c',
        maxResults : this.appView.router.setupModel.getMaxContactUsResults()
      });
      this.sResultsView.on("elementClicked",this.elementClicked,this);
      this.sResultsView.on("reset", this.render, this);
      this.sResultsView.on("noResults", this.displayUserDataForm, this);
      this.qStr = decodeURIComponent(this.options.parent.localData.get('questionBody'));
      this.sResultsView.searchFor( this.qStr);
      this.render();
    },

    elementClicked: function(obj){
    	kavId 	= obj.model.get('id');
        source 	= (obj.options.source != undefined) ? obj.options.source : 's';
        var route = "contactFlowS/"+this.options.parent.afterSumit+"/hPlease/"+encodeURIComponent(this.qStr)+"/"+kavId+"/"+this.appView.router.filters;
        this.appView.router.navigate(route,true);
    },

    displayUserDataForm: function (e) {
      this.generateDeflection(false);
      this.options.parent.displayUserDataForm();
    },

    goBack: function(){
    	window.history.back(1);
    },

    cancelFlow: function(){
      //remove pictures from dom
      this.options.parent.formView.removePictureUploadeElements();
    	this.appView.contactUsView = undefined;
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
    	this.appView.router.navigate("home",true);
    },

    render: function () {
      var html = this.template();
      $(this.el).html(html);
      this.appView.router.qString = this.qStr;
      if ( this.searchB != undefined ){
    	  this.searchB.$el.empty();
    	  this.searchB.$el.off();
      }
      this.searchB = new searchBarView({appView : this.appView, router : this.appView.router, contactFlow : true});
      this.searchB.on("performSearch",this.performSearch,this);


      var filtersB = new filterBarView({appView : this.options.appView, router : this.options.router});
    },

    performSearch: function(val){
    	$('.preSearchTitle').show();
    	this.appView.router.qString = val;
    	this.qStr = val;
    	this.options.parent.localData.set({ 'questionBody' : val });
    	this.sResultsView.searchFor(this.qStr);
    	$('#resultsList').empty();
    	var url = "contactFlow/"+this.options.parent.afterSumit+"/hPlease/"+this.qStr+"/"+this.appView.router.filters;
    	this.appView.router.navigate(url,false);
    },

    deflectAndRedirectHome : function (){

      this.generateDeflection(true);
      //clearn query string
      this.appView.router.qString = '';
      //clean localData
      this.options.parent.localData.set(  this.options.parent.localData.defaults());

      this.appView.router.navigate('home',true);
    },

    generateDeflection : function (deferred){


      var feedBackObj = new feedBackModel();
      feedBackObj.set({
                          isDeferred: deferred,
                          articleNumber: 'n/a',
                          feedbackComments: 'n/a',
                          searchString: this.appView.router.qString,
                          source: 'c',
                          kavId: 'n/a',
                          title: 'n/a'
                        });
      //deflectio parameters
      if (this.options.parent.kaDetail != undefined ) {
        kaModel = this.options.parent.kaDetail.model;
        feedBackObj.set('articleNumber', kaModel.get('articleNumber'));
        feedBackObj.set('title', kaModel.get('title'));
        feedBackObj.set('kavId', kaModel.get('id'));
      }


      feedBackObj.submitData();

    },

    cleanup: function () {
      this.undelegateEvents();
      $(this.el).empty();
    },
    /*
        SKIP USER DETAILS FORM AND SUBMIT
    */
    submitCaseSkipForm : function(){

      //take data form cookie
      var userData = {'firstName' :'loren',
                      'lastName' : 'impsun',
                      'email':'an@email.com',
                      'reqType':'theType'};

      this.options.parent.skipUserDetailsFormAndSubmit(userData);


    }
  });
  return contactUsResults;
});
