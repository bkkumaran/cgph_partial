  define([
    'underscore',
    'backbone',
    'pkbUtils'
    ], function (_, Backbone, pkbUtils) {

    var feedbackModel = Backbone.Model.extend({
      utils: new pkbUtils,
      defaults: {
        isDeferred: false,
        articleNumber: '123456',
        feedbackComments: 'not good at all',
        searchString: 'what would the others do',
        source: 'origin',
        kavId: '0',
        title: 'an article a day'

      },
      submitData: function () {
        this.reqObj = this.utils.buildRequestObject('submitFeedBack');
        //Request Object 
        this.reqObj.articleFeedback = this.attributes;
        var self = this;
        var callback = function (e, r) {
          result = JSON.parse($('<div>').html(r.result).text());
          if (result.isSuccess) {
            self.trigger('successSubmit', result.message,self);
          } else {
            self.trigger('errorSubmit', result.message,self);
          }
        }
        pkb_mobile_proxy.getRemoteAction(JSON.stringify(this.reqObj), callback);
      }
    });
    return feedbackModel;
  });