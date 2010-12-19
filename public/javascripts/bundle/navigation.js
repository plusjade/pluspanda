/* UI  tab highlighting */
; var adminNavigation = {

  initSubs : function(){
    $('div.tab-content').hide();
    $('div.tab-content:first').show();
  },
  
  mainTab : function(page){
    $('#parent_nav li a').removeClass('active');
    $("#parent_nav li."+ page + " a").addClass('active');    
  },

  subTab : function($target){
    var tab = $target.attr('rel');
    $('div.tab-content').hide();
    $('#sub-tabs li a').removeClass('active');
    $target.addClass('active');
    $('#'+ tab).show();
  }
  
}