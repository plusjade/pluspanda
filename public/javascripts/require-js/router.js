define([
  'jquery',
  'underscore',
  'backbone',

  'lib/pages',
  'lib/navigation'
], function($, _, Backbone, adminPages, adminNavigation){

  return Backbone.Router.extend({

    routes: {
      "admin" : "home",
      "*page": "page"
    },

    initialize : function(){
      var that = this;
      
      this.bind("route:home", function(){
        console.log('home!');
        that.navigate('admin/widget', {trigger: true});
      }, this)
      
      this.bind("route:page", function(page){
        console.log('page: '+page);
        $.get("/"+page, function(view){
          $('#main-wrapper').html(view);
          adminPages.call(page);
          adminNavigation.mainTab(page);
        })
      }, this)
      
      
      // Hand off all link events to the Router.
      $("#parent_nav").find('a').live("click", function(e){
        console.log('clicking!');
        if( _.isString($(this).attr("href")))
          that.navigate($(this).attr("href"), {trigger: true});
        
        e.preventDefault();
        return false;
      });
    },
    
    // Public: Start Router.
    // Returns: Nothing
    start : function(){
      Backbone.history.start({pushState: true});
    }

  });

});