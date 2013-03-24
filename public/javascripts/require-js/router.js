define([
  'jquery',
  'underscore',
  'backbone',

  'lib/pages',
], function($, _, Backbone, adminPages){

  return Backbone.Router.extend({

    routes: {
      "*page": "page"
    },

    initialize : function(){
      var that = this;

      this.bind("route:page", function(page){
        $.get("/"+page, function(view){
          $('#main-wrapper').html(view);
          $(".sub-tabs").find("a[href='"+window.location.pathname+"']").addClass("active");
          adminPages.call(page);
        })
      }, this)

      // Hand off all link events to the Router.
      $("#parent_nav").find('a').live("click", function(e){
        if( _.isString($(this).attr("href")))
          that.navigate($(this).attr("href"), {trigger: true});
          
        $("#parent_nav").find("a").removeClass("active");
        $(this).addClass('active');
        e.preventDefault();
        return false;
      });

      $(".sub-tabs").find('a').live("click", function(e){
          if( _.isString($(this).attr("href")))
            that.navigate($(this).attr("href"), {trigger: true});

          e.preventDefault();
          return false;
      })

    },

    // Public: Start Router.
    // Returns: Nothing
    start : function(){
      Backbone.history.start({pushState: true, silent : true});
    }

  });

});