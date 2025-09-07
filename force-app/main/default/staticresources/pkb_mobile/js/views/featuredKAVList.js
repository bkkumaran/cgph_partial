define([
  'jquery',
  'underscore',
  'backbone',
  'models/kArticleModel',
  'collections/featuredKACollection',
  'views/kAVListItem'

], function($, _, Backbone, kavModel, kavCollection, kavItemView ){

  var featuredListView = Backbone.View.extend({
	template: _.template($("#template-KAV-FeaturedList").html()),

	initialize: function(){
      this.appView = this.options.appView;
      this.el = '#featuredList';
      this.$el = $('#featuredList');
      this.collection = new kavCollection( this.appView.router.filters); 
      this.collection.bind("reset",this.render,this); 
      this.collection.fetch();    
    },

    render: function(){
	    var html = this.template();
	    $(this.el).append(html);
      this.collection.each(function(itm){ 
                this.displayListItem(itm);  
      },this);
      //Handle if no items to display, hide featured title
      if ( this.collection.length == 0 ){
    	  $('#featuredList').remove();
      }
    },

    displayListItem: function (item) {
      var kItem = new kavItemView({
        model  : item,
        appView : this.appView,
        source : 's'
      });
      kItem.on("elementClicked",this.elementClicked,this);
      $(this.el).append(kItem.render().$el);
      window.scrollTo(0,1);
    },
    
    elementClicked: function(obj){
    	tmpUrl = obj.utils.getLanguage(obj.router.filters);
        kavId = obj.model.get('id');
        source = (obj.options.source != undefined) ? obj.options.source : 's';
        obj.router.navigate('article' + obj.utils.pathGlueKey + tmpUrl + obj.utils.pathGlueKey + kavId+ obj.utils.pathGlueKey+source,true);
    },
    
    cleanup : function (){
      this.undelegateEvents();
      $(this.el).empty();
    }
  });
  return featuredListView;
});