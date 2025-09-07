  define([
  'underscore',
  'backbone',
], function(_, Backbone) {
  var KArticleModel = Backbone.Model.extend({
  	defaults : {
  		id : '0303456',
  		title : 'no value',
  		Summary :'text used to describe',
  		urlName:'a/b/c/d',
  		articleTypeName :'OneOfMany',
  		articleTypeLabel :'OneOfMany',
  		lastModifiedDate :'2012-12-12',
  		firstPublishedDate :'2012-12-12',
  		lastPublishedDate :'2012-12-12',
      articleData : null
  	},
    fetch: function(l){
      console.log('langl '+ l);
      l = l.replace('l:','');
    	searchQ = (this.id != undefined && this.id != '') ? this.id : this.url;
        var req = {
          searchCriteria: searchQ,
          lang : l,
          dataCategories : '',
          sessionId : this.sessionId
        }
        req.operationType =  'getArticleDetail';

        var self = this;
        var callback = function (e,r){
          result = JSON.parse($('<div>').html(r.result).text());
          if (result.isSuccess) {
            self.set(result.articleData);
          } else {
             self.trigger('errorFetching', result.message,self);
          }
        }
        pkb_mobile_proxy.getRemoteAction(JSON.stringify(req), callback);
      }
  });
  return KArticleModel;
});
