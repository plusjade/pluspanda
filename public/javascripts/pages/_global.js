/*
 * admin (controller) = interfaces with server to carry out actions.
 * event handlers (view)= determine which admin call to invoke. Update the view.
 */
$(function(){

/* delegate UI click events  */
  $('body').click($.delegate({

    'a[rel*=facebox]' :function(e){
      $.facebox(function(){ 
        $.get(e.target.href, function(data) { $.facebox(data) })
      })
      return false;
    },
   // facebox share panel 
    'a.fb-div' : function(e){
      $.facebox({ div: $(e.target).attr('rel') });
      $('div.share-data input').val(e.target.href);
      return false;
    },
    
    
   // primary page links
    '#parent_nav li a' : function(e){
      $('#parent_nav li a').removeClass('active');
      $(e.target).addClass("active");   
      var page = $(e.target).attr('rel'); 
      
      admin.loadPage(page);
      return false;
    },
   
   // secondary navigation tabs
    'ul.grandchild_nav li a' : function(e){
      var $target = $(e.target);
      var tab     = $target.attr('rel');
      $('div.tab-content').hide();
      $('ul.grandchild_nav li a').removeClass('active');
      $target.addClass('active');
      $('#'+ tab).show();
      
      if('tab-widget' == tab)
        admin.loadWidgetPreview();
      else if('tab-collect' == tab)
        admin.loadFormPreview();
        
      if(admin.thisPage === 'manage'){
        $("#data-description").html($target.attr('title'));
        var filter = $target.html().toLowerCase();
        admin.loadTestimonials(filter);
      }
      return false;
    },

    '#with-selected li a.select' : function(e){
      toggle = ($(e.target).hasClass('all')) ? true : false; 
      $(".checkboxes input").attr('checked', toggle);
      return false;
    },

    // batch update testimonials
    '#with-selected li a.do' : function(e){
      var ids = []
      $(".checkboxes input:checked").each(function(){
        ids.push($(this).val());
      })
      if (ids.length === 0) {
        admin.respond({"msg":'Nothing selected.'});
      } else {
        var action = $(e.target).html().toLowerCase();
        var filter = $('ul.grandchild_nav li a.active').html().toLowerCase();
        admin.batchUpdate(ids, action, filter);
      }
      return false;
    },
    
      
   // save testimonial positions 
    '#with-selected a.save-positions' : function(e){
      var order = $("table.t-data").sortable("serialize");
      if(order){
        admin.savePositions(order);
      } else {
        admin.respond({"msg":'No items to sort'});
      }
      return false;
    },
    
    '.js-show-settings' : function(e){
      admin.loadSettingsForm();
      return false;
    }
    
    /* TODO: add soft deleting via trashcan functionality. */
  }))
    
}); // end


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
      admin.submitting();
      $('button', form[0]).attr('disabled','disabled').removeClass('positive');
    },
    success: function(rsp) {
      admin.respond(rsp);     

      if (rsp.tconfig)
        admin.settingsSave(rsp);
      else if (rsp.testimonial)
        admin.testimonialSave(rsp);

      $('form button').removeAttr('disabled').addClass('positive');
    }
  })
})