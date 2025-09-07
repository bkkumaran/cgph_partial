define([
  'jquery',
  'underscore',
  'backbone',
  'pkbUtils',
  'views/filtersMenu' 
], function($, _, Backbone,utilsObj, fMenuView){

  var filtersView = Backbone.View.extend({

    utils: new utilsObj(),

    template: _.template($("#template-PKBFiltersPage").html()),  

    events : { 
      'click a#doneBtn' : 'goBack'
    },

    initialize : function() {
      this.el =  "div#homeContainer";
      this.$el =  $("div#homeContainer");
    },

    render: function(){
      var html = this.template();
      $(this.el).html(html);
      this.fMenu = new fMenuView({'localdata'		: this.resolveSelectedRoot(), 
                                  'appView'			: this.options.appView,
                                  'selectedValues'	: this.options.appView.selectedOptions[this.resolveSelectedRoot()[0].dcIndex]});
    },
    
    resolveSelectedRoot: function(){
    	for ( var i=0; i<root.childs.length;i++ ){
    		if ( root.childs[i].rootName == this.options.elm.options.node.rootName ) return [ root.childs[i] ];
    	}
    },
    
    goBack : function (){
		tmpOldLang = this.utils.getLanguage(this.options.router.filters);
		tmpUrl = this.utils.buildFiltersPath(this.options.appView.selectedOptions);
		tmpNewLang = this.utils.getLanguage(tmpUrl);

		//determine page to return to
		urlFragment =  Backbone.history.getFragment();
		if (urlFragment.indexOf('/') != -1){
			urlFragment = urlFragment.replace('contactFlowS','contactFlow');
			viewInDisplay = urlFragment.split('/')[0];
		}else{
			viewInDisplay = '';
		}
		
		qStr = (this.options.router.qString != undefined) ? this.options.router.qString : '';
		
		switch(viewInDisplay){
			case 'results':
					retURL = 'results/'+qStr+'/';
				break;
			case 'contactFlow': 
					retURL = urlFragment.substring(0,urlFragment.indexOf('l:'));
				break;
			default : 	retURL = 'home/';
				break;
		}



      this.cleanup();

     if (tmpOldLang != tmpNewLang ) { 
           tmpSearch = "?"+tmpNewLang.replace(':','=');
           originUrl = window.location.protocol + "//" + window.location.host;//window.location.origin
           tmpHref =   originUrl +window.location.pathname +tmpSearch+'#'+retURL+tmpUrl;
           window.location.href = tmpHref;
       }else{
		this.options.router.navigate(retURL+tmpUrl,false);
		//this.options.router.filters = window.location.hash.replace("#home/","");
		this.options.router.filters = tmpUrl;
		this.options.appView.render();
        switch(viewInDisplay){
			case 'results':
					 this.options.appView.renderResults();
				break;
			case 'contactFlow':
					 //this.options.appView.renderContactUsFlow();
					 state = '';
					 chain = '';
					 if (urlFragment.indexOf('/') != -1){
						parts = urlFragment.split('/');
						if (parts.length > 3){
							state = parts[2];
							chain = parts[3];
						}
					}
					 this.options.appView.renderContactUsFlow(state,chain);
					 
				break;
			default : 	this.options.appView.renderHome();
				break;
		}
        
      }
    },
    
    cleanup : function (){
      this.undelegateEvents();
      $(this.el).empty();
    }
  });
  return filtersView;
});
