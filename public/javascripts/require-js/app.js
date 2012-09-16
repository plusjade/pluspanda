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
  'lib/navigation',
  'lib/pages',
  'lib/showStatus',
  'lib/simpleTabs',
  'lib/tweetWidget',
  'lib/widget',
  'lib/bind',
], function($, _, Backbone, Router,
  a,a,a,a,a,a,
  AdminTestimonials, AdminNavigation, AdminPages, ShowStatus, SimpleTabs,
  TweetWidget, Widget, Bind
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
        that.bind()
        that.router.start()
      })
    },
    
    bind : function(){
      $("a[rel*=facebox]").live("click", function(){
        var url = this.href
        $.facebox(function(){ 
          $.get(url, function(data) { $.facebox(data) })
        })
        mpmetrics.track(url);
        return false;    
      });

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
      
      SimpleTabs.init('.js_tabs_list', '.js_tabs_wrapper');
    }
    
  }
  
  return App;
});
