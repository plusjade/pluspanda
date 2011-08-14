var sammyApp = $.sammy(function() {

  this.debug = false;
  
  this.before(function(){
    $('#main-wrapper').html(loading);
    
    // fix this later.
    page = this.path.substring(2);
  });
    
  this.after(function(){
    adminNavigation.mainTab(page);
    mpmetrics.track("page: " + page);
  });
    
/* standard testimonial pages */  

  this.get('#/widget', function() {
    $.get("/admin/widget", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });

  this.get('#/manage', function() {
    $.get("/admin/manage", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });
  
  this.get('#/collect', function() {
    $.get("/admin/collect", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });  
  
  this.get('#/install', function() {
    $.get("/admin/install", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });
    
  this.get('#/theme', function() {
    $.get("/admin/theme", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });    
    
  this.get('#/thanks', function() {
    $.get("/admin/thanks", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });
    
/* twitter pages */

  this.get('#/t_widget', function() {
    $.get("/twitter/widget", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });
  
  this.get('#/t_manage', function() {
    $.get("/twitter/manage", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });
  
  this.get('#/t_install', function() {
    $.get("/twitter/install", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });
  

});

