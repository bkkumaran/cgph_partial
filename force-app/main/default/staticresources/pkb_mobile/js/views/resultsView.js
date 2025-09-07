define([
  'jquery',
  'underscore',
  'backbone',
  'views/headerView',
  'views/searchKAVList'
], function($, _, Backbone, headerView, searchResultView){

  var resultsView = Backbone.View.extend({
    
    el: $("div#content"),

    template: _.template($("#template-PKBSearchResults").html()), 

    initialize:function() {
      this.appView = this.options.appView;
      this.el =  'div#content';
      this.$el =  $('div#content');
      this.resultsView = new searchResultView({
            'appView' : this.appView , 
            el: '#resultsSection',
            source : 's'});
      this.resultsView.on("elementClicked",this.elementClicked,this);
    },

    elementClicked: function(obj){
    	tmpUrl = obj.utils.getLanguage(obj.router.filters);
        kavId = obj.model.get('id');
        source = (obj.options.source != undefined) ? obj.options.source : 's';
        obj.router.navigate('article' + obj.utils.pathGlueKey + tmpUrl + obj.utils.pathGlueKey + kavId+ obj.utils.pathGlueKey+source ,true);
    },
    
    render: function(){
      var html = this.template();
      $(this.el).html(html);
      $(this.el).show();
      this.resultsView.searchFor(this.appView.router.qString);
    },
    
    cleanup : function (){
      this.undelegateEvents();
      $(this.el).empty();
    }

  });

  return resultsView;
  
});
