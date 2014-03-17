define([
    'jquery',
    'underscore',
    'backbone',
    'router',

    'user',

    'layoutView',
    'manageView',
    'collectView',
    'accountView',
    'widgetView',
    'editorView',
    'previewView',

    'lib/showStatus',

    'vendor/addon',
    'vendor/facebox',
    'vendor/jquery.ui-1.10.2.min',
    'vendor/timeago.min'
], function($, _, Backbone, Router,
    User,
    LayoutView, ManageView, CollectView, AccountView, WidgetView, EditorView, PreviewView,
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
        EditorView : EditorView
        ,
        PreviewView : PreviewView
        ,
        start : function(user) {
            this.user = new User(user);
            this.router = new Router(this);
            var self = this;
            $(function() {
                new LayoutView(self.router);
                self.router.start();
            })
        }
    }
});
