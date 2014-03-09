define([
    'jquery',
    'underscore',
    'backbone'
], function($, _, Backbone) {
    return Backbone.View.extend({
        el: '#parent_nav'
        ,
        events : {
            'click a' : 'loadPage'
        }
        ,
        initialize : function(router) {
            this.router = router;
            this.$("a[href='"+window.location.pathname+"']").addClass("active");
        }
        ,
        loadPage: function(e) {
            if ( Modernizr && Modernizr.history ) {
                e.preventDefault();
                var $target = $(e.currentTarget);
                var url = $target.attr("href");

                this.router.navigate(url, { trigger: true });

                this.$("a").removeClass("active");
                $target.addClass('active');
            }
        }
    });
})
