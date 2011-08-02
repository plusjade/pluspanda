
;var twitterWidget = {
  $iframe : $('<iframe width="100%" height="800px">Iframe not Supported</iframe>'),
  
  loadWidgetPublished : function(){
    $('#widget-published-wrapper')
     .html(adminWidget.$iframe.clone()
     .attr('src', '/admin/twitter/published#panda.admin'))
  },

  loadWidgetStaged : function(){
    $('#widget-staged-wrapper')
     .html(adminWidget.$iframe.clone()
     .attr('src', '/admin/twitter/staged#panda.admin'))
  }

}