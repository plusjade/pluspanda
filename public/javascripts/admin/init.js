/*
 * admin (controller) = interfaces with server to carry out actions.
 * event handlers (view)= determine which admin call to invoke. Update the view.
 
 *  the admin object should provide an api for carrying out actions between client and server.
 *    UI updates should be handled elsewhere if possible.
 *  UI events should determine which admin call to invoke based on event.
      Also they should carry out UI updates and DOM manipulations.
 */
var loading = '<div class="loading">Loading...</div>';
var widgetCss;
var $iframe = $('<iframe width="100%" height="800px">Iframe not Supported</iframe>');

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



var admin = {
  pages   : {'widget':'', 'manage':'', 'collect':'', 'install':''},
  filters : {'new':'', 'published':'', 'hidden':''},
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
        
        if(page in admin) admin[page]();
        $(document).trigger('ajaxify.form');
      })
    }
  },
    
  
/* Init setup invividual pages */
  
  // widget page
  widget : function(){
    widgetCss = CodeMirror.fromTextArea('widget_css', {
      width: "800px",
      height: "700px",
      parserfile: "parsecss.js",
      stylesheet: "/stylesheets/codemirror/csscolors.css?3453",
      path: "/javascripts/codemirror/",
      continuousScanning: 500,
      lineNumbers: true,
      textWrapping: false,
      saveFunction: function(){
        $('#widget_css').val(widgetCss.getCode());
        $('#css-form').submit();
      },
      initCallback: function(editor){
        //editor.setCode('some value');    
      }    
    });

   // overload save button for saving css
    $('#css-form button').click(function(){
      $('#widget_css').val(widgetCss.getCode());
    });
    
    $('#load-stock-css').click(function(){
      admin.submitting();
      $.get('/admin/theme_stock_css', {rand: Math.random()}, function(data){
        widgetCss.setCode(data);
        admin.respond({status:'good', msg:'Stock CSS Loaded!'});
      });
    })        
    
    $('ul.grandchild_nav li a:first').click();
  },

  
  // setup manage page
  manage : function(){
    $("table.t-data").tablesorter({
      headers:{
        0:{sorter:false},
        1:{sorter:false},
        9:{sorter:false},
        10:{sorter:false},
        11:{sorter:false}
      }
    }); 
    
    // TODO: make this declare only once and for published filter only
    $('table.t-data').sortable({
      items:'tr',
      handle:'td.move',
      axis: 'y',
      helper: 'clone'
    });
  
    //admin.loadTestimonials('new');
    $('ul.grandchild_nav li a:first').click();
  },
  
  collect : function(){
     $('ul.grandchild_nav li a:first').click();
  },
  
  
/* testimonial interactions */

  savePositions : function(order){
    admin.submitting();    
    $.get('/admin/save_positions', order, function(rsp){
      admin.respond(rsp);
      if(rsp.status = 'good'){
        admin.loadSettingsForm();
      }
    })
  },

  /*
   * ids (array) : testimonials to update.
   * action (string) : what action to carry out.
   * filter (string) : optionally reloads these testimonials into the DOM
   */
  batchUpdate : function(ids, action, filter){
    admin.submitting();
    $.get('/admin/update?do=' + action, $.param( {'id[]': ids}, true), function(rsp){
      admin.respond(rsp);
      if (filter)
        admin.loadTestimonials(filter);
    })
  },


/* load data and views into the DOM */

  // pretty much only for manage page atm.
  loadTestimonials : function(filter){
    if(filter in admin.filters ) {
      $.get('/admin/testimonials?filter=' + filter, function(data){
        $("#with-selected li.right").hide();
        if (filter === 'new'){
          $("#with-selected li.new-testimonial").show();
        }
        if (filter === 'published'){
          $("#with-selected li.save-positions").show();
        }          
      
        $('#t-data').removeClass().addClass(filter).html(data);
        $('abbr.timeago').timeago();
      })
    }    
  },
    
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
  },
  
  
/* resource updating callbacks */
  
  settingsSave : function(rsp){
    admin.settingsStore = rsp.tconfig;
    
    if(admin.thisPage === 'widget'){
      admin.loadWidgetPreview();
      $.get('/admin/theme_css', {rand: Math.random()}, function(data){
          widgetCss.setCode(data);
      })      
    }
  },
  
  testimonialSave : function(rsp){
    if (admin.thisPage !== 'manage') return;
    
    if(rsp.testimonial.image){
      $('#testimonial-image-wrapper').html('<img src="' + rsp.testimonial.image + '" />');
    }

    $.get(rsp.testimonial.path, function(data){
      switch(rsp.testimonial.type){
        case 'new':
          $('#facebox form').clearForm();
          $('#t-data').prepend(data);
          break;
        case 'existing':
          $('#tstml_' + rsp.testimonial.id).replaceWith(data);
          break;
      }
      $('abbr.timeago').timeago();  
    })
  
  },
 
 
/* UI responses */
  
  submitting: function(){
    $('#status-bar div.responding.active').remove();
    $('#submitting').show();    
  },

  respond : function(rsp){
    var status = (undefined == rsp.status) ? 'bad' : rsp.status;
    var msg = (undefined == rsp.msg) ? 'There was a problem!' : rsp.msg;
    $('#submitting').hide();
    $('div.responding.active').remove();
    $('div.responding').hide().clone().addClass('active ' + status).html(msg).show().insertAfter('div.responding');
    setTimeout('$("div.responding.active").fadeOut(4000)', 1900);  
  }
  
}

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
      console.log(rsp);
      admin.respond(rsp);     

      if (rsp.tconfig)
        admin.settingsSave(rsp);
      else if (rsp.testimonial)
        admin.testimonialSave(rsp);

      $('form button').removeAttr('disabled').addClass('positive');
    }
  })
})