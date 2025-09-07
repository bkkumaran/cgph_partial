  define([
  'underscore',
  'backbone',
], function(_, Backbone) {
  var KArticleModel = Backbone.Model.extend({
    initialize: function(data){
      this.localData = data.setupD;
      this.reset(data.setupD);
    },
    reset: function(arguments){
        this.set(arguments, {silent: true});
        this.attributes = arguments ;
        if (typeof this.onReset == 'function' ) this.onReset();
    },
    isContactUsEnabled : function (){
      return this.get('Contact_Us_Available')=="true";
    },

    isLiveAgentEnabled : function (){
      return this.get('LA_Enabled')=="true";
    },

    isMultiLanguageEnabled : function(){
    	return this.get('multiLanguageEnabled')=="true";
    },
    
    isSupportCallEnabled : function (){
      return this.get('supportCallEnabled')=="true";
    },

    getMaxFilesToUpload : function (){
      return this.get('maxAllowedFilesToUpload');
    },
    //
    getMaxRelatedArticles : function (){
      result = 0;
      if ( ! isNaN(this.get('relatedArticleMaxResults'))){
        result = parseInt(this.get('relatedArticleMaxResults'));
      }
      return result;
    },

    getMaxContactUsResults : function (){
      return this.get('contactUsMaxResults');
    },

    getCaseTypes : function (){
      auxStr = this.get('caseType');
      ret = new Object;
      if (auxStr.indexOf(';')> -1){ 
        lpart = auxStr.split(';');
        for(part in lpart ){ 
          if (typeof lpart[part] =="string") { 
              tmp = lpart[part].split(':');
              if (tmp[0]=='')
                ret[tmp[1]]= tmp[1];
              else
                ret[tmp[0]]= tmp[1];
              }
          }
      }
      return ret;
    },
    getEmoIconsTypes : function (){
      result = new Object;
      auxStr = this.get('caseEmoIcons');
      auxStr = auxStr.replace(';','');
      lpart = auxStr.split(';'); 
      for(k in lpart) 
        if (typeof lpart[k] == 'string')
              result[k]=lpart[k];
      return result;
    }
  });
  return KArticleModel;
});
