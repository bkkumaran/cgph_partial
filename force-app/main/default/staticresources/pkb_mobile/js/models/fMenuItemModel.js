define([
  'underscore',
  'backbone',
], function(_, Backbone) {

  var filterItem = Backbone.Model.extend({
  	defaults : 	{
                    "label": "",
                    "depth": 1,
                    "name" :"noName",
                    "childs": []
            	}
  });
  return filterItem;
});
