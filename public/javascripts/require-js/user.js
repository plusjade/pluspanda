define([
    'jquery',
    'underscore',
    'backbone'
], function($, _, Backbone) {
    return Backbone.Model.extend({
        url : function() {
            return '/users/' + this.id;
        }
    });
})