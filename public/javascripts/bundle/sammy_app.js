var sammyApp = $.sammy(function() {

  this.debug = true;
  
  this.before(function(){
    console.log("before hook called");
    $('#main-wrapper').html(loading);
    console.log(this.path);
    
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
    
    
    
  this.after(function(){
    console.log("after hook called");
    adminNavigation.mainTab(page);
  })

});

