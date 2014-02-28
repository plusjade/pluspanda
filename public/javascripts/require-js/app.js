define([
    'jquery',
    'underscore',
    'backbone',
    'router',

    'layoutView',
    'manageView',
    'collectView',
    'accountView',
    'widgetView',
    'previewView',

    'lib/showStatus',

    'vendor/addon',
    'vendor/facebox',
    'vendor/jquery.ui-1.10.2.min',
    'vendor/timeago.min'
], function($, _, Backbone, Router,
    LayoutView, ManageView, CollectView, AccountView, WidgetView, PreviewView,
    ShowStatus
){
    return { 
        utils : {
            showStatus : ShowStatus,
        }
        ,
        LayoutView : LayoutView
        ,
        ManageView : ManageView
        ,
        CollectView : CollectView
        ,
        AccountView : AccountView
        ,
        WidgetView : WidgetView
        ,
        PreviewView : PreviewView
        ,
        start : function() {
            this.router = new Router(this);
            var self = this;
            $(function() {
                new LayoutView(self.router);
                self.router.start();
            })
        }
    }
});
