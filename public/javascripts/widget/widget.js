var panda = {
  loading: '<div class="ajax_loading">Loading...</div>',
  $container : null,
  pollTry: 0,
  admin : false,
  debug: false,
  
  init: function () {
    if (window.location.hash === '#panda.admin') panda.admin = true;
    if (window.location.hash === '#panda.debug') panda.debug = true;
    if (panda.debug){console.log("init called, expecting jQuery, then setup()")}
    if (typeof jQuery === 'undefined') { 
      if(panda.debug){console.log('no jQuery, expecting google cdn and poll(), then setup()')} 
      var script = document.createElement("script");
      script.type = "text/javascript";
      script.src = "http://ajax.googleapis.com/ajax/libs/jquery/1.4.2/jquery.min.js";    
      document.body.appendChild(script);
      panda.poll()
    } else {
      panda.setup()
    }
  },
  
  poll: function (){
    panda.pollTry = panda.pollTry+1;
    if (panda.debug){console.log("polling, expecting jQuery. Try#:" + panda.pollTry)}
    
    if (panda.pollTry > 25) { 
      var container = document.getElementById('plusPandaYes');
      container.innerHTML = 'pluspanda error! Could not load jquery';
    } else if (typeof jQuery === 'undefined') {  
      setTimeout("panda.poll()", 150);
    } else {
      panda.setup()
    }
  }, 

  setup: function(){ 
    if(panda.debug){console.log("setup called, expecting css, $container, delegation, then getTstmls()")}
    var cssUrl = pandaThemeConfig.cssUrl + ( panda.admin ? ('?r=' + Math.random()) : '' );
    jQuery('head').append('<link type="text/css" href="' + cssUrl + '" media="screen" rel="stylesheet" />');
    panda.$container = jQuery('#plusPandaYes').html(pandaThemeConfig.wrapperHTML);

    jQuery.delegate = function(rules) {return function(e) { var target = jQuery(e.target); for (var selector in rules) if (target.is(selector)) return rules[selector].apply(this, jQuery.makeArray(arguments));}}    
    panda.$container.click(jQuery.delegate({
      'a.show-more' : function(e){  
        var is_sort = e.target.href.indexOf('#');    
        var parent = (-1 == is_sort) ? 'a.show-more' : '.panda-testimonials-sorters a';
        var spltr = (-1 == is_sort) ? '?' : '#';

        // get GET params from links TOD0: optimize this?
        var hash = e.target.href.split(spltr)[1].split('&');
        var params = {"tag":"all","sort":"newest","page":1};
        for(x in hash){
            var arr = hash[x].split('=');
            params[arr[0]] = arr[1]; 
        }
        jQuery(e.target).remove();
        panda.getTstmls(params.tag, params.sort, params.page);
        return false;
      },

      'div.panda-tags ul a' : function(e){
        var tag = e.target.hash.substring(1);
        jQuery('div.panda-tags ul a').removeClass('active');
        jQuery(this).addClass('active');

        jQuery('div.panda-container').empty();
        panda.getTstmls(tag,'newest',1);
        return false;  
      }     
    }))
    if(panda.debug){console.log(cssUrl);console.log(panda.$container)}
    panda.getTstmls('all','newest',1)
    
    var $iframe = $('<iframe width="750px" height="390px" frameborder="0" scrolling="no">Iframe not Supported</iframe>');
    $iframe.attr('src',  pandaSettings.apiUrl + '/' + pandaSettings.apiVrsn + '/testimonials/new.iframe?apikey='+pandaSettings.apikey);
    panda.$container.find(".add-link a").click(function(){
        jQuery.facebox($iframe);
        return false;
      })

    if(!panda.admin)jQuery.get(pandaSettings.apiUrl+'/log/'+pandaSettings.apikey+"?"+parent.location.href)
  },


  /* get the testimonials as json. */
  getTstmls: function (tag, sort, page){
    if (panda.debug){console.log("getTstmls called(" + tag + '/' + sort + '/' + page+ ')');console.log('expecting callbacks: display(), update()')}
    jQuery('div.panda-container').append(panda.loading);
    jQuery.ajax({ 
        type:'GET', 
        url: pandaSettings.apiUrl + '/' + pandaSettings.apiVrsn + '/testimonials.js', 
        data:"apikey="+pandaSettings.apikey+"&tag="+tag+"&sort="+sort+"&page="+page, 
        dataType:'jsonp'
    }); 
  },
  
  clean: function (){
    jQuery('head script[src^="' + pandaSettings.apiUrl + '"]').remove();
  },  
  
  /* callback to format and inject testimonials data. */
  display: function (tstmls){
    if (panda.debug){console.log("display called, expecting updated content.");console.log(tstmls)}
    var content = '';
    var date = new Date();
    jQuery(tstmls).each(function(i){
      this.created_at = new Date(this.created_at).toDateString();
      if (this.image_src === false) this.image_src = this.image_stock;
      this.url     = (0 == this.url.length) ? '' : 'http://' + this.url;
      this.alt     = (0 == (i+1) % 2) ? 'even' : 'odd';
      this.tag_name = (this.tag_name)? this.tag_name : '';
      content  += pandaThemeConfig.testimonialHTML(this);
    });
    jQuery('div.panda-container .ajax_loading', panda.$container).replaceWith(content);
    if(panda.debug){console.log(content)}
    panda.clean()
  },

  /* callback to update display with pagination, counts, etc */
  update: function (data){
    if (panda.debug){console.log("update called, expecting total count and pagination updated.");console.log(data);}
    jQuery("#panda-total-testimonials").html(data.total);
    if(!data.nextPage) return false;
    var link = '<a href="' + data.nextPageUrl + '" class="show-more">Show More</a>';
    jQuery('div.panda-container').append(link);
  }
}
window.onload = panda.init();