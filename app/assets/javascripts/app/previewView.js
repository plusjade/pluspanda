App.PreviewView =  Backbone.View.extend({
    el : '#widget-previewer'
    ,
    events : {
        'click .js-staging' : 'staging',
        'click .js-production' : 'production'
    }
    ,
    initialize : function(args) {
        this.user = args.user;
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
                .attr('src', this.user.url() + '/widget/' + endpoint + '#panda.admin')
          );

        this.$('a.btn').removeClass('active');
        this.$('a.btn.js-'+ state).addClass('active');
    }
});
