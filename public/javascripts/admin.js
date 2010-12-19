/* 
 * the admin interface javascript api
 */
;var admin = {
  pages   : {'widget':'', 'manage':'', 'collect':'', 'install':''},
  filters : {'new':'', 'published':'', 'hidden':'', 'trash': ''},
  thisPage : false,
  settingsStore : {},

  loadPage : function (page){
    if(page in admin.pages ) {
      $('#main-wrapper').html(loading);
      $("#parent_nav li."+ page + " a").addClass('active');
      admin.thisPage = page;
      window.location.hash = page;    

      $.get("/admin/" + page, function(view){
        $('#main-wrapper').html(view);
        
        // execute the page init callback
        if(page in admin) admin[page]();
        $(document).trigger('ajaxify.form');
      })
    }
  }

} 
 
