// Filename: router.js
define([
    'jquery',
    'underscore',
    'backbone',
    'pkbUtils',
    'models/pkbCSetting',
    'views/mainView',
    'views/kArticleDetailView'], function ($, _, Backbone, utilsObj, pkbSetupModel, mainView, KArticleDetailView) {
	/* @ROUTER
        @setupModel		: Json detail for custom setting detail
        @filters 		: string with filter part of the url = dataC1:value/dataC2:value/
        @qString 		: string holding the searched value
        @afterSumit 	: When contact us is called, if mail=n; call=call; chat=chat; 
    */
    var AppRouter = Backbone.Router.extend({
        routes: {
            // Define URL routes
            'articles/:lang/:topic/:url' : 'showArticleFromUrl',
            'articles/:lang/:topic/:url/*rest' : 'showArticleFromUrl',
            'article/:lang/:kId/:s': 'showArticleDetail',
            //contactUs
            'contact/:fAction/:lang/*filters': 'showContactUs',
            'contactFlow/:fAction/:contactState/:chain/:lang/*filters': 'showContactUsState',
            'contactFlowS/:fAction/:contactState/:chain/:kId/:lang/*filters' : 'showArticleDetailContactFlow',
            //results page
            'results/:qString/:lang/*filters': 'showResults',
            'results/:qString/:lang*filters': 'showResults',
            //home page
            'home/:lang/*filters': 'showHome',
            // Default
            '*actions': 'defaultAction'
        }
    });
    
    var initialize = function (setupData) {
    	utils = new utilsObj();
    	var app_router = new AppRouter;
    	app_router.setupModel = new pkbSetupModel({
            setupD: setupData
        });
        window.pkb2M_sessCookieName = setupData.sessionCookieName;
        app_router.sessionId =  utils.readCookie(window.pkb2M_sessCookieName);




 		app_router.on('route:showArticleFromUrl', function (lang, topic,kUrl) {
            this.filters = utils.getFiltersUrl(lang);

            if ( this.kaDetail != undefined ){
              this.kaDetail.$el.empty();
              this.kaDetail.$el.off();
              this.kaDetail = undefined;
            }

            this.kaDetail = new KArticleDetailView({
                kArticleUrl: kUrl,
                router: this,
                source : 's'
            });
        });

        app_router.on('route:showArticleDetail', function (lang, kId,s) {
            this.filters = utils.getFiltersUrl(lang);

            if ( this.kaDetail != undefined ){
              this.kaDetail.$el.empty();
              this.kaDetail.$el.off();
              this.kaDetail = undefined;
            }

            this.kaDetail = new KArticleDetailView({
                kArticleId: kId,
                router: this,
                source : s
            });
        });

        app_router.on('route:showContactUs', function (fAction,lang, fValues) {
            this.filters = utils.getFiltersUrl(lang, fValues);
            this.afterSumit = fAction;
            if ( this.mainPageView == undefined ){
            	this.mainPageView = new mainView({
                    router: this
                });
            }
            
            if (this.setupModel.isContactUsEnabled()) this.mainPageView.renderContactUs();
            else this.mainPageView.renderHome();
        });
        
        app_router.on('route:showContactUsState', function (fAction,state,chain,lang,fValues){
            this.filters = utils.getFiltersUrl(lang,fValues);
            this.afterSumit = fAction;
            if ( this.mainPageView == undefined ){
            	this.mainPageView = new mainView({
                    router: this
                });
            }
            if(this.setupModel.isContactUsEnabled()){
            	this.qString = chain;
                this.mainPageView.renderContactUsFlow(state,chain);
                this.mainPageView.contactUsView.afterSumit = fAction;
            }else{
                this.mainPageView.renderHome();
            }
        });
        
        app_router.on('route:showArticleDetailContactFlow',function(fAction,state,chain,kId,lang,fValues){
        	this.filters = utils.getFiltersUrl(lang,fValues);
            this.afterSumit = fAction;
        	if ( this.mainPageView == undefined ){
            	this.mainPageView = new mainView({
                    router: this
                });
            }
            
            if(this.setupModel.isContactUsEnabled()){
                this.qString = chain;
                this.mainPageView.renderContactUsFlowSiView(state,chain,kId);
            }else{
                this.mainPageView.renderHome();
            }
        });
        
        app_router.on('route:showResults', function (qStr, lang, fValues) {
            var utils = new utilsObj();
            this.filters = utils.getFiltersUrl(lang, fValues);
            this.qString = decodeURIComponent(qStr);
            if ( this.mainPageView == undefined ){
            	this.mainPageView = new mainView({
                    router: this
                });
            }
            this.mainPageView.render();
            this.mainPageView.renderResults();
        });

        app_router.on('route:showHome', function (lang, fValues) {
            this.qString = '';
            this.filters = utils.getFiltersUrl(lang, fValues);
            if ( this.mainPageView == undefined ){
            	this.mainPageView = new mainView({
                    router: this
                });
            }
            this.mainPageView.render();
            this.mainPageView.renderHome();
        });


        app_router.on('route:defaultAction', function (lang, fValues) {
            this.filters = utils.getFiltersUrl(lang, fValues);
            if ( this.mainPageView == undefined ){
            	this.mainPageView = new mainView({
                    router: this
                });
            }
            this.mainPageView.render();
            this.mainPageView.renderHome();
        });
        Backbone.history.start();
    };
    return {
        initialize: initialize
    };
});