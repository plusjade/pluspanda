
;var adminWidget = {
  $iframe : $('<iframe width="100%" height="800px">Iframe not Supported</iframe>'),
  
  loadWidgetPublished : function(){
    $('#widget-published-wrapper')
     .html(adminWidget.$iframe.clone()
     .attr('src', '/admin/published#panda.admin'))
  },

  loadWidgetStaged : function(){
    $('#widget-staged-wrapper')
     .html(adminWidget.$iframe.clone()
     .attr('src', '/admin/staged#panda.admin'))
  },
    
  loadFormPreview : function(){
    $('#collector-form-view')
      .html(adminWidget.$iframe.clone()
      .attr('src', $('#collector-form-url').val()))
  }
  
}