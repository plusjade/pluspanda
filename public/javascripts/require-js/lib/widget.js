define([], function(){
  return {
    $iframe : $('<iframe width="100%" height="800px">Iframe not Supported</iframe>'),
  
    loadWidgetPublished : function(){
      $('#widget-published-wrapper')
       .html(this.$iframe.clone()
       .attr('src', '/admin/widget/published#panda.admin'))
    },

    loadWidgetStaged : function(){
      $('#widget-staged-wrapper')
       .html(this.$iframe.clone()
       .attr('src', '/admin/widget/staged#panda.admin'))
    },
    
    loadFormPreview : function(){
      $('#collector-form-view')
        .html(this.$iframe.clone()
        .attr('src', $('#collector-form-url').val()))
    },

    loadThemePreview : function(url){
      $('#theme-gallery')
        .html(this.$iframe.clone()
        .attr('src', url))
    
      //mpmetrics.track(url);  
    }  
  
  }
})  