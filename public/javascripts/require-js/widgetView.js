define([
  'jquery',
  'underscore',
  'backbone',

  'lib/showStatus',
  'previewView'
], function($, _, Backbone, ShowStatus, PreviewView) {

    var SettingsView = Backbone.View.extend({
        el : '#theme-settings-form'
        ,
        events : {
            'submit' : 'save',
            'change select' : 'autoSave',
            'keyup input' : 'autoSave'
        }
        ,
        initialize : function(attrs) {
            this.previewView = attrs.previewView;

            var self = this;
            this.autoSave = _.debounce(function(e) {
                if (e.which === 13) {
                    e.preventDefault();
                }
                else {
                    self.save(e);
                }
            }, 800)
        }
        ,
        save : function(e) {
            if(e) e.preventDefault();
            var self = this;
            ShowStatus.submitting();
            $.ajax({
                dataType: "JSON",
                type : "PUT",
                url: "/admin/settings",
                data: this.$el.serializeArray()
            })
            .done(function(rsp) {
                ShowStatus.respond(rsp);
                self.previewView.staging();
            })
            .error(function(){
                ShowStatus.respond({ msg :'There was an error! Please try again' });
            })
        }
    })

    var ThemeChangeView = Backbone.View.extend({
        el : '#theme-change-form'
        ,
        events : {
            'submit' : 'save',
            'click div' : 'select'
        }
        ,
        initialize : function(attrs) {
            this.previewView = attrs.previewView;
        }
        ,
        save : function(e) {
            if(e) e.preventDefault();
            var self = this;
            ShowStatus.submitting();
            $.ajax({
                dataType: "JSON",
                type : "POST",
                url: "/admin/theme",
                data: { "theme[name]" : this.selected }
            })
            .done(function(rsp) {
                ShowStatus.respond(rsp);
                self.previewView.staging();
            })
            .error(function(){
                ShowStatus.respond({ msg :'There was an error! Please try again' });
            })
        }
        ,
        select : function(e) {
            var $node = $(e.currentTarget);
            this.$('div').removeClass('active');
            $node.addClass('active');
            this.selected = $node.text();
            this.save();
        }
    })

    return Backbone.View.extend({
        el : '#theme-publish'
        ,
        events : {
            'click' : 'publish'
        }
        ,
        initialize : function() {
            this.previewView = new PreviewView();
            new SettingsView({ previewView : this.previewView });
            new ThemeChangeView({ previewView : this.previewView });
        }
        ,
        publish : function(e) {
            e.preventDefault();

            var self = this;
            ShowStatus.submitting();
            $.ajax({
                dataType: "JSON",
                type : "GET",
                url: "/admin/theme/publish"
            })
            .done(function(rsp) {
                ShowStatus.respond(rsp);
                self.previewView.production();
            })
            .error(function(){
                ShowStatus.respond({ msg :'There was an error! Please try again' });
            })
        }
    })
})
