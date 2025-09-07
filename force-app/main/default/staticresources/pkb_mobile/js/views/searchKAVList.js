define([
  'jquery',
  'underscore',
  'backbone',
  'models/kArticleModel',
  'collections/searchResultsCollection',
  'collections/keywordKACollection',
  'views/kAVListItem',
  'pkbUtils'

], function($, _, Backbone, kavModel, kavCollection,keyCollection, kavItemView, utilsObj ){

  var sResultsListView = Backbone.View.extend({


    utils : new utilsObj(),

    initialize: function(){
      this.appView = this.options.appView;
      this.filters = this.appView.router.filters;
      this.el =  this.options.el;
      this.$el =  $(this.options.el);
      this.collection = new kavCollection( this.filters);
      this.collection.bind("reset",this.displaySearchResults,this);
      this.collection.bind("errorFetch", this.errorFetch, this);
      this.recomendedCollection = new keyCollection( this.filters);
      this.recomendedCollection.bind("reset",this.displayRecommendedResults,this);
      this.recomendedCollection.bind("errorFetch", this.errorFetch, this);
      this.searchFlag = this.recommendedFlag = 0;
    },
    
    searchFor : function(qString){
      this.collection.fetch(qString); 
      this.recomendedCollection.fetch(qString);  
    },

    displayRecommendedResults : function (){
      $(this.el).find('#recommendedList > article').remove();
      if (! this.recomendedCollection.isEmpty()){
        $('#recommendedList').append($('span.kavListTitle'));
        this.recomendedCollection.each(function(itm){ 
              this.displayListItem(itm, true);  
        },this);
      }
      this.recommendedFlag = 1;
      this.checkFlags();
    },

    displaySearchResults : function (){
      $(this.el).find('#resultsList > article').remove();
      $('#noResults').hide();
      if (! this.collection.isEmpty()){
        maxItems =  parseInt(this.options.maxResults);
        this.collection.each(function(itm){
            if (  isNaN(maxItems) || maxItems == -1 ||
                ( maxItems > -1 && 
                  $(this.el).find('#resultsList article').size() < maxItems))
                  this.displayListItem(itm,false);
        },this);
      }
      this.searchFlag = 1;
      this.checkFlags();
    },
    
    checkFlags: function(){
    	if ( this.searchFlag == 1 && this.recommendedFlag == 1 ){
    		this.searchFlag = this.recommendedFlag = 0;
    		if ( this.collection.isEmpty() && this.recomendedCollection.isEmpty() ){
    			$('#noResults').show();
        		this.trigger('noResults',this);
    		}
    		$('.footerBox').show();
    	}
    },
    
    displayListItem: function (item,isKeyword) {
         
      var kItem = new kavItemView({
        model  : item,
        appView : this.appView,
        isKeyword : isKeyword,
        source : this.options.source
      });
      kItem.on("elementClicked",this.elementClicked,this);
      if (isKeyword){
        $(this.el).find('#recommendedList').append(kItem.render().$el);
      }else{
        $(this.el).find('#resultsList').append(kItem.render().$el);
      }
    },
    
    elementClicked: function(obj){
    	this.trigger("elementClicked",obj);
    },
    
    errorFetch: function (msg){
      this.showError( msg);
    },

    showError : function (msg){
      this.utils.showErrorModal( msg);
    },
    
    cleanup : function (){
      this.undelegateEvents();
      $(this.el).empty();
    }
  });
  return sResultsListView;
});