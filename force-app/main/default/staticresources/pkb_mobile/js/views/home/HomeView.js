define([
  'jquery',
  'underscore',
  'backbone',
  'views/featuredKAVList',
  'views/popularKAVList'
], function($, _, Backbone, featuredView,popularView){
  var HomeView = Backbone.View.extend({
      el: $("div#homeContainer"),
      template: _.template($("#template-PKBhome").html()),
    render: function(){
      // Pass this object onto the template function.
      // This returns an HTML string.
      var html = this.template();
      // Append the result to the view's element.
      $(this.el).append(html);
      // featured list view 
      var fKAvCollView = new featuredView(); 
      // popular list view 
      var pKAvCollView = new popularView(); 
    }
});
return HomeView;
});
