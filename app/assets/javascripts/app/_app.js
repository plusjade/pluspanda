/* UI responses */
ShowStatus = {
    submitting : function() {
        $('#status-bar div.responding.active').remove();
        $('#submitting').show();
    }
    ,
    respond : function(rsp) {
        var status = (undefined == rsp.status) ? 'bad' : rsp.status;
        var msg = (undefined == rsp.msg) ? 'There was a problem!' : rsp.msg;
        $('#submitting').hide();
        $('div.responding.active').remove();
        $('div.responding').hide().clone().addClass('active ' + status).html(msg).show().insertAfter('div.responding');
        setTimeout('$("div.responding.active").fadeOut(4000)', 1900);  
    }
}

App = {
    start : function(user) {
        this.user = new App.User(user);
        this.router = new App.Router(this);
        var self = this;
        $(function() {
            new App.LayoutView(self.router);
            self.router.start();
        })
    }
}

App.User = Backbone.Model.extend({
    url : function() {
        return '/users/' + this.id;
    }
});
