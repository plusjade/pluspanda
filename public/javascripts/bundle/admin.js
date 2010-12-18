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
    
    $('#load-stock-css, #reload-css').click(function(){
      admin.submitting();
      $.get(this.href, {rand: Math.random()}, function(data){
        widgetCss.setCode(data);
        admin.respond({status:'good', msg:'CSS Loaded!'});
      });
      return false;
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
    $.get('/admin/testimonials/save_positions', order, function(rsp){
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
    $.get('/admin/testimonials/update?do=' + action, $.param( {'id[]': ids}, true), function(rsp){
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
        if (filter === 'trash'){
          $("#with-selected li.untrash").show();
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
