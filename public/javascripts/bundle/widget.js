
;var adminWidget = {
  loadWidgetPublished : function(){
    $('#widget-published-wrapper')
     .html($iframe.clone()
     .attr('src', '/admin/published#panda.admin'))
  },

  loadWidgetStaged : function(){
    $('#widget-staged-wrapper')
     .html($iframe.clone()
     .attr('src', '/admin/staged#panda.admin'))
  },
    
  loadFormPreview : function(){
    $('#collector-form-view')
      .html($iframe.clone()
      .attr('src', $('#collector-form-url').val()))
  }
  
}