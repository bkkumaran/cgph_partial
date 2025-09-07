define([
  'jquery',
  'underscore',
  'backbone',
  'pkbUtils',
  'views/filtersBarItem',
  'libs/iscroll/iscroll'
], function($, _, Backbone, utilsObj, fbItem,iScroll){

  var filtersView = Backbone.View.extend({
    el : "#filtersBar",

    utils : new utilsObj,

    template: _.template($("#template-PKBFiltersBar").html()),

    initialize:function() {
      this.$el =  $("#filtersBar");
      this.menuBarItems = [];
      this.render();
    },

    render: function(){
      var html = this.template();
      $(this.el).append(html);
      this.populateOptionsView();
      //hotfix: do not display filter bar if app is monolingual and no datacategories has been setted up
      this.hideOrShowFiltersBar(window.root.childs);
    },

    hideOrShowFiltersBar: function(elements){
    	//pos 0 is always for language, so if size >= 2 is multilingual
    	if ( elements[0].childs.length < 2 && elements.length < 2 ){
    		$("#filtersBar").remove();
        if ( $('.titlePreSearchFlow').length > 0 ){
          $("#content").addClass("featuredSectionWithoutFiltersBarSearchFlow");
        }else{
          $("#content").addClass("featuredSectionWithoutFiltersBarHome");
        }
    	}else{
    		$("#content").removeClass("featuredSectionWithoutFiltersBarHome");
        $("#content").removeClass("featuredSectionWithoutFiltersBarSearchFlow");
    	}

    	//now only hide language selection if only exists one language
    	//if ( elements[0].rootName =='l' && elements[0].childs.length < 2 ){
    		//hiding first element that is always Language
    	//	$('#selectedOptions li:first').remove();
    	//}
    },

    populateOptionsView : function (){
      optList = this.buildOptList();
      for(o in optList){
        if ( (typeof optList[o] == "object") && ( optList[o].rootName  != undefined ) ){

          if ( !this.options.router.setupModel.isMultiLanguageEnabled() && optList[o].rootName == 'l'){
        	  //do nothing
          }else{
        	  l_fbItem = new fbItem({'node': optList[o],'appView': this.options.appView,'router': this.options.router});
              l_fbItem.on('itemClicked',this.showFiltersPage,this);
              this.menuBarItems.push(l_fbItem);
              $(this.el).find('#selectedOptions').append(l_fbItem.render().el);
          }
        }
      }
      window.scrollTo(0,1);
      this.handleFilterScroll();
      window.addEventListener('orientationchange', this.handleFilterScroll, false);
      window.addEventListener('resize', this.handleFilterScroll, false);
    },

    handleFilterScroll: function(){
    	//Iscroll for filter Bar
    	if ( $('#scroller').length == 0 ) return;
        $('#scroller').css({ width : $('#scroller').width() });
        $('#wrapper').css({ width : ($(window).width() -55) });

        if ( window.iScrollElement == undefined || window.iScrollElement == null ){
      	  window.iScrollElement = new window.iScroll('wrapper', { hScroll: true, vScroll: false, hScrollbar: false, vScrollbar: false });
        }else{
      	  window.iScrollElement.destroy();
      	  window.iScrollElement = null;
      	  window.iScrollElement = new window.iScroll('wrapper', { hScroll: true, vScroll: false, hScrollbar: false, vScrollbar: false });
        }
    },

    buildOptList : function(){
    	if ( window.root == undefined || window.root == null ) return null;
    	var ret = new Array;
    	_.each(window.root.childs,function(item){
    		var elm = {
    				rootName 		: item.rootName,
    				rootPath 		: item.rootPath,
    				dataCategory 	: item.name,
    				label			: item.label
    		};
    		ret.push(elm);
    	});
    	return ret;
    },

    showFiltersPage: function(clickedView){
      //if there is a search string save it to display later
      if ($('#searchText').length > 0){
        //i'm not escaping this cause it's not going to the url
        this.options.appView.router.tmpQString = $('#searchText').val().trim();
        this.options.appView.renderFilters(clickedView);
      }
    },

    cleanup : function (){
      this.undelegateEvents();
      $(this.el).empty();
    }

  });

  return filtersView;

});
