// Filename: app.js
define([
  'jquery',
  'underscore',
  'backbone',
  'router'
], function($, _, Backbone, Router){

  var initialize = function(){

    //fetch setup data
    var req = {
      operationType: 'getSetup'
    }

    var that = this;
    var callback = function (e,r){
       if (e.type == "exception") {
          console.log(e)
        }else{
            setupValues  = JSON.parse($('<div>').html(r.result).text()).setup;
            // Pass in our Router module and call it's initialize function
            Router.initialize(setupValues);
        }

       var resolveScrollingPopAndFeat = function(){
    	   if ( $('.appHeaderFocused').length > 0 ){
    		   $('.fixedkavListTitle').remove();
    		   return;
    	   }

    	   var negative = null;
    	   $.each($('.kavListTitle'),function(){
    	   	var currentPos = $(this).offset().top;
    	       if ( currentPos - $(window).scrollTop() < 35 ){
    	       	negative = $(this);
    	       }
    	   });
    	   if ( negative != null ){
    	   	if ( $('.fixedkavListTitle').length < 1 ) $('<div>'+negative.text()+'</div>').addClass('fixedkavListTitle').appendTo('#content');
    	   	else $('.fixedkavListTitle').text( negative.text() );
    	   }else{
    	   	$('.fixedkavListTitle').remove();
    	   }
       };

       window.addEventListener('touchmove', function(event) {
    	   resolveScrollingPopAndFeat();
       });

       window.addEventListener('touchstart', function(event) {
    	   resolveScrollingPopAndFeat();
       });

       window.addEventListener('touchend', function(event) {
    	   resolveScrollingPopAndFeat();
       });

       $(window).scroll(function () {
    	   resolveScrollingPopAndFeat();
       });
    }

    //Setting up Loader
    XMLHttpRequest.prototype.origOpen = XMLHttpRequest.prototype.open;
    var pkbLoader = function(method, url, async, user, password) {
    	var valImg = window.pkb_loaderImgSource != undefined ? '<img src="'+window.pkb_loaderImgSource+'">' : 'Loading';
	    this.addEventListener("readystatechange", function() {
	    	if ( this.readyState == 1 ){
          if ($('div#modalMBOX:visible').length == 0){
            if ( ($("body").find("#overlayGral")).length == 0 && ($("body").find("#loaderDiv")).length == 0){
              $('<div id="overlayGral"></div><div id="loaderDiv">'+valImg+'</div>').appendTo("body");
            }
          }

	    	}
	    	if ( this.readyState == 4 ){
	    		$("body").find("#overlayGral").remove();
	    		$("body").find("#loaderDiv").remove();
	    	}
	    }, false);
	    this.origOpen (method, url, async, user, password);
    };
    XMLHttpRequest.prototype.open = pkbLoader;
    pkb_mobile_proxy.getRemoteAction(JSON.stringify(req), callback);
  };

  return {
    initialize: initialize
  };
});
