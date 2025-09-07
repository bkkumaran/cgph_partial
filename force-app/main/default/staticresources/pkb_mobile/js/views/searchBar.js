define([
  'jquery',
  'underscore',
  'backbone',
  'pkbUtils'
], function($, _, Backbone, utilsObj){

  var headerView = Backbone.View.extend({

    el : "#searchBar",

    utils : new utilsObj(),

    events: {
            "click img.cloudLogo" : "redirectHome",
            "click img.backBtn"	  : "goBack",
            "click #cancelBtn"	  : "cancelSearch",
            "keyup #searchText"   : "searchArticles",
            "click a#searchIcon"  : "doSearch",
            "focusin #searchText" : "fIn",
            "focusout #searchText": "fOut"
    },

    template: _.template($("#template-PKBSearchBar").html()),

    initialize:function() {
        this.isSingleView = this.options.isSingleView == undefined ? false : this.options.isSingleView;
        if ( this.options.contactFlow == undefined ) this.options.contactFlow = false;
        this.render();
        this.expandedView = false;
        this.utils.initBox();
    },

    fIn: function(e){
    	window.scrollTo(0,1);

    	if ( $('.titlePreSearchFlow').length > 0 ){
    		$('.preSearchFlow').css({ position : 'relative' });
    		$('.contentPreSearchFlow').css({ 'margin-top' : '2px' });
    	}

    	this.expandSearchView();
    	$('#searchBar').removeClass('appheaderInPlace').addClass('appHeaderFocused');
    	$('.articleDetailContainer').css( { 'margin-top' : 0 } );
    	$('#filtersBar').css( { 'margin-top' : 0 } );
    	$('a.cancelBtn').show();
    	$("#content").removeClass("featuredSectionWithoutFiltersBarHome");
      $("#content").removeClass("featuredSectionWithoutFiltersBarSearchFlow");
    },

    fOut: function(e){
    	if ( $('.titlePreSearchFlow').length > 0 ){
    		$('.preSearchFlow').attr('style',function(){ return "";	});
    		$('.contentPreSearchFlow').attr('style',function(){ return ""; });
    	}else{
    		$('#searchBar').removeClass('appHeaderFocused').addClass('appheaderInPlace');
    	}
    	$('#filtersBar').attr('style', function(i, style){	return ""; });
    	$('.articleDetailContainer').attr('style', function(i, style){	return ""; });
    	this.displayPreSearchBar();
    	window.setTimeout( function(){ $('a.cancelBtn').hide(); }, 500 );
    	window.setTimeout( function(){ window.scrollTo(0); }, 550 );
    	if ( $('#filtersBar').length < 1 ){
    		if ( $('.titlePreSearchFlow').length > 0 ){
          $("#content").addClass("featuredSectionWithoutFiltersBarSearchFlow");
        }else{
          $("#content").addClass("featuredSectionWithoutFiltersBarHome");
        }
    	}

    },

    render: function(){
      var html = this.template({ isSingleView : this.isSingleView, inContactFlow : this.options.contactFlow});
      $(this.el).append(html);

      //display search string
      qStr = '';
      if (this.options.router.qString != undefined && this.options.router.qString.length > 0){
      qStr = $.trim(this.options.router.qString);
      }
      else{
        //if we are back from the filters page just display the string
        if (this.options.router.tmpQString != undefined && this.options.router.tmpQString.length > 0)
           qStr = $.trim(this.options.router.tmpQString);
      }
      this.$el.find('#searchText').val(qStr);
      $("form#searchForm").bind("keypress", function (e) {
        if (e.keyCode == 13) {
          return false;
        }
      });
      window.scrollTo(0,1);
      if ( $('.contactUsTitle').length > 0 ){
    	  $('#searchBar').removeClass('appheaderInPlace').addClass('appHeaderFocused');
      }
    },

    expandSearchView : function (){
        if ( this.$el.find('.cloudLogo').length > 0 ){
        	this.$el.find('.cloudLogo').hide();
        }else{
        	this.$el.find('.backBtnContainer').hide();
        }
        this.expandedView = true;
    },

    redirectHome : function (e){
      if (window.location.hash.substr(1,5)!='home/'){
        filtersURL = this.utils.getFiltersUrl(this.options.router.filters);
        this.options.router.navigate('home/'+filtersURL,true);
      }
    },

    goBack : function(){
    	this.cleanup();
    	window.history.back(1);
    },

    displayPreSearchBar : function (){
      this.options.router.qString = '';
      if ( this.$el.find('.cloudLogo').length > 0 ){
    	  this.$el.find('.cloudLogo').show();
      }else{
    	  this.$el.find('.backBtnContainer').show();
      }
      this.expandedView = false;
    },

    cancelSearch : function (){
    	this.displayPreSearchBar();
    	$('#searchText').val("");
    },

    validateSearch : function(){

      errors = false;
      //question Title
      trimmed = $('#searchText').val().trim();
      errorStr = '';

      /*if (this.areValidSearchCharacters(trimmed)){
          errorStr = pkb2_LANG.get('error_invalid_characters')+'\n';
          errors = true;
      }
      else*/
      if (trimmed.length == 0){
          errorStr = pkb2_LANG.get('error_search_string_empty')+'\n';
          errors = true;
      } else
          if (trimmed.length < 3){
              errorStr += pkb2_LANG.get('error_search_string_min_length').replace('NNN','3')+'\n';
              errors = true;
          }else
          if (trimmed.length > 255){
              errorStr += pkb2_LANG.get('error_search_string_length_to_long').replace('NNN','255');
              errors = true;
          }
        if (errors){
            this.showError(errorStr);
        }
        return errors;
    },

    searchArticles: function(e){
      if ( e.keyCode == 13 ){
        this.doSearch(e);
      }
    },

    areValidSearchCharacters: function (text){

      invalidFound = false;
      var re = /([!.,?/<>;:{}@#$%^&*()])/;
      invalidFound = re.test(text);
      if ( !invalidFound ){
        var re = /"{2,}/;
        invalidFound = re.test(text);

      }
      //var text = $('#searchText').val().replace(/([!.,?/<>;:{}@#$%^&*()])/mg, '').replace(/"{2,}/g, '"');
      //$('#searchText').val(text);
      return invalidFound;
    },

    doSearch : function (e){
      e.stopImmediatePropagation();
      var value = $('#searchText').val().trim();
      //remove temporal string used to hold string while we display the filters page
      this.options.router.tmpQString = "";
      //this.options.router.qString = value;
      if ( this.options.contactFlow != undefined && this.options.contactFlow != false && ! this.validateSearch() ){
    	  this.trigger("performSearch",value);
    	  return;
      }
      if (! this.validateSearch() ) {
          //this.options.router.navigate('results'+this.utils.pathGlueKey+value+this.utils.pathGlueKey+this.options.router.filters,true);
          url ='results';
          url += this.utils.pathGlueKey + encodeURIComponent(value) ;
          url += this.utils.pathGlueKey + this.utils.getResultPageFilters(this.options.router.filters);
          this.options.router.navigate(url,true);
      }
    },

    showError : function (msg){
      this.utils.showErrorModal( msg);
    },

    cleanup : function (){
      this.undelegateEvents();
      $(this.el).empty();
      $(this.el).off();
    }
  })
  return headerView;
});
