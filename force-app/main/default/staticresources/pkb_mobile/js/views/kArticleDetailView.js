define([
  'jquery',
  'underscore',
  'backbone',
  'pkbUtils',
  'models/kArticleModel',
  'models/kArticleFeedbackModel',
  'collections/searchResultsCollection',
  'views/searchBar',
  'views/kArticleDetailFeedBack'
  ], function ($, _, Backbone, pkbObj, kArticleView, feedBackModel, kavCollection,searchBarView,kArticleDetailFeedBack) {

  var articleDetailView = Backbone.View.extend({

    el: "#homeContainer",

    template: _.template($("#template-KA-Detail").html()),

    utils: new pkbObj(),

    events: {
      'click div.relatedArticle'      : 'displayRelatedItem',
      'click #feedbackOK'             : 'sendFeedbackOK',
      'click #feedbackNOTOK'          : 'showFeedbackForm',
      'click #showUserDataFormSiView' : 'showDataForm'
    },

    initialize: function () {

      if ( this.options.isContactFlow != undefined && this.options.isContactFlow == true ){
    	  this.template = _.template($("#template-KA-Detail-inContactFlow").html());
    	  this.$el = $("<div></div>");
      }

      this.router = this.options.router;

      this.model = new kArticleView();
      this.model.onReset = this.render;
      this.model.on("change", this.checkRender, this);
      this.model.url = this.options.kArticleUrl;
      this.model.id = this.options.kArticleId;
      this.model.sessionId = this.router.sessionId;
      this.model.on("errorFetching", this.errorFetching, this);

      this.feedBackObj = new feedBackModel();
      this.feedBackObj.set('source', this.options.source);
      this.feedBackObj.set('searchString', this.router.qString);
      this.feedBackObj.bind("errorSubmit", this.errorSubmit, this);
      this.feedBackObj.bind("successSubmit", this.successSubmit, this);

      this.maxRelatedArticlesToShow = this.router.setupModel.getMaxRelatedArticles();

      this.utils.initBox();
      lang = this.utils.getLanguage(this.router.filters);
      this.model.fetch(lang);
    },

    checkRender: function(){
    	if ( this.options.isContactFlow == true ){
    		this.trigger("readyToRender");

        self = this;
        //binding of events within contactUs flow
        $('#showUserDataFormSiView').click(function(i,c){
          /*
              If user click yes, we present the contact
              form and create a deflection record with
              deflection checkbox off
          */
          if (!self.model.get('feedbackGiven')){
            self.feedBackObj.off("successSubmit");
            self.feedBackObj.on("successSubmit", self.successSubmitSilent, self);
            self.feedBackObj.set('source', 'c');
            self.sendFeedback();
          }

          self.trigger("showUserDataFormSiView",self);
        });
        /*
              If user clicks no, we create a deflection checkbox
              set to on with related article and keyword,
              channel and we redirect to the landing page.
        */
        $('#feedbackOK').click(function(i,c){
          self.feedBackObj.set('source', 'c');
          self.sendFeedbackOK();
        });

      }else{
    		this.render();
    	}

    },

    render: function () {
      if ( this.options.isContactFlow == undefined ) this.options.isContactFlow = false;

      if ( this.alreadyEscapedArticle == undefined ){
        auxScaped = this.model.attributes.title;
        this.model.attributes.title = _.escape(auxScaped);
        auxScaped = this.model.attributes.summary;
        this.model.attributes.summary = _.escape(auxScaped);
        this.alreadyEscapedArticle = true;
      }

      this.$el.html( this.template(this.model.toJSON()) );

      if ( this.options.isContactFlow == false )
          var searchB = new searchBarView({appView : this.appView, router : this.options.router, isSingleView : true, noSearch : this.options.isContactFlow});

      this.feedBackObj.set('articleNumber', this.model.get('articleNumber'));
      this.feedBackObj.set('title', this.model.get('title'));
      this.feedBackObj.set('kavId',  this.model.get('id'));//the deflectiopn goes related to the KA this.model.get('id'));
      this.displayArticleFields();
      window.scrollTo(0,1);

      if ( this.options.isContactFlow == false ){
    	  // search results list view
          // use the artitle title to search related articles
          this.collection = new kavCollection(this.router.filters);
          this.collection.bind("reset", this.displayRelatedResults, this);
          this.collection.fetch(this.model.get('title'));
          $('body').css({ 'margin-bottom' : 101 });
      }
      return this;
    },

    displayArticleFields:function(){
      fieldTpl = _.template($('#template-KA-FieldDetail').html());
      listFields = this.model.get('fieldValues').fieldOrder.split(',');
      //list detailing wich fields are RICHTEXT
      rFields = this.model.get('fieldValues').richTextFields.split(',');

      for ( i in listFields ) {
          if (typeof listFields[i] == 'string' && this.model.get('fieldValues')[listFields[i]] != undefined ) {
              if ( $.inArray(listFields[i],rFields) == -1 )
                  tmpValue = _.escape(this.model.get('fieldValues')[listFields[i]]);
              else
                  tmpValue = this.model.get('fieldValues')[listFields[i]];

              data = {
                fLabel: listFields[i],
                fValue:  tmpValue
              };
              this.$el.find('.articleBody').append(fieldTpl(data));
          }
      }

    },

    displayRelatedResults: function (){
      if (this.maxRelatedArticlesToShow == 0 ) {
         $('.relatedTitle').hide();
         return;
      }

      if (this.collection.length > 1){
        $('#noResults').hide();
        this.collection.each(function(itm){
          if ( $('#relatedResultsSection div.relatedArticle').size() < this.maxRelatedArticlesToShow )
          this.displayListItem(itm);
        }, this);
        $('#relatedResultsSection').show();
      } else {
        $('#noResults').show();
        $('.relatedTitle').hide();
      }
    },

    displayListItem: function (item) {
      tpl = _.template($('#template-KAV-Related-Item').html());
      if (item.get('id') != this.model.get('id')) {
        $(this.el).find('#relatedResultsSection').append(tpl({
          id: item.get('id'),
          title: _.escape(item.get('title'))
        }));
        //adjust lines
        linesToDisplay = 2;
        obj = $('div#'+item.get('id'));
        lineH = $(obj).css('line-height');
        currentH = $(obj).height();
        numLines = (Math.floor( currentH / parseInt(lineH, 10)));
        if (numLines > linesToDisplay){
          finalLength =  10 + (  linesToDisplay *  currentH /   numLines );
          tmpTitle = this.utils.cutAt(item.get('title'),finalLength);
          $(obj).html(tmpTitle);
        }

      }
    },

    displayRelatedItem: function (e) {
      var kavID = $(e.currentTarget).attr('id');
      e.stopImmediatePropagation();
      tmpUrl = this.utils.getLanguage(this.router.filters);
      this.router.navigate('article' + this.utils.pathGlueKey + tmpUrl + this.utils.pathGlueKey + kavID+ this.utils.pathGlueKey+'r', true);

      this.cleanup();
    },

    sendFeedbackOK: function (e) {
      //
      this.feedBackObj.set('isDeferred', true);
      this.feedBackObj.set('feedbackComments','');
      this.feedBackObj.submitData();//(this.successSubmit, this.errorSubmit, this.model);
    },

    showFeedbackForm : function (e) {
    	var feedbackForm = new kArticleDetailFeedBack();
    	feedbackForm.on('cancelSubmit',this.cancelSubmit,this);
    	feedbackForm.on('sendFeedback',this.sendFeedback,this);

    	$('#homeContainer').hide();
    	feedbackForm.render();
    },

    cancelSubmit: function(args){
    	args.$el.empty();
    	args.off();
    	$('.feedBackMain').remove();
    	$('#homeContainer').show();
    },

    sendFeedback: function(args){
    	this.feedBackObj.set('isDeferred', false);
      userInput = '';
      if (this.options.isContactFlow == false ){
        userInput =$('.feedBackTextArea').val();
      }

      this.feedBackObj.set('feedbackComments', userInput);
      this.feedBackObj.submitData();//(this.successSubmit, this.errorSubmit, this.model );
      if (typeof args != 'undefined'){
        args.$el.empty();
        args.off();
      }
    	$('.feedBackMain').remove();
    	$('#homeContainer').show();
    },

    successSubmitSilent: function () {},

    successSubmit: function () {

      tmpStat = parseInt( this.model.get('usefulStat'))+ 1;
      this.model.set({'usefulStat': tmpStat,
                      'feedbackGiven': true});

      tpl = _.template($('#template-KA-FeedbackSuccess').html());
      this.utils.modalStyle = "small";
      this.utils.openBox({content: tpl()});
      this.utils.modalStyle = "normal";
      //bind events to modalBox content
      var self = this;
      $("#closeFeedback").bind("click", function (e) {
          self.utils.closeBox();
          if (self.options.isContactFlow){
             self.router.navigate('home',true);
          }
      });
    },

    errorFetching :function (msg) {
      this.utils.showErrorModal(msg);
    },

    errorSubmit: function (msg) {
      this.utils.showErrorModal(msg);
    },

    cleanup: function () {
      this.undelegateEvents();
      $(this.el).empty();
    },
    showDataForm: function(){
    	this.trigger("confirmSend",this);
    }
  });
  return articleDetailView;
});