var sammyApp = $.sammy(function() {

  this.debug = false;
  
  this.before(function(){
    $('#main-wrapper').html(loading);
    
    // fix this later.
    page = this.path.substring(2);
  })
    
    
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
    
/* twitter stuff */
  this.get('#/t_widget', function() {
    $.get("/admin/twitter/widget", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });
  
  this.get('#/t_manage', function() {
    $.get("/admin/twitter/manage", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });
  
  this.get('#/t_install', function() {
    $.get("/admin/twitter/install", function(view){
      $('#main-wrapper').html(view);
      adminPages.call(page);
    })
  });
  
  this.after(function(){
    adminNavigation.mainTab(page);
    mpmetrics.track("page: " + page);
  })

});

