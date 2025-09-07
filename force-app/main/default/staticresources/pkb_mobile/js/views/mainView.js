define([
    'jquery',
    'underscore',
    'backbone',
    'views/headerView',
    'views/homeView',
    'views/resultsView',
    'views/filtersPage',
    'views/footerView',
    'views/contactUs/contactUsView',
    'pkbUtils'], function ($, _, Backbone, headerView, homeView, resultsView, filtersView, footerView, contactUsView, pkbObj) {

    var mainView = Backbone.View.extend({
        el: $("div#homeContainer"),

        utils: new pkbObj(),

        template: _.template($("#template-PKBhome").html()),

        initialize: function () {
            this.router = this.options.router;
            this.selectedOptions = new Object();
            if (this.router.filters != undefined) this.populateSelectselectFilterOption();
        },

        populateSelectselectFilterOption: function () {

            dcList = this.router.filters.split(this.utils.pathGlueKey);
            for (n in dcList) {
                if ((typeof dcList[n] == 'string') && (dcList[n].indexOf(this.utils.pathGlueValue) >= 0)) {
                    p = dcList[n].split(this.utils.pathGlueValue);
                    ind = dataCList.indexOf(p[0]);
                    this.selectFilterOption(ind, p[0], p[1], dcList[n],window.rootRelations[p[1]]);
                }
            }
            //for data categories not yet selected apply default values
            for (d in dataCList) {
                if (this.selectedOptions[d] == undefined) {
                    if (!isNaN(d)) {
                        this.selectedOptions[d] = new Object();
                        tmpRootPath = dataCList[d].defaultCategory + this.utils.pathGlueValue + dataCList[d].defaultCategory;
                        this.selectedOptions[d] = {
                            'rootName'		: dataCList[d].rootName,
                            'dataCategory'	: dataCList[d].defaultCategory,
                            'rootPath'		: tmpRootPath,
                            'label'			: dataCList[d].label
                        };
                    }
                }
            }
        },

        selectFilterOption: function (dcIndex, rName, dName, rootPath,label) {
            if ( rName == 'No Filter' ){
            	this.selectedOptions[dcIndex] = {
                        'rootName'		: undefined,
                        'dataCategory'	: undefined,
                        'rootPath'		: 'undefined:undefined',
                        'label'			: undefined
                    };
            }else{
            	this.selectedOptions[dcIndex] = {
                        'rootName'		: rName,
                        'dataCategory'	: dName,
                        'rootPath'		: rootPath,
                        'label'			: label
                    };
            }

        },

        isParentOfSelected: function (dcIndex, rootPath) {
            res = false;
            if (this.selectedOptions[dcIndex] != undefined) {
                path = rootPath.split(this.utils.pathGlueValue);
                res = (this.selectedOptions[dcIndex].rootName == path[0]);
            }
            return res;
        },

        render: function () {
            var html = this.template();
            $(this.el).html(html);
        },

        renderHeader: function () {
            var appHeader = new headerView({
                el: $("header#app_header"),
                appView: this,
                router: this.router
            });
        },

        renderHome: function () {
        	if (this.contactUsView != undefined) this.contactUsView.resetData();
        	//clean possible old uploaded images
        	$(".upload").remove();$("input[type='file']").val('');$('#picThumbnail').html('');

        	this.renderHeader();
            var homePage = new homeView({
                appView: this
            });
            homePage.render();

            var fView = new footerView({
                appView: this
            });
        },
        renderResults: function () {
            this.renderHeader();
            var sResults = new resultsView({
                appView: this
            });
            sResults.render();
            var fView = new footerView({
                appView: this
            });
        },

        renderFilters: function (clickedView) {
            var fView = new filtersView({
                appView: this,
                router: this.router,
                elm: clickedView
            });
            fView.render();
        },

        renderContactUs: function () {
        	if ( this.contactUsView == undefined ){
        		this.contactUsView = new contactUsView({
                    appView: this,
                    router: this.router
                });
        	}else{
        		this.contactUsView.render();
        	}
        },

        renderContactUsFlow: function(state,chain){
        	if ( this.contactUsView == undefined ) this.renderContactUs();
        	else this.contactUsView.render(state,chain);
        },

        renderContactUsFlowSiView: function(state,chain,kId){
        	if ( this.contactUsView == undefined ) this.renderContactUs();
        	else this.contactUsView.renderSiView(state,chain,kId);
        },

        cleanup: function () {
            this.undelegateEvents();
            $(this.el).empty();
        }

    });
    return mainView;
});