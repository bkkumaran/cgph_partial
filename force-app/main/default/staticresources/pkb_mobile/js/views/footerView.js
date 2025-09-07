define([
    'jquery',
    'underscore',
    'backbone',
    'pkbUtils',
    'views/contactUs/contactUsFooterView'], function ($, _, Backbone, utilsObj, contactUsFooterView) {

    var appFooter = Backbone.View.extend({
        initialize: function () {
            this.utils = new utilsObj();
        	this.appView = this.options.appView;
            this.$el = $("#footer");
            this.render();
        },

        render: function () {
            if (this.appView.router.setupModel.isContactUsEnabled()) {
                this.renderContactUsForm();
                $('body').css({ 'margin-bottom' : 101 });
            }else{
            	$('body').attr('style', function(i, style){
            		return "";
            	});
                this.$el.hide();
            }
        },

        renderContactUsForm: function (){
            this.cView = new contactUsFooterView({
                appView: this.appView
            });
        },

        cleanup: function (){
            this.undelegateEvents();
            $(this.el).empty();
        }
    });
    return appFooter;
});