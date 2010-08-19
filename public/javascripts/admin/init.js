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
      return false;
    },

   // save testimonial positions 
    '#manage-buttons button' : function(e){
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
    },
    
  // TODO: save an image with javascript
    'blah blah' : function(e){  
      $.get(e.target.href, function(data){

        // upload the image given in the file input.
        $('.panda-image input').change(function(){
          var file = $(this).val();
          if(!file)return false;
          var ext = file.substring(file.lastIndexOf('.')).toLowerCase();
          var imgTypes = ['.jpg','.jpeg','.png','.gif','.tiff','.bmp'];
          var valid = false;
          $.each(imgTypes, function(){
            if(this == ext){valid = true; return false;}
          });
          if(!valid){alert('Filetype not supported'); return false};
          
          $(document).trigger('submitting');
          //var url = $('#save-testimonial').attr('action').replace('save', 'save_image');
          var id = $('#save-testimonial').attr('rel');
          $('#save-testimonial').ajaxSubmit({
            dataType: 'json',
            type: 'post',
            url : '/admin/testimonials/manage/save_image?id=' + id,
            success: function(rsp){
              console.log(rsp);
              $('.panda-image input').val('');
              if('success' == rsp.status){
                var imgUrl = $('.t-details .image').attr('rel') + '/' + rsp.image + '?r=' + new Date().getTime();
                newImg = new Image(); 
                newImg.src = imgUrl;
                $('#save-testimonial').attr('rel', rsp.id);
                $('div.t-details a:first').attr('href','/admin/testimonials/manage/crop?image='+rsp.image);
                $('div.t-details .image').html('<img src="'+ newImg.src +'">');
              }
              $(document).trigger('rsp.server', rsp);
            }
          })
        })
      });
      return false;
    },
    
/* TODO: refactor category stuff
 */            
   // add a category.
    'form#add-cat button' :function(e){
      $('form#add-cat').ajaxSubmit({
        dataType: 'json',
        beforeSubmit: function(fields, form){
          if(! $("input, textarea", form[0]).jade_validate()) return false;
          $('button', form).attr('disabled', 'disabled').html('Submitting...');
          $(document).trigger('submitting');
        },
        success: function(rsp) {
          $(document).trigger('rsp.server', rsp);
          $('form#add-cat button').removeAttr('disabled').html('Add Category');
          $('form#add-cat').clearFields();
          $('#primary_content').load('/admin/testimonials/tags', function(){
              $('ul#sortable li:last').effect("highlight", {}, 5000);
          });
        }
      });
      return false;
    },
    
   // save category edits.
    '.cat-save button' : function(e){
      var $form = $(e.target).parent('div').parent('form');
      $form.ajaxSubmit({
        dataType : 'json',
        beforeSubmit : function(fields, form){
          if(!$("input", form[0]).jade_validate()) return false;
          $(document).trigger('submitting');
        },
        success : function(rsp){
          $(document).trigger('rsp.server', rsp);
          $form.parent('li').hide().fadeIn(600);
        }
      });
      return false;
    },
    
   // save categories/tags sort order.
    '#save_order' : function(e){
      var order = $("#sortable").sortable("serialize");
      if(!order){alert("No items to sort");return false;}
      var url = $(e.target).attr('rel');
      $(document).trigger('submitting');
      $.get(url, order, function(rsp){
        $(document).trigger('rsp.server', rsp);
      });    
      return false;
    }
      
  }));


 /*
  // css handling
  $('.common-ajax button.positive, a.update-css').click(function(){
    $('head link#pandaTheme').remove();
    var css = $('textarea[name="css"]').val();
    $('style#custom-css').html(css);
    return false;
  });
  
  $('a.load-stock').click(function(){
    var css = $('div.stock-css').html();
    $('textarea[name="css"]').val(css);
    return false;
  });
  
  $('a.toggle-html').click(function(){
    $('textarea[name="html"]').slideToggle('fast');
    return false;
  });
 */
  
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
    $('div.responding').hide();
    $('div.responding.active').remove();
    $('div.responding').clone().addClass('active ' + status).html(msg).show().insertAfter('div.responding');
    setTimeout('$("div.responding.active").fadeOut(4000)', 1900);  
  }); 
     
 // ajaxify the forms
  $(document).bind('ajaxify.form', function(){
    $('form').ajaxForm({
      dataType : 'json',     
      beforeSubmit: function(fields, form){
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
        }
        $(document).trigger('responding', rsp);
        $('form button').removeAttr('disabled').addClass('positive');
        if(formCallback != 'undefined')
          $(document).trigger(formCallback);
      }
    });
  });
      
}); // end

