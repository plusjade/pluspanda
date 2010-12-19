
// facebox reveal callback  
$(document).bind('reveal.facebox', function(){
  /* well this was the only way that seemed to work... but it sucks ... fix it later */
  $("select.tconfig_theme").val(admin.settingsStore.theme);
  $(".tconfig_per_page").val(admin.settingsStore.per_page);
  $("select.tconfig_sort").val(admin.settingsStore.sort);

  $(document).trigger('ajaxify.form');
});

// facebox close callback
$(document).bind('close.facebox', function() {
  //$('.content', '#facebox').empty();
});

   
// ajaxify the forms
$(document).bind('ajaxify.form', function(){
  $('form').ajaxForm({
    dataType : 'json',      
    beforeSubmit: function(fields, form){
      if($(form).hasClass('js-multipart-form')){
        $(form).append('<input type="hidden" name="is_ajax" value="true" />'); 
      }
      showStatus.submitting();
      $('button', form[0]).attr('disabled','disabled').removeClass('positive');
    },
    success: function(rsp) {
      showStatus.respond(rsp);     

      if (rsp.tconfig)
        admin.settingsSave(rsp);
      else if (rsp.testimonial)
        admin.testimonialSave(rsp);

      $('form button').removeAttr('disabled').addClass('positive');
    }
  })
})