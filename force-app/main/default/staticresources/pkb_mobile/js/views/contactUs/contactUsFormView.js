define([
  'jquery',
  'underscore',
  'backbone',
  'pkbUtils',
  'fileUpload'], function ($, _, Backbone, utilsObj) {

  var contactUsForm = Backbone.View.extend({

    el: "div#homeContainer",

    utils: new utilsObj,

    template: _.template($("#template-contactUs-QuestionForm").html()),

    events: {
      "click div#emoIconBtn"  		: "displayEmotionOptions",
      "click div.emoIconOption"		: "emoticonSelection",
      "click div#geoBtn"      		: "checkGeolocalization",
      "click div#picBtn"      		: "checkPictureUpload",   
      "click img.thumb"       		: "cancelCurrentPictureUpload",
      "click #cancelBtnContactFlow" : "cancelContact",
      "click div#askBtn"      		: "continueAction",
      "keyup textarea"        		: "enableContinueBtn"
    },

    initialize: function () {
      this.$el = $("div#homeContainer");
      this.parent = this.options.parent;
      //check browser support
      this.browserUploadEnabled = this.controlBrowserSupport();
      this.maxFiles = this.parent.appView.router.setupModel.getMaxFilesToUpload();
      if (this.maxFiles ==1 ){
         $('#filesInput').removeAttr("multiple")
      }
      this.render();
    },

    render: function () {
      emoIcons =  this.parent.appView.router.setupModel.getEmoIconsTypes();
      //local data
      searchStr = this.parent.localData.get('questionBody');
     // searchStr = decodeURIComponent(searchStr).replace(/\n\r?/g, '\r\n');


      lDIcon   = this.parent.localData.get('emoIcon');
      emoIcon = _.contains(emoIcons, lDIcon ) ? lDIcon : '';
      geoLoc =  !( this.parent.localData.get('latitude') == null || this.parent.localData.get('longitude') == null ) ;
      picsAdded = document.getElementById('filesInput').files.length;//( $('span[data-status="pending"]').size() > 0  );
      sanitizedBody = decodeURIComponent(searchStr).replace(/\n\r ?/g, '\r\n') ;
      var dataToTemplate = {
    		  'questionBody': sanitizedBody,
    	      'emoIcons'    : emoIcons,
    	      'type'		: (this.options.router.afterSumit != undefined ? this.options.router.afterSumit : "n"),
            'emoIcon' : emoIcon,
            'geoLoc' : geoLoc,
            'picAdded' : picsAdded
      };
      var html = this.template(dataToTemplate);
      $(this.el).html(html);
      //enable ask
      if (searchStr != undefined && searchStr.length >=3)
        $('#askBtn').removeClass('buttonGreenInactive');

      if (this.browserUploadEnabled){

        //remove all previous thumbnails
        $('#picThumbnail span').remove();

        var self = this;
        $('#filesInput').change(function(e) {
          var files = e.target.files; // FileList object
          if  (files.length > self.maxFiles ) {
                str = pkb2_LANG.get('error_reach_max_uploaded_files').replace('NNN',self.maxFiles);
                self.utils.showErrorModal(str);
          }
          self.handleFileSelect(e);
          changeToActiveIcon = ($(this).val() == ''); 
          self.toggleIconClass($('div#picBtn'), changeToActiveIcon);
        });
        
        //if there were pictures, replace the thumbnails
        if (picsAdded){
          for(i = 0; i < document.getElementById('filesInput').files.length; i++){
            //Determine total file display size
            this.createThumbView(document.getElementById('filesInput').files[i],false);
          }  
        }
        
      }
      this.utils.initBox();
    },
    
    renderAgain: function(){
    	this.delegateEvents();
    	this.render();
    },
    
    cancelContact: function (e) {
      this.cancelAllPicturesUpload();
    	this.options.appView.contactUsView = undefined;
    	this.cleanup();
    	this.parent.appView.router.filters = this.parent.appView.router.filters.split("/")[0]+"/";
    	for ( var index in this.parent.appView.selectedOptions ){
    		if ( index > 0 ){
    			this.parent.appView.selectedOptions[index] = {
                        'rootName'		: undefined,
                        'dataCategory'	: undefined,
                        'rootPath'		: 'undefined:undefined',
                        'label'			: undefined
                    };
    		}
    	}
    	this.parent.appView.router.navigate("/home/",true);
    },

    /*   VALIDATIONS    */
    validateSearch: function () {
      errors = false;
      //question Title 
      trimmed = $('textarea').val().trim();
      errorStr = '';
      if (trimmed.length == 0) {
        errorStr = pkb2_LANG.get('error_question_empty')+'\n';
        errors = true;
      } else if (trimmed.length >= 1000) {
        errorStr += pkb2_LANG.get('error_question_length').replace('NNN','1000');
        errors = true;
      }
      if (errors) {
        this.showError(errorStr);
      }
      return errors;
    },

    /*enable Ask button when text is greater that 3 chars*/
    enableContinueBtn : function (){
      if ($.trim($('textarea').val()).length >=3)
        $('#askBtn').removeClass('buttonGreenInactive');
      else  
        $('#askBtn').addClass('buttonGreenInactive');
    },

    continueAction: function () {

      value = $.trim($('textarea').val());
    
      if (value.length < 3) return;

      
      if (!this.validateSearch()) {
        value = encodeURIComponent($.trim($('textarea').val().replace(/\n\r?/g,'\n\r ')));
        //value = encodeURIComponent($.trim($('textarea').val()));
        this.parent.localData.set({
          questionBody: value
        });      
        this.cleanup();
          this.parent.renderResultsList(value);
      }
    },

    /* for Icon Actions selection deSelection*/
    toggleIconClass: function (obj, isSelected) {
      if (!isSelected) {
        //change class and call action
        $(obj).removeClass('unSelected');
        $(obj).addClass('selected');
      } else {
        //change class and call action
        $(obj).addClass('unSelected');
        $(obj).removeClass('selected');
      }
    },

    /* EMOTICONS*/

    emoticonSelection: function (e) {

      var emoId = $(e.currentTarget).attr('id');
      var isSelected = $(e.currentTarget).hasClass('unSelected');

      if (isSelected) {
        this.parent.localData.set({
          emoIcon: ' '
        });
        $(e.currentTarget).removeClass('selected');
        this.toggleIconClass($('div#emoIconBtn'), isSelected);
      } else {
        this.parent.localData.set({
          emoIcon: emoId
        });
        $(e.currentTarget).siblings().removeClass('selected');
        $(e.currentTarget).addClass('selected');
        $(this.el).find('#emoticonsOptions').hide();
        $('div#emoIconBtn').addClass(emoId);
        $('div#emoIconBtn').removeClass('unSelected');
      }
    },

    displayEmotionOptions: function (e) {

      if ($(this.el).find('#emoticonsOptions:visible').length > 0) {
        $(this.el).find('#emoticonsOptions').hide();
      } else {
        //remove previous options
        $('div#emoIconBtn').attr('class','icon unSelected');
        this.parent.localData.set({
          emoIcon: ' '
        });
        $(this.el).find('#emoticonsOptions').show();
      }
    },

    /* GEOLOCALIZATION */

    showGeolocalization: function (position) {
      this.$el.find('#formDATA').html(str);
    },

    checkGeolocalization: function (e) {
      var isSelected = $(e.currentTarget).hasClass('selected'); 

      if (isSelected) {
        // display unselected icon
        this.toggleIconClass($(e.currentTarget), isSelected);
        //remove values from model
        this.parent.localData.set({
                                    latitude: null,
                                    longitude: null});
      } else {
        //check if browser supports geoLoc 
         var self = this;
        if (navigator.geolocation) {
          var callback = function (position) {
 
            self.parent.localData.set({
              latitude: position.coords.latitude
            });
            self.parent.localData.set({
              longitude: position.coords.longitude
            });
           self.toggleIconClass($(e.currentTarget), isSelected);

          }
          var errorHnd = function (err) {
            if (err.code == 1) {
              self.utils.showErrorModal(pkb2_LANG.get('error_access_denied'));
            } else if (err.code == 2) {
              self.utils.showErrorModal(pkb2_LANG.get('error_position_unavailable'));
            }
          }
          navigator.geolocation.getCurrentPosition(callback, errorHnd);
        } else { 
          str = pkb2_LANG.get('error_geoloc_not_supported');
          self.showGeolocalization(str);
        }
      }
    },

    /** PHOTO UPLOAD  **/

    controlBrowserSupport : function (){
      res = false;
      if (  typeof File != 'undefined' && 
            typeof FileList != 'undefined' && 
            typeof FileReader != 'undefined')

        res= true;

      return res;
    },

    createThumbView : function (f,full){


        var self = this;
        var reader = new FileReader();

        // Closure to capture the file information.
        reader.onload = (function(theFile) {
          return function(e) {
            // Render thumbnail.
            fileIndex = $('img.thumb').size();
            if ( self.maxFiles > parseInt(fileIndex) ){
            
              var thumbSpan = document.createElement('span');
              thumbSpan.innerHTML = ['<img class="thumb" data-index = "'+fileIndex+'" src="', 
                                      e.target.result,
                                      '" title="', escape(theFile.name), '"/>'].join('');
              $('#picThumbnail').append(thumbSpan);
              if (full){
                var span = document.createElement('span');
                $(span).addClass('upload');
                $(span).attr('data-status','pending');
                $(span).attr('data-index',fileIndex);
                $('.uploadBox').append(span);
              }
            
            }
          };
        })(f);
        // Read in the image file as a data URL.
      reader.readAsDataURL(f);


    },


    handleFileSelect : function (evt) {
    
      var files = evt.target.files; // FileList object

      // Loop through the FileList and render image files as thumbnails.
      for (var i = 0, f; f = files[i]; i++) {

      // Only process image files.
        if (!f.type.match('image.*')) {
          continue;
        }
        this.createThumbView(f,true);
      }

      this.toggleIconClass($('div#picBtn'), false);
  },

  removePictureUploadeElements : function (){

      $(".upload").remove();
      $("input[type='file']").val('');
      $('#picThumbnail').html('');

  },

  cancelAllPicturesUpload : function (){
        this.removePictureUploadeElements();
        this.toggleIconClass($('div#picBtn'), true);

  },

  cancelCurrentPictureUpload: function (e){

      fileIndex = $(e.currentTarget).attr('data-index');
      //remove file from upload array
      $(".upload[data-index='"+fileIndex+"']:first").remove();
      $(e.currentTarget).remove();
      if ( $('#picThumbnail img').length == 0 ){
      $("input[type='file']").val('');
      $('#picThumbnail').html('');
      this.toggleIconClass($('div#picBtn'), true);
      }

  },

  checkPictureUpload: function (e) {

      if (this.browserUploadEnabled){ 
          this.cancelAllPicturesUpload();
          $("input[type='file']").trigger('click');

          } else {
        //display message in a modal
          this.utils.showErrorModal(pkb2_LANG.get('error_geoloc_not_supported'));
        }
     
    },

    showError: function (msg) {
      alert(pkb2_LANG.get('error') + msg);
    },

    cleanup: function () {

      //remove change event form file input
      $('#filesInput').unbind('change');

      this.undelegateEvents();
      $(this.el).empty();
    }
  });
  return contactUsForm;
});