
;var adminWidget = {
  loadWidgetPreview : function(){
    $('#widget-wrapper')
     .html($iframe.clone()
     .attr('src', '/admin/staging#panda.admin'))
  },
  
  loadFormPreview : function(){
    $('#collector-form-view')
      .html($iframe.clone()
      .attr('src', $('#collector-form-url').val()))
  },
  
  loadSettingsForm : function(){
    var $data = $('<div>');
    $settingsForm.clone().show().appendTo($data);
    $.facebox($data);  
  }  
  
}