$(function(){
  var loading = '<div class="loading">Loading...</div>';
  var $iframe = $('<iframe width="100%" height="800px">Iframe not Supported</iframe>');
  var formCallback = 'undefined';
  
/*
 * delegations
 *************
 */
  $('body').click($.delegate({
   // delegate facebox links
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
      $('#main-wrapper').html(loading);
      $('#parent_nav li a').removeClass('active');
      $(e.target).addClass("active");    
      $.get(e.target.href, function(data){
        $('#main-wrapper').html(data);
        $(document).trigger('page.init', $(e.target).attr('rel'));
      });
      return false;
    },
   
   // secondary navigation tabs
    'ul.grandchild_nav li a' : function(e){
      var $target = $(e.target);
      var rel = $target.attr('rel');
      $('div.tab-content').hide();
      $('ul.grandchild_nav li a').removeClass('active');
      $target.addClass('active');
      $('#'+ rel).show();
      
      if($target.hasClass('reload')){
          if('tab-widget' == rel)
            $('#widget-wrapper').html($iframe.clone().attr('src', '/admin/staging'));
          else if('tab-collect' == rel)
            $('#collector-form-view').html($iframe.clone().attr('src', $('#collector-form-url').val()));
      }
      
      if($target.hasClass('manage')){
        $("#data-description").html($target.attr('title'));
        $.get(e.target.href, function(data){
          var filter = $target.html().toLowerCase();
          $("#with-selected li.right").hide();
          if (filter == 'new'){
            $("#with-selected li.new-testimonial").show();
          }
          if (filter == 'published'){
            $("#with-selected li.save-positions").show();
          }          
          $('#t-data').removeClass().addClass(filter).html(data);
          $('abbr.timeago').timeago();
        });
      }
      return false;
    },

    // batch update testimonials
    '#with-selected li a.do' : function(e){
      var ids = []
      $(".checkboxes input:checked").each(function(){
        ids.push($(this).val());
      });
      if (ids.length == 0) {
        $(document).trigger('responding', {'status':"bad", "msg":'Nothing selected.'});
        return false;
      }
      $(document).trigger('submitting');
      $.get(e.target.href, $.param( {'id[]': ids}, true), function(rsp){
        $(document).trigger('responding', rsp);
        $('ul.grandchild_nav li a.active').click();
      });      
      return false;
    },
    
    
    '#with-selected li a.select' : function(e){
      toggle = ($(e.target).hasClass('all')) ? true : false; 
      $(".checkboxes input").attr('checked', toggle);
      return false;
    },
      
   // save testimonial positions 
    '#with-selected a.save-positions' : function(e){
      var order = $("table.t-data").sortable("serialize");
      if(!order){alert("No items to sort");return false;}
      $(document).trigger('submitting');
      $.get('/admin/save_positions', order, function(rsp){
        $(document).trigger('responding', rsp);
      });    
      return false;
    },
   // delete a resource
    'a.delete' :function(e) {
      $.ajax({
        type: 'DELETE',
        dataType:'json',
        url: e.target.href,
        beforeSend: function(){
          if(!confirm('Sure you want to delete?')) return false;
          $(document).trigger('submitting');
        },
        success: function(rsp){
          $(document).trigger('responding', rsp);
          $(e.target).parent().parent().remove();
        }
      })
      return false;     
    }
  }));

/*
 * top navigation page callbacks
 *******************************
 */
  // index page
  $(document).bind('page.index', function(){
    var widgetCss = CodeMirror.fromTextArea('widget_css', {
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
      $(document).trigger('submitting');
      $.get('/admin/theme_stock_css', {rand: Math.random()}, function(data){
        widgetCss.setCode(data);
        $(document).trigger('responding', {status:'good', msg:'Stock CSS Loaded!'});
      });
    })        

    // tconfig form settings callback
    $(document).bind('form.settings', function(){
      $.get('/admin/theme_css', {rand: Math.random()}, function(data){
        widgetCss.setCode(data);
      })
    })
  });
     
 // manage page
  $(document).bind('page.manage', function(){
    $("table.t-data").tablesorter({
      headers:{
        0:{sorter:false},
        1:{sorter:false},
        9:{sorter:false},
        10:{sorter:false},
        11:{sorter:false}
      }
    }); 
    $('table.t-data').sortable({
      items:'tr',
      handle:'td.move',
      axis: 'y',
      helper: 'clone'
    });
    $('abbr.timeago').timeago();  
  });
  
    
/*
 * form callbacks (can be called from any form through rel="" tag)
 ****************
 */  



/*
 * base callbacks
 ****************
 */
  $(document).bind('page.init', function(e, page){ 
    $('ul.grandchild_nav li a:first').click();
    $(document).trigger('ajaxify.form');
    window.location.hash = page;
    $(document).trigger('page.' + page);
  });
            
  // facebox reveal callback  
  $(document).bind('reveal.facebox', function(){
    $(document).trigger('ajaxify.form');
  });

  // facebox close callback
  $(document).bind('close.facebox', function() {
    //$('body').removeClass('disable_body').removeAttr('scroll');
  });
  
  // show the submit ajax loading graphic.
  $(document).bind('submitting', function(){
    $('#status-bar div.responding.active').remove();
    $('#submitting').show();
  });

  // show the response (always json)
  $(document).bind('responding', function(e, rsp){
    var status = (undefined == rsp.status) ? 'bad' : rsp.status;
    var msg = (undefined == rsp.msg) ? 'There was a problem!' : rsp.msg;
    $('#submitting').hide();
    $('div.responding.active').remove();
    $('div.responding').hide().clone().addClass('active ' + status).html(msg).show().insertAfter('div.responding');
    setTimeout('$("div.responding.active").fadeOut(4000)', 1900);  
  }); 
     
 // ajaxify the forms
  $(document).bind('ajaxify.form', function(){
    $('form').ajaxForm({
      dataType : 'json',      
      beforeSubmit: function(fields, form){
        $(form).append('<input type="hidden" name="is_ajax" value="true" />');
        //if(! $("input", form[0]).jade_validate() ) return false;
        $('button', form[0]).attr('disabled','disabled').removeClass('positive');
        $(document).trigger('submitting');
        formCallback = $(form).attr('rel');
      },
      success: function(rsp) {
        if(undefined != rsp.resource){
          if('created' == rsp.resource.action){
            $('#facebox form').clearForm();
            $.get('/' + rsp.resource.name + '/' + rsp.resource.id, function(data){
              $('#t-data').prepend(data);
              $('abbr.timeago').timeago();
            });
          }
          else if('updated' == rsp.resource.action){
            $.get('/' + rsp.resource.name + '/' + rsp.resource.id, function(data){
              $('#tstml_' + rsp.resource.id).replaceWith(data);
              $('abbr.timeago').timeago();
            });        
          }
          if ('testimonials' == rsp.resource.name && undefined != rsp.resource.image){
            $('#testimonial-image-wrapper').html('<img src="' + rsp.resource.image + '" />');
          }
        }
               
        $(document).trigger('responding', rsp);
        $('form button').removeAttr('disabled').addClass('positive');
        if(formCallback != 'undefined')
          $(document).trigger(formCallback);
      }
    })
  })
      
}); // end

