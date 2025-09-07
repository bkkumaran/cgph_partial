define([
  'jquery',
  'underscore',
  'backbone'
  ], function ($, _, Backbone) {

  var kArticleDetailFeedBack = Backbone.View.extend({
	  
	  tagName: 'div',
	  className: 'feedBackMain',
	  
	  events: {
		  'click .sendNegativeFeedback'   	: 'sendIt',
		  'click .cancelNegativeFeedback' 	: 'cancelIt',
		  'keyup textarea.feedBackTextArea' : 'enableSendBtn'
	  },
	  
	render: function(){
		  var template = _.template($("#template-KA-feedBackForm").html());
		  this.$el.html(template());
		  $('body').find('.feedBackMain').remove();
		  $('body').append( this.el );
	},
	  

	/*enable send button when test is greater that 3 chars*/
	enableSendBtn : function (){
		if ($.trim($('textarea.feedBackTextArea').val()).length >=3)
		$('.sendNegativeFeedback').removeClass('buttonGreenInactive');
		else  
		$('.sendNegativeFeedback').addClass('buttonGreenInactive');
	},

	  sendIt: function(){
		value = $.trim($('textarea.feedBackTextArea').val());
    
		if (value.length < 3) return;
		  this.trigger('sendFeedback',this);
	  },
	  
	  cancelIt: function(){
		  this.trigger('cancelSubmit',this);
	  }
	  
  });

  return kArticleDetailFeedBack;
})