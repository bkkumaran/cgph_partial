 define([
   'underscore',
   'backbone',
   'models/kArticleModel',
   'pkbUtils'
 ], function (_, Backbone, aModel, pkbUtils) {
   var kFeatured = Backbone.Collection.extend({
     model: aModel,
     utils: new pkbUtils,
     initialize: function (ac) {
       this.action = ac;
       this.reqObj = this.utils.buildRequestObject('getFeatured', ac);
     },
     fetch: function () {
       var that = this;
       var callback = function (e, r) {
          result = JSON.parse($('<div>').html(r.result).text());
          if (result.isSuccess) {
            knowArticles = result.articles;
            that.reset(knowArticles);
          } else {
            alert(result.message);
          }
     }
      pkb_mobile_proxy.getRemoteAction(JSON.stringify(this.reqObj), callback);
     }
   });
   return kFeatured;
 });