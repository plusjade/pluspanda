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
        this.user = attrs.user;
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
            url: this.user.url() + "/settings",
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
        this.user = attrs.user;
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
            url: this.user.url() + "/theme",
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

App.WidgetView = Backbone.View.extend({
    el : '#theme-publish'
    ,
    events : {
        'click' : 'publish'
    }
    ,
    initialize : function(args) {
        this.user = args.user;
        this.previewView = new App.PreviewView({ user: this.user });
        new SettingsView({ previewView : this.previewView, user: this.user });
        new ThemeChangeView({ previewView : this.previewView, user: this.user });
    }
    ,
    publish : function(e) {
        e.preventDefault();

        var self = this;
        ShowStatus.submitting();
        $.ajax({
            dataType: "JSON",
            type : "POST",
            url: this.user.url() + "/theme/publish"
        })
        .done(function(rsp) {
            ShowStatus.respond(rsp);
            self.previewView.production();
        })
        .error(function(){
            ShowStatus.respond({ msg :'There was an error! Please try again' });
        })
    }
});
