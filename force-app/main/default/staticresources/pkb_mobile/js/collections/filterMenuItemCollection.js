define([
  'underscore',
  'backbone',
  'models/fMenuItemModel'
  ], function(_, Backbone, fMenuItemModel ){  
	var fMItemCollection = Backbone.Collection.extend({
		model: fMenuItemModel
 	});
    return fMItemCollection;
});