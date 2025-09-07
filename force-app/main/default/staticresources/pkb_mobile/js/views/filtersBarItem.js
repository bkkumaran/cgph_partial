define([
    'jquery',
    'underscore', 
    'backbone',
    'pkbUtils'
    ], function($, _, Backbone , utilsObj){

    var filterItemView = Backbone.View.extend({
 
        template: _.template($('#template-PKBSelectedFiltersOption').html()),
        className: 'filterSelItem',
        tagName: "li",
        
        utils : new utilsObj(),

        render: function () {
            labelValue = this.resolveLabelToDisplay();
        	$(this.el).html(this.template({'name': labelValue}));
            if (   window.rootRelations[this.options.node.label] != undefined && 
                    ( labelValue == window.rootRelations[this.options.node.label]) )
                $(this.el).addClass('defaultValue');
            return this;
        },
        
        cleanup: function() {
            this.undelegateEvents();
            $(this.el).empty();
        },
        
        resolveLabelToDisplay: function(){
        	var ret = this.options.node.label;
        	for ( var key in this.options.appView.selectedOptions ){
        		var currentElement = this.options.appView.selectedOptions[key];
        		if ( currentElement.rootName == this.options.node.rootName ){
        		     var currentElementRootPathVector = currentElement.rootPath.split(":");
        		     ret = window.rootRelations[ currentElementRootPathVector[currentElementRootPathVector.length-1] ] ;
                     if (typeof ret == "undefined" && currentElementRootPathVector[0] =='l' ){
                        ret = window.rootRelations['l'];
                     }
                     else
        		      if ( currentElementRootPathVector[currentElementRootPathVector.length-1] == 'All' ) 
                            ret = "All";
        		     break;
        		    }else{
                        //top level category when no value has been selected
                        if ( window.rootRelations[ret] != undefined ) 
                                ret = window.rootRelations[ret];
                    }
        	}
        	return ret;
        },
         
        events : {
            'click' : 'itemclick'
        },
        
        itemclick: function(e){
            e.preventDefault();
            e.stopPropagation();
            this.trigger('itemClicked',this);
        }
    });
    return filterItemView;
});