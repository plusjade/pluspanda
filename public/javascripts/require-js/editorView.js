define([
  'jquery',
  'underscore',
  'backbone'
], function($, _, Backbone, adminWidget){


  return Backbone.View.extend({
    initialize : function() {

    }
    ,
    'admin/widget/css' : function() {
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
        
        $("#new_theme").submit(function(e){
            showStatus.submitting();
            $.ajax({
                type : 'POST',
                dataType : 'JSON',
                url :  $(this).attr('action'),
                data : $(this).serialize(),
                success : function(rsp){
                    showStatus.respond(rsp);
                    adminWidget.loadWidgetStaged();
                }
            })

            e.preventDefault();
            return false;
        })
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
    }
    ,
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
  })


})
