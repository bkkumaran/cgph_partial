define([
    'jquery',
    'underscore', 
    'backbone',
  'pkbUtils'
    ], function($, _, Backbone , pkbObj){

    var articleListItemView = Backbone.View.extend({
 
        tagName: 'article',
        className:'articleItem',
        utils : new pkbObj(),
        template: _.template($('#template-KAVItem').html()),
        events: {
            "click " : "showArticleDetail"
        },

        initialize: function() {
            this.appView = this.options.appView;
            this.router = this.appView.router;
            this.isKeyword = (this.options.isKeyword == undefined) ? false : this.options.isKeyword;
            _.bindAll(this, 'render');
        },
        
        render: function () {

            msDate  = new Date(this.model.get('lastPublishedDate')).getTime();
            if (this.model.get('elapsed') != null)
                elap = this.model.get('elapsed');
            else
                elap = this.model.get('lastPublishedDate');
                
            this.model.set('lastPublishedDate',elap);
            this.model.set('isKeyword' , this.isKeyword );


        
            //substring for title
            tmpTitle =  this.utils.cutAt(this.model.get('title'),140); 
            this.model.set('title', _.escape(tmpTitle));
            this.$el.html(this.template(this.model.toJSON())); 

            return this;
        },
        
        cleanup: function() {
            this.undelegateEvents();
            $(this.el).empty();
        },

        showArticleDetail: function(e){
            this.trigger("elementClicked",this); 
        } 
    });
    return articleListItemView;
});