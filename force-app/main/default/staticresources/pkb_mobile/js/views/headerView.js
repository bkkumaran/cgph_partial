define([
  'jquery',
  'underscore',
  'backbone',
  'views/searchBar',
  'views/filtersBar'
], function($, _, Backbone, searchBarView, filterBarView){

  var headerView = Backbone.View.extend({
      template: _.template($("#template-PKBHeader").html()),

    initialize:function() {
        this.render();
    },

    render: function(){
      var html = this.template();
      $(this.el).append(html);
      var searchB = new searchBarView({appView : this.options.appView, router : this.options.router}); 
      var filtersB = new filterBarView({appView : this.options.appView, router : this.options.router});
    },
    
    cleanup : function (){
      this.undelegateEvents();
      $(this.el).empty();
    }
  });
  return headerView;
});
