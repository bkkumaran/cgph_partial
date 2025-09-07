define([
    'jquery',
    'underscore', 
    'backbone'
    ], function($, _, Backbone ){

    var fMenuItemView = Backbone.View.extend({
 
        template: _.template($('#template-filterItem').html()),

        tagName : 'article',
         
        initialize: function() {
            this.parent = this.options.parent;
            this.childs = [];
            if ( this.model.childs == undefined ) this.model.childs = [];
            if ( this.model.childs.length > 0 ){
            	for ( var i=0; i<this.model.childs.length;i++ ){
            		var mItemView = new fMenuItemView( { model : this.model.childs[i], parent : this.parent } );
              		this.childs.push(mItemView);
            	}
            }
            this.viewState = 'collapsed';
            this.selected = false;
            if ( this.model.name == undefined ) this.model.name = "NoFilter";
        },
        
        render: function(){
        	this.$el.html(this.template( _.extend(this.model,{ viewState : this.viewState, selected : this.selected }) ));
        	var self = this;
        	this.$el.find('div:first').click(function(e){
        		self.itemclick(e);
        	});
            var childsContainer = this.$el.find('.childs');
        	for ( var i=0; i<this.childs.length;i++ ){
            	childsContainer.append( this.childs[i].render().el );
            }
            return this;
        },
        
        checkAndMark: function(nodeData){
        	if ( nodeData.dataCategory == undefined && this.model.name == "NoFilter" ) return this;
        	if ( this.model.name == nodeData.dataCategory){
        		return this;
        	}else{
        		if ( this.childs.length > 0 ){
        			for ( var i=0; i<this.childs.length; i++ ){
        				var ret = this.childs[i].checkAndMark(nodeData);
        				if ( ret != false ){
        					this.viewState = 'expanded';
        					this.render();
        					return ret;
        				}
        			}
        		}else{
        			return false;
        		}
        	}
        	return false;
        },
        
        itemclick: function(e){
        	this.viewState = this.viewState == 'collapsed' ? 'expanded' : 'collapsed';
        	this.render();
        	
        	this.$el.find('div:first').addClass('blocked');
            this.parent.$el.find('.checkMark').removeClass('checkMark');
            this.parent.$el.find('.blocked').addClass('checkMark').removeClass('blocked');
            
        	this.parent.selectFilterOption( this.model.dcIndex ,
            		this.model.rootName,
            		this.model.name,
            		this.model.rootPath,
            		this.model.label);
        }
        
    });
    
    return fMenuItemView;
});