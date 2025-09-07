define([
  'jquery',
  'underscore',
  'backbone'
], function($,_, Backbone){

    var pkbUtils = function(){};

    _.extend(pkbUtils.prototype, {

      pathGlueChar  : ',',
      pathGlueKey   : '/',
      pathGlueValue : ':',
      defaultLangFilter : 'l:'+window.defaultLang,

      /*takes selecteOptions{
          {rootName: NAME1,  dataCategory:  DC1},
          {rootName: NAME2,  dataCategory:  DC2},
        }
        returns string :  /NAME1:DC1/NAME2:DC2/
      */
      buildFiltersPath : function (selectedOptions){

        tmpUrl = '';
        for(n in selectedOptions){
          if (selectedOptions[n].rootName != undefined)
            tmpUrl = tmpUrl +  selectedOptions[n].rootName + this.pathGlueValue +  selectedOptions[n].dataCategory + this.pathGlueKey;
        }
        return tmpUrl;
      },

      /* takes a string  /l:LANG/NAME1:DC1/NAME2:DC2/
        returns string :  /NAME1:DC1/NAME2:DC2/
      */
      getFilterString : function (fullString){

          langFull = this.getLanguage(fullString);
          langStart = langFull.indexOf('l:');
          if (langStart!= -1){
            l = langFull.substring(langStart+2)
          }
          filterStart = fullString.indexOf(langFull) + langFull.length + 1;
          filterString = fullString.substring(filterStart, fullString.length+1);
          return filterString;
      },


      getResultPageFilters : function (str){

        langStart = str.indexOf('l:');
        filterString = str.substring(langStart);

        return filterString;
      },


      getFiltersUrl : function (origLang,base){
        lang = $.trim(origLang);
        if ( ( lang.length == 0 ) || ( lang.indexOf('l'+this.pathGlueValue) < 0 ) ){
          rest = this.defaultLangFilter + this.pathGlueKey ;
        }else{
          lang = lang.substring(lang.indexOf('l'+this.pathGlueValue),lang.length)
          rest =  lang + this.pathGlueKey;
        }
        if (typeof base != 'undefined')
          rest = rest+base;
        rest = rest.replace('//','/');
        return rest;
      },

	  buildRequestObject : function (op,base){
	        l = window.defaultLang;
	        if (base != undefined){
	          //parse language option
	          l = this.getLanguage(base);
	          filterString = this.getFilterString(base);
	          filters = filterString.replace(/\//g,this.pathGlueChar);

	        }else{
	          filters = "";
	        }


        sessionID = this.readCookie(window.pkb2M_sessCookieName);

	        var req = {
	          searchCriteria: 'all',
	          lang : l,
	          dataCategories : filters,
          operationType : op,
          sessionId : sessionID
	        }
        return req;
	  },

      getLanguage : function (filterStr){
        start = filterStr.indexOf('l:');
        end = filterStr.indexOf('/',start+1);
        lang = filterStr.substring(start, end);//(0,start);


        return lang;
      },
      // replace the inner data category name by the main data category name
      // currently hardcoded to All //TODO : change this it must not be tied to this value
      removeFilter : function ( filterString,node) {
        oldPathName = node.rootName + this.pathGlueValue+node.dataCategory;
        newPathName = node.rootName + this.pathGlueValue+'All';
        return filterString.replace (oldPathName,newPathName);
      },

      /** COOKIES HANDLING **/
       createCookie : function (name,value,days) {
        if (days) {
                var date = new Date();
                date.setTime(date.getTime()+(days*24*60*60*1000));
                var expires = "; expires="+date.toGMTString();
        }
        else var expires = "";
        document.cookie = escape(name)+"="+escape(value)+expires+"; path=/";
      },

      readCookie : function (name) {
        var nameEQ = escape(name) + "=";
        var ca = document.cookie.split(';');
        for(var i=0;i < ca.length;i++) {
                var c = ca[i];
                while (c.charAt(0)==' ') c = c.substring(1,c.length);
                if (c.indexOf(nameEQ) == 0) return unescape(c.substring(nameEQ.length,c.length));
        }
        return null;
      },

      eraseCookie : function eraseCookie(name) {
        createCookie(name,"",-1);
      },

      /** modalBox **/


      //display message in a modal
      showErrorModal : function (msg){
          tpl = _.template($("#template-error-message").html());
          this.modalStyle = "small";
          this.openBox({content: tpl({'message' : msg})});
          //bind events to modalBox content
          var self = this;
          $("#closeDialog").bind("click", function (e) {
              self.closeBox();
          });
          this.modalStyle = "normal";
      },

    // Generate the HTML and add it to the document
    modalStyle : "normal",
    overlay : $('<div id="overlayMBOX"></div>'),
    modal : $('<div id="modalMBOX"></div>'),
    content : $('<div id="contentMBOX"></div>'),

    initBox : function (){
      this.modal.hide();
      this.overlay.hide();
      this.modal.append(this.content);
      $('body').append(this.overlay, this.modal);
    },
    // Center the modal in viewport
    centerBox : function () {
    	this.modal = $('#modalMBOX');
    	this.modal.css({
    		'top'			: $(window).height()/2,
    		'margin-top' 	: '-'+this.modal.height()/2+'px',
    		'left'			: $(window).width()/2,
    		'margin-left'	: '-'+this.modal.width()/2+'px'
    	});
    },

    // Open the modal
    openBox : function (settings) {
      this.modal    = $('#modalMBOX');
      this.overlay  = $('#overlayMBOX');
      this.content  = $('#contentMBOX');
      this.close    = $('#closeMBOX');
      this.content.empty().append(settings.content);
      if ( this.modalStyle == "normal" ){
    	  this.modal.addClass("normalModal").removeClass("smallModal");
      }else{
    	  this.modal.addClass("smallModal").removeClass("normalModal");
      }
      this.centerBox();
      this.modal.show();
      this.overlay.show();
      window.scrollTo(0,1);
    },

    // Close the modal
    closeBox : function () {
      this.modal    = $('#modalMBOX');
      this.overlay  = $('#overlayMBOX');
      this.content  = $('#contentMBOX');
      this.close    = $('#closeMBOX');
      this.modal.hide();
      this.overlay.hide();
      this.content.empty();
    },
    cutAt :  function (origText,max){

      if (origText.length > max){
        cutAt = origText.indexOf(' ',(max-5));
        if (cutAt <= 0) {cutAt = reply.Body.length ;}
        origText = origText.substring(0,cutAt) + '...';
      }

      return origText ;
    },

    deviceIsAndroid : function (){
      return ( /Android/i.test(navigator.userAgent) );
    },
    deviceIsWebOS : function (){
      return ( /webOS/i.test(navigator.userAgent) );

    },
    deviceIsIPhone : function (){
      return ( /iPhone/i.test(navigator.userAgent) );

    },
    deviceIsIPad : function (){
      return ( /iPad/i.test(navigator.userAgent) );

    },
    deviceIsBlackBerry : function (){
      return ( /BlackBerry/i.test(navigator.userAgent) );

    },
    deviceIsIPod : function (){
      return ( /iPod/i.test(navigator.userAgent) );

    },
    /*  sanitize searchString     */
    sanitizeSearchString : function (origText){
      return origText;
    }
    });
    return pkbUtils;
});
