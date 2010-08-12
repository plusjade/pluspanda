
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
        $(document).trigger('page.' + $(e.target).attr('rel'));
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
    },
    
  // save the sort for testimonials  
    '#manage-buttons button' : function(e){
      var order = $("table.t-data").sortable("serialize");
      if(!order){alert("No items to sort");return false;}
      $(document).trigger('submitting');
      $.get('/admin/save_positions', order, function(rsp){
        $(document).trigger('responding', rsp);
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
   #### bindings 
  -------------------------------------------
*/
 // manage tab
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
  });
  
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
        if(undefined != rsp.resource){
          if('created' == rsp.resource.action){
            $('#facebox form').clearForm();
            $.get('/' + rsp.resource.name + '/' + rsp.resource.id, function(data){
              $('#t-data').prepend(data);
            });
          }
          else if('updated' == rsp.resource.action){
            $.get('/' + rsp.resource.name + '/' + rsp.resource.id, function(data){
              $('#tstml_' + rsp.resource.id).replaceWith(data);
            });        
          }
        }
        $(document).trigger('responding', rsp);
        $('form button').removeAttr('disabled').addClass('positive');
      }
    });
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
     
    
}); // end




