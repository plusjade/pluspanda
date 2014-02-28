define([
    'jquery',
    'underscore',
    'backbone'
], function($, _, Backbone) {

    return Backbone.Router.extend({
        routes: {
            "*page": "page"
        }
        ,
        initialize : function(App) {
            this.App = App;
            this.$main = $('#main-wrapper');
        }
        ,
        page : function(route) {
            var self = this;
            $.ajax({
                url : "/" + route,
            })
            .done(function(view) {
                self.$main.html(view);
                self.call(route);
            })
        }
        ,
        start : function() {
            Backbone.history.start({ pushState: true, silent: true, hashChange : false });
            this.call(window.location.pathname.slice(1));
        }
        ,
        call : function(page) {
            if(typeof this[page] === "function") {
                this[page]();
            }
        }
        ,
        'admin/manage' : function() {
            new this.App.ManageView();
        }
        ,
        'admin/collect' : function() {
            new this.App.CollectView();
        }
        ,
        'admin/account' : function() {
            new this.App.AccountView();
        }
        ,
        'admin/widget' : function() {
            new this.App.WidgetView();
        }
        ,
        'admin/widget/editor' : function() {
            new this.App.EditorView();
        }

    });
});
