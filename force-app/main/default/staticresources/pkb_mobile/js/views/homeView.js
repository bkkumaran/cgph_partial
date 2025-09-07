define([
  'jquery',
  'underscore',
  'backbone',
  'views/featuredKAVList',
  'views/popularKAVList'
], function($, _, Backbone, featuredView,popularView){

  var homeView = Backbone.View.extend({

    el: $("div#content"),

    template: _.template($("#template-PKBhome").html()), 

    render: function(){
      //reset any previous search state
      this.options.appView.router.qString = '';
      $('input#searchText').val('');
      // Pass this object onto the template function.
      // This returns an HTML string.
      var html = this.template();
      // Append the result to the view's element.
      $(this.el).html(html);
      // featured list view 
      var fKAvCollView = new featuredView({'appView' : this.options.appView}); 
      // popular list view 
      var pKAvCollView = new popularView({'appView' : this.options.appView}); 

    },
    
    cleanup : function (){
      this.undelegateEvents();
      $(this.el).empty();
    }

  });

  return homeView;
  
});
