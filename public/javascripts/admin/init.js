
$(function(){
  var loading = '<div class="loading">Loading...</div>';
  // TODO: refactor this.
  $('li.fb-help a').click(function(){
    $.facebox({ div: this.href });
    return false;
  });
  $('a.fb-div').live('click',function(){
    $.facebox({ div: $(this).attr('rel') });
    $('div.share-data input').val(this.href);
    return false;
  });
        
/* delegations
 */
  $('body').click($.delegate({
   // delegate facebox links
    'a[rel*=facebox]' :function(e){
      $.facebox(function(){ 
        $.get(e.target.href, function(data) { $.facebox(data) })
      })
      return false;
    },
      
  // main panel links
    '#parent_nav li a' : function(e){
      $('#main-wrapper').html(loading);
      $('#parent_nav li a').removeClass('active');
      $(e.target).addClass("active");    
      $.get(e.target.href, function(data){
        $('#main-wrapper').html(data);
        $('ul.grandchild_nav li a:first').click();
        $(document).trigger('ajaxify.form');
        window.location.hash = $(e.target).attr('rel');
      });
      return false;
    },
 
  // main tabs
    'ul.grandchild_nav li a' : function(e){
      $('div.tab-content').hide();
      $('ul.grandchild_nav li a').removeClass('active');
      $(e.target).addClass('active');
      $('#'+ $(e.target).attr('rel')).show();
      /*
      if(e.target.id == 'reload-widget-iframe'){
        var $container = $('#widget-view-container');
        $container.html($iframe.clone().attr('src', '/sliders/'+ $container.attr('rel')));
      }
      */
      return false;
    },
        
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
    
  // delete a category.
    '.cat-delete a' : function(e){
      if(confirm('This cannot be undone!! Delete this category?')){
        $(document).trigger('submitting');
        $.get(e.target.href, function(rsp){
          $(document).trigger('rsp.server', rsp);
          $(e.target).parent('div').parent('form').parent('li').remove();
        });
      }
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
    },

  // load the edit view into the bottom container
    '.admin-new-testimonials-list table td.edit a, li.create a' : function(e){  
      $('.edit-window').html('<div class="ajax-loading">Loading...</div>');
      $.get(e.target.href, function(data){
        $('.edit-window').hide().html(data).slideDown('slow');

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
          });
        });
        // override the normal submit event
        $('#save-testimonial').submit(function(){
          $('#save-testimonial button').click();
          return false;
        });
      });
      return false;
    },
  // save the edit testimonial
    '#save-testimonial button' : function(e){
      //var url = $('#save-testimonial').attr('action');
      var id = $('#save-testimonial').attr('rel');
      $('#save-testimonial').ajaxSubmit({
        dataType : 'json',
        url : '/admin/testimonials/manage/save?id=' + id,
        beforeSubmit: function(fields, form){
          $(document).trigger('submitting');
          // json response acts up when we send a file =/
          $('.panda-image input').attr('disabled','disabled');
        },
        success: function(rsp){
          $(document).trigger('rsp.server', rsp);
          $('#save-testimonial').attr('rel', rsp.id);
          if('success' == rsp.status){
            if(rsp.exists) $("tr#tstml_" + rsp.id).replaceWith(rsp.rowHtml);
            else $("table.t-data tr:first").after(rsp.rowHtml);
            $("tr#tstml_" + rsp.id).effect("highlight", {}, 3000);
            $('abbr.timeago').timeago();
          }
          $('.panda-image input').removeAttr('disabled');
        }
      });
      return false;
    },

  // delete a testimonial
    '.t-data td.delete a' : function(e){
      if(confirm('This cannot be undone! Delete testimonial?')){
        $(document).trigger('submitting');
        $.get(e.target.href, function(rsp){
          $(document).trigger('rsp.server', rsp);
          $(e.target).parent('td').parent('tr').remove();
        });
      }
      return false;
    },

  // hide the round boxes
    '.round-box-top a.close, .panda-image a.close' : function(e){
      $(e.target).parent().parent().hide();
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
   #### bindings 
  -------------------------------------------
*/
 // ajaxify the forms
  $(document).bind('ajaxify.form', function(){
    $('form').ajaxForm({
      dataType : 'json',     
      beforeSubmit: function(fields, form){
        //if(! $("input", form[0]).jade_validate() ) return false;
        $('button', form[0]).attr('disabled','disabled').removeClass('positive');
        $(document).trigger('submitting');
      },
      success: function(rsp) {
        if(undefined != rsp.created){
        }
        $(document).trigger('responding', rsp);
        $('form button').removeAttr('disabled').addClass('positive');
      }
    });
  });
  
 // show server response.
  $(document).bind('responding', function(e, rsp){
    if(typeof rsp === "string"){
      // hacky. All responses should be one object
      if('{' == rsp.substring(0, 1)) rsp = JSON.parse(rsp);
      else rsp = {'status':'attention','msg':'Server gave a bad response'};
    }
    // validate required responses.
    if(typeof rsp.status !== "string") rsp.status = 'attention';
    if(typeof rsp.msg !== "string") rsp.msg = 'Server gave no message';

    $('#server_response .load').hide();
    $('<div></div>').addClass(rsp.status).html(rsp.msg).appendTo($('#server_response .rsp'));
    setTimeout('$("#server_response span div").fadeOut(4000)', 1500);
  });

// show submit icon
  $(document).bind('submitting', function(e, data){
    $('#server_response .rsp').empty();
    $('#server_response div.load').show();
  });
  
  
    
}); // end




