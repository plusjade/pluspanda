/* 
 * page callbacks
 */ 
;var adminPages = {

  widget : function(){
    console.log("widget page callback invoked");
    
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
      showStatus.submitting();
      $.get(this.href, {rand: Math.random()}, function(data){
        widgetCss.setCode(data);
        showStatus.respond({status:'good', msg:'CSS Loaded!'});
      });
      return false;
    })        

    // subtabs
    $("#sub-tabs li a").click(function(){
      adminNavigation.subTab($(this));
      return false;
    });
    
    
    // init
    adminWidget.loadWidgetPreview();
    adminNavigation.initSubs();
  },


  // setup manage page
  manage : function(){
    console.log("manage callback");
    
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
    $("#sub-tabs li a").click(function(){
      $target = $(this);
      $("#data-description").html($target.attr('title'));
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
        var filter = $('ul.grandchild_nav li a.active').html().toLowerCase();
        admin.batchUpdate(ids, action, filter);
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
  },

  collect : function(){
    console.log("collect callback");
    
    $("#sub-tabs li a").click(function(){
      console.log("testychu");
      adminNavigation.subTab($(this));
      return false;
    });
    
    // init
    adminWidget.loadFormPreview();
    adminNavigation.initSubs();
  },
  
  install : function(){
    console.log("install callback");
    
    $("#sub-tabs li a").click(function(){
      console.log("testychu");
      adminNavigation.subTab($(this));
      return false;
    });

    adminNavigation.initSubs();    
  }

}