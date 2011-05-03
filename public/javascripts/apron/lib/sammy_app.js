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
      if(typeof adminPages[page] === "function") adminPages[page]();
    })
  });

  this.get('#/manage', function() {
    $.get("/admin/manage", function(view){
      $('#main-wrapper').html(view);
      if(typeof adminPages[page] === "function") adminPages[page]();
    })
  });
  
  this.get('#/collect', function() {
    $.get("/admin/collect", function(view){
      $('#main-wrapper').html(view);
      if(typeof adminPages[page] === "function") adminPages[page]();
    })
  });  
  
  this.get('#/install', function() {
    $.get("/admin/install", function(view){
      $('#main-wrapper').html(view);
      if(typeof adminPages[page] === "function") adminPages[page]();
    })
  });
    
  this.get('#/theme', function() {
    $.get("/admin/theme", function(view){
      $('#main-wrapper').html(view);
      if(typeof adminPages[page] === "function") adminPages[page]();
    })
  });    
    
  this.get('#/thanks', function() {
    $.get("/admin/thanks", function(view){
      $('#main-wrapper').html(view);
      if(typeof adminPages[page] === "function") adminPages[page]();
    })
  });
    
  this.after(function(){
    adminNavigation.mainTab(page);
    mpmetrics.track("page: " + page);
  })

});

