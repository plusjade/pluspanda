App.AccountView = Backbone.View.extend({
    el : '#account-form'
    ,
    events : {
        'submit' : 'save'
    }
    ,
    save : function(e) {
        e.preventDefault();
        var self = this;
        ShowStatus.submitting();
        $.ajax({
            dataType: "JSON",
            type : "POST",
            url: "/admin/account",
            data: this.$el.serializeArray()
        })
        .done(function(rsp) {
            ShowStatus.respond(rsp);
        })
        .error(function(){
            ShowStatus.respond({ msg :'There was an error! Please try again' });
        })
    }
})
