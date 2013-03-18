define([
  'jquery',
  'underscore',
  'backbone',
  'router',

  'vendor/addon',
  'vendor/facebox',
  'vendor/jquery.form',
  'vendor/jquery.tablesorter.min',
  'vendor/jquery.ui',
  'vendor/timeago.min',

  'lib/adminTestimonials',
  'lib/pages',
  'lib/showStatus',
  'lib/widget',
  'lib/bind',
], function($, _, Backbone, Router,
  a,a,a,a,a,a,
  AdminTestimonials, AdminPages, ShowStatus,
  Widget, Bind
  ){

  var App = { 
    
    router : new Router,
    
    // Public: Start the application relative to the site_source.
    // The web-server is responsible for passing site_source in the Header.
    // Once the site_source folder is known we can load _config.yml and start the app.
    //
    // Returns: Nothing
    start : function(){
      var that = this;
      $(function(){
        that.bind();
        that.router.start();
        AdminPages.call(window.location.pathname.slice(1));
        $("#parent_nav").find("a[href='"+window.location.pathname+"']").addClass("active")
        $(".sub-tabs").find("a[href='"+window.location.pathname+"']").addClass("active");
      })
    },

    bind : function(){
      $("a[rel*=fb-div]").live("click", function(){
        $.facebox({div : this.href});
        mpmetrics.track(this.href);
        return false;    
      });

      // facebox share panel 
      $("a.fb-div").live("click", function(){
        $.facebox({ div: $(this).attr('rel') });
        $('div.share-data input').val(this.href);
        mpmetrics.track(this.href);
        return false;    
      });
    }
    
  }
  
  return App;
});
