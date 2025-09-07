define([
  'jquery',
  'underscore',
  'backbone',
  'models/kArticleModel',
  'collections/popularKACollection',
  'views/kAVListItem'

], function($, _, Backbone, kavModel, kavCollection, kavItemView ){

  var popularListView = Backbone.View.extend({
	template: _.template($("#template-KAV-PopularList").html()),
    initialize: function(){
      this.appView = this.options.appView;
  	  this.el =  '#popularList';
      this.$el =  $('#popularList');
      this.collection = new kavCollection( this.appView.router.filters); 
      this.collection.bind("reset",this.render,this); 
      this.collection.fetch();    
    },

    render: function(){

	    // Pass this object onto the template function.
	    // This returns an HTML string.
	    var html = this.template();

	    // Append the result to the view's element.
	    $(this.el).append(html);

      this.collection.each(function(itm){ 
                this.displayListItem(itm);  
      },this);
      window.scrollTo(0,1);
      //Now display it (to avoid showing footer while results are still not displayed
      $('.footerBox').show();
    },

    displayListItem: function (item) {
         
      var kItem = new kavItemView({
        model  : item,
        appView : this.appView,
        source : 's'
      });
      kItem.on("elementClicked",this.elementClicked,this);
      $(this.el).append(kItem.render().$el);
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
  return popularListView;
});