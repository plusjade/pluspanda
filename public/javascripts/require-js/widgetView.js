define([
  'jquery',
  'underscore',
  'backbone',

  'lib/showStatus'
], function($, _, Backbone, ShowStatus) {

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

    var PreviewView = Backbone.View.extend({
        el : '#widget-previewer'
        ,
        events : {
            'click .js-staging' : 'staging',
            'click .js-production' : 'production'
        }
        ,
        initialize : function() {
            this.$preview = $("#widget-published-wrapper");
            this.staging();
        }
        ,
        staging : function(e) {
            this._run(e, 'staging');
        }
        ,
        production : function(e) {
            this._run(e, 'production');
        }
        ,
        _run : function(e, state) {
            if(e) e.preventDefault();

            var endpoint = (state === "staging") ? "staged" : "published";
            this.$preview.html(
                $('<iframe width="100%" height="800px">Iframe not Supported</iframe>')
                    .attr('src', '/admin/widget/' + endpoint + '#panda.admin')
              );

            this.$('a.btn').removeClass('active');
            this.$('a.btn.js-'+ state).addClass('active');
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
