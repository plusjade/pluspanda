// page initilization callbacks.
define([
  'lib/adminTestimonials', 
  'lib/widget',
  'lib/showStatus'
  ], function(
    adminTestimonials, adminWidget, showStatus
  ){
  return {

    call : function(page){
      if(typeof this[page] === "function")
        this[page]();
    },

    'admin/widget/css' : function(){
        var editor = this.initEditor('code-editor', {
          mode: { name: "css"},
          theme: "ambiance",
          continuousScanning: 500,
          lineNumbers: true,
          textWrapping: false
        });
        $(document).trigger('ajaxify.form');
    },

    'admin/widget/wrapper' : function(){
        var editor = this.initEditor('code-editor', {
          mode: { name: "xml", htmlMode: true },
          theme: "ambiance",
          path: "/codemirror-3.1/",
          continuousScanning: 500,
          lineNumbers: true
        });
        $(document).trigger('ajaxify.form');
    },

    'admin/widget/testimonial' : function(){
        var editor = this.initEditor('code-editor', {
          mode: { name: "xml", htmlMode: true },
          theme: "ambiance",
          continuousScanning: 500,
          lineNumbers: true,
          textWrapping: false
        });
        $(document).trigger('ajaxify.form');
    },
    
    'admin/widget' : function(){
        adminWidget.loadWidgetPublished();
    },

    'admin/widget/preview' : function(){
        adminWidget.loadWidgetStaged();
        $("#theme-publish").click(function(){
            showStatus.submitting();
            $.get(this.href, function(rsp){
                showStatus.respond(rsp);
            })
            return false;
        });
    },

    'admin/manage' : function(){
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

      // subtabs
      $(".manage-testimonial-filters").find('a').click(function(){
        $target = $(this);
        $(".data-description").html($target.attr('title'));
        var filter = $target.html().toLowerCase();
        adminTestimonials.loadTestimonials(filter);
        return false;
      })
    

      $('#with-selected li a.select').click(function(){
        var toggle = ($(this).hasClass('all')) ? true : false; 
        $(".checkboxes input").attr('checked', toggle);
        return false;
      });

      // batch update testimonials
      $('#with-selected li a.do').click(function(){
        var ids = []
        $(".checkboxes input:checked").each(function(){
          ids.push($(this).val());
        })
        if (ids.length === 0) {
          showStatus.respond({"msg":'Nothing selected.'});
        } else {
          var action = $(this).html().toLowerCase();
          var filter = $('ul.sub-tabs li a.active').html().toLowerCase();
          adminTestimonials.batchUpdate(ids, action, filter);
        }
        return false;
      });


      // save testimonial positions 
      $('#with-selected a.save-positions').click(function(){
        var order = $("table.t-data").sortable("serialize");
        if(order){
          adminTestimonials.savePositions(order);
        } else {
          showStatus.respond({"msg":'No items to sort'});
        }
        return false;
      });    
    
    
    
      // initialize
      adminTestimonials.loadTestimonials("new");
      $(document).trigger('ajaxify.form');
    },

    'admin/collect' : function() {
        console.log("collect callback");
        adminWidget.loadFormPreview();
    },

    'admin/collect/settings' : function() {
        $(document).trigger('ajaxify.form');
    },

    'admin/theme' : function(){
      $("#gallery-links").find("a").click(function(){
        adminWidget.loadThemePreview(this.href);
        var theme_id = $(this).attr("rel");
        $("#theme_name").val(theme_id);
        $("#new_theme").show();
      
        $("#gallery-links").find("a").removeClass("active");
        $(this).addClass("active");
      
        return false;
      });
      $(document).trigger('ajaxify.form');
    },


    initEditor : function(id, options){
        var $codeEditor = $('#code-editor'),
            $form = $('#code-editor-form'),
            editor = window.CodeMirror.fromTextArea(document.getElementById(id), options);

        editor.addKeyMap({
          'Cmd-S' : function(cm){
              $codeEditor.val(cm.getValue());
              $form.submit();
              mpmetrics.track("editor save:css");
          }
        })

        $form.find('button').click(function(){
          $codeEditor.val(editor.getValue());
        });

        $form.find('.refresh, .load-stock').click(function(){
          showStatus.submitting();
          $.get(this.href, {rand: Math.random()}, function(data){
            editor.setValue(data);
            showStatus.respond({status:'good', msg:'Content Loaded.'});
          });
          return false;
        })

        return editor;
    }
  }
})