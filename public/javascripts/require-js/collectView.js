define([
  'jquery',
  'underscore',
  'backbone',

  'lib/showStatus'
], function($, _, Backbone, ShowStatus) {

    return Backbone.View.extend({
        el : '#collect-form'
        ,
        events : {
            'submit' : 'save'
        }
        ,
        initialize : function() {
            this.$preview = $('#collector-form-view');
            this.renderPreview();
        }
        ,
        save : function(e) {
            e.preventDefault();
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
                self.renderPreview();
            })
            .error(function(){
                ShowStatus.respond({ msg :'There was an error! Please try again' });
            })
        }
        ,
        renderPreview : function() {
            this.$preview.html(
                $('<iframe width="100%" height="800px">Iframe not Supported</iframe>')
                    .attr('src', $('#collector-form-url').val())
              )
        }
    })
})
