  define([
    'underscore',
    'backbone',
    'pkbUtils',
    'fileUpload'], function (_, Backbone, pkbUtils, fUploadObj) {
    var contactUsModel = Backbone.Model.extend({
      utils: new pkbUtils,
      fUpload: new fUploadObj,
      /*defaults: {
        firstName: '',
        lastName: '',
        email: '',
        reqType:'',
        questionBody: '',
        urlSearchQuery: '',
        latitude: null,
        longitude: null,
        emoIcon: ''
      },*/

      defaults : function (){

        return {
                  firstName: '',
                  lastName: '',
                  email: '',
                  reqType:'',
                  questionBody: '',
                  urlSearchQuery: '',
                  latitude: null,
                  longitude: null,
                  emoIcon: ''
                }
      },

      submitData: function () {
        this.reqObj = this.utils.buildRequestObject('processContact');
        //Request Object 
        this.reqObj.contactData = this.attributes;
        var self = this;
        var callback = function (e, r) {
          result = JSON.parse($('<div>').html(r.result).text());
          //contactDetails
          if (result.isSuccess) {
            self.uploadImage(result);
          } else {
            self.trigger('errorSubmit', result.message,self);
          }
        }
        pkb_mobile_proxy.getRemoteAction(JSON.stringify(this.reqObj), callback);
      },
      uploadImage: function (result) {
        attachmentId = result.caseId;
        if ($("input[type='file']").val() != '') this.fUpload.prepareFileUploads(document.getElementById('filesInput').files, attachmentId, this, result);
        else this.trigger('submitSuccess',result,this);
      }
    });
    return contactUsModel;
  });