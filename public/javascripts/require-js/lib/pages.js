// page initilization callbacks.
define([
  'lib/adminTestimonials', 
  'lib/navigation',
  'lib/widget',
  'lib/showStatus'
  ], function(
    adminTestimonials, adminNavigation, adminWidget, showStatus
  ){
  return {

    call : function(page){
      if(typeof this[page] === "function")
        this[page]();
    },

    'admin/widget' : function(){
      var editor = {}
      editor.wrapper = window.CodeMirror.fromTextArea(document.getElementById("editor_wrapper"), {
        mode: { name: "xml", htmlMode: true },
        theme: "ambiance",
        path: "/codemirror-3.1/",
        continuousScanning: 500,
        lineNumbers: true
      });
      editor.wrapper.addKeyMap({
        'Cmd-S' : function(cm){
            $('#editor_wrapper').val(cm.getValue());
            $('#wrapper-form').submit();
            mpmetrics.track("editor save:widget");
        }
      })

      editor.testimonial = window.CodeMirror.fromTextArea(document.getElementById('editor_testimonial'), {
        mode: { name: "xml", htmlMode: true },
        theme: "ambiance",
        continuousScanning: 500,
        lineNumbers: true,
        textWrapping: false
      });
      editor.wrapper.addKeyMap({
        'Cmd-S' : function(cm){
            $('#editor_testimonial').val(cm.getValue());
            $('#testimonial-form').submit();
            mpmetrics.track("editor save:testimonial");
        }
      })

      editor.css = window.CodeMirror.fromTextArea(document.getElementById('editor_css'), {
        width: "850px",
        height: "700px",
        mode: { name: "css"},
        theme: "ambiance",
        continuousScanning: 500,
        lineNumbers: true,
        textWrapping: false
      });
      editor.css.addKeyMap({
        'Cmd-S' : function(cm){
            $('#editor_css').val(cm.getValue());
            $('#css-form').submit();
            mpmetrics.track("editor save:css");
        }
      })
    
     // overload save button for saving data
      $('#wrapper-form button').click(function(){
        $('#editor_wrapper').val(editor.wrapper.getCode());
      });
      $('#testimonial-form button').click(function(){
        $('#editor_testimonial').val(editor.testimonial.getCode());
      });
      $('#css-form button').click(function(){
        $('#editor_css').val(editor.css.getCode());
      });

      // editor data-loading functions
      $('#load-stock-wrapper, #refresh-wrapper').click(function(){
        showStatus.submitting();
        $.get(this.href, {rand: Math.random()}, function(data){
          editor.wrapper.setValue(data);
          showStatus.respond({status:'good', msg:'Wrapper HTML Loaded.'});
        });
        return false;
      })
      $('#load-stock-testimonial, #refresh-testimonial').click(function(){
        showStatus.submitting();
        $.get(this.href, {rand: Math.random()}, function(data){
          editor.testimonial.setValue(data);
          showStatus.respond({status:'good', msg:'Testimonial HTML Loaded.'});
        });
        return false;
      })
      $('#load-stock-css, #refresh-css').click(function(){
        showStatus.submitting();
        $.get(this.href, {rand: Math.random()}, function(data){
          editor.css.setValue(data);
          showStatus.respond({status:'good', msg:'CSS Loaded.'});
        });
        return false;
      })    
        
    
      $("#theme-publish").click(function(){
        showStatus.submitting();
        $.get(this.href, function(rsp){
          showStatus.respond(rsp);
        })
        return false;
      });
    
      // subtabs
      $("ul.sub-tabs li a").click(function(){
        adminNavigation.subTab($(this));

        var tab = $(this).attr("href").substring(1);
        switch(tab){
          case "published":
            adminWidget.loadWidgetPublished();
            break;
          case "staged":
            adminWidget.loadWidgetStaged();
            break;
        }
      
        return false;
      });
    
      $("#installed-themes li.theme").find("a").click(function(){
        showStatus.submitting();
        $.get(this.href, function(rsp){
          showStatus.respond(rsp);
          sammyApp.refresh();
        })
        return false;
      });
    
      // init
      adminWidget.loadWidgetPublished();
      adminNavigation.initSubs();
      $(document).trigger('ajaxify.form');
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
        adminNavigation.subTab($(this));
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
      adminNavigation.initSubs();
      $(document).trigger('ajaxify.form');
    },

    'admin/collect' : function(){
      $("ul.sub-tabs li a").click(function(){
        adminNavigation.subTab($(this));
      
        var tab = $(this).attr("href").substring(1);
        if (tab === "form"){
          adminWidget.loadFormPreview();
        }
        return false;
      });
    
      // init
      adminWidget.loadFormPreview();
      adminNavigation.initSubs();
      $(document).trigger('ajaxify.form');
    },
  
    'admin/install' : function(){
      $("ul.sub-tabs li a").click(function(){
        adminNavigation.subTab($(this));
        return false;
      });

      adminNavigation.initSubs();    
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
  }
})