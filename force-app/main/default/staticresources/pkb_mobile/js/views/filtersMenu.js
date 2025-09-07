define([
  'jquery',
  'underscore',
  'backbone',
  'views/fMenuItemView'
], function($, _, Backbone, fMenuItemView){

  var menuView = Backbone.View.extend({

    localdata : {}, 

    el: '#homeContainer ul',

    initialize : function() {
      this.localdata = this.options.localdata;
      this.appView = this.options.appView;
      
      this.fMenuItemViews = [];
      for ( var i=0; i<this.options.localdata[0].childs.length; i++ ){
  		var mItemView = new fMenuItemView( { model : this.localdata[0].childs[i], parent : this } );
  		this.fMenuItemViews.push(mItemView);
  	  }
      this.render();
      this.resolveSelectedValue();
    },
    
    resolveSelectedValue: function(){
    	var nodeData = this.options.selectedValues;
    	var response = null;
    	for ( var i=0; i<this.fMenuItemViews.length;i++ ){
    		response = this.fMenuItemViews[i].checkAndMark(nodeData);
    		if (response != undefined && response != null && response != false) break;
    	}
    	if ( response != null && response != false ) response.$el.find('div:first').trigger('click');
    },

    selectFilterOption : function (dcIndex, rName,dName, rootPath,label){
      this.appView.selectFilterOption(dcIndex,rName,dName,rootPath,label);
    },

    render: function(){
       var template = _.template($('#template-filterItemRoot').html());
       //top level category when no value has been selected
       data = _.extend({},this.options.localdata[0] ) ;

      if (  this.options.localdata[0].label != undefined &&
            window.rootRelations[this.options.localdata[0].label ] != undefined ) {
          rootLabel = window.rootRelations[this.options.localdata[0].label ];
          data = _.extend(data,{label :rootLabel } ) ;
      }
      this.$el.append(template(data));
       
      for ( var i=0; i<this.fMenuItemViews.length;i++){
    		this.$el.append(this.fMenuItemViews[i].render().el);
		  }
    },
    
    cleanup : function (){
      this.undelegateEvents();
      $(this.el).empty();
    }

  });

  return menuView;
  
});
