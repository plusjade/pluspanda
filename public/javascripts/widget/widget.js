var panda = {
  loading: '<div class="ajax_loading">Loading...</div>',
  $container : null,
  $testimonials : null,
  $iframe : null,
  $total : null,
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
    if(pandaThemeConfig.cssUrl.length > 0) jQuery('head').append('<link type="text/css" href="' + cssUrl + '" media="screen" rel="stylesheet" />');

    panda.$container = jQuery('#plusPandaYes').html(pandaThemeConfig.wrapperHTML);
    panda.$testimonials = panda.$container.find('span.pandA-tWrapper_ness');
    panda.$totals = panda.$container.find("span.pandA-tCount_ness");
    panda.$tags = panda.$container.find("ul.pandA-tTags_ness");
    /*
    panda.$iframe = jQuery('<iframe width="750px" height="390px" frameborder="0" scrolling="no">Iframe not Supported</iframe>')
      .attr('src',  pandaSettings.apiUrl + '/' + pandaSettings.apiVrsn + '/testimonials/new.iframe?apikey='+pandaSettings.apikey);
    */
    panda.$container.find("a.show-more").live("click",function(){  
      var is_sort = this.href.indexOf('#');    
      var parent = (-1 == is_sort) ? 'a.show-more' : '.panda-testimonials-sorters a';
      var spltr = (-1 == is_sort) ? '?' : '#';

      // get GET params from links TOD0: optimize this?
      var hash = this.href.split(spltr)[1].split('&');
      var params = {"tag":"all","sort":"newest","page":1};
      for(x in hash){
          var arr = hash[x].split('=');
          params[arr[0]] = arr[1]; 
      }
      jQuery(this).remove();
      panda.getTstmls(params.tag, params.sort, params.page);
      return false;
    });
    panda.$tags.find("a").live("click", function(){
      var tag = this.hash.substring(1);
      panda.$tags.find('a').removeClass('active');
      jQuery(this).addClass('active');

      panda.$testimonials.empty();
      panda.getTstmls(tag,'newest',1);
      return false;  
    });
    /*     
    panda.$container.find(".add-link a").click(function(){
      jQuery.facebox(panda.$iframe);
      return false;
    });
    */
    if(panda.debug){console.log(cssUrl);console.log(panda.$container)}
    panda.getTstmls('all','newest',1)
    if(!panda.admin)jQuery.get(pandaSettings.apiUrl+'/log/'+pandaSettings.apikey+"?"+parent.location.href)
  },

  /* get the testimonials as json. */
  getTstmls: function (tag, sort, page){
    if(panda.debug){console.log("getTstmls called(" + tag + '/' + sort + '/' + page+ ')');console.log('expecting callbacks: display(), update()')}
    panda.$testimonials.append(panda.loading);
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
    if(panda.debug){console.log("display called, expecting updated content.");console.log(tstmls)}
    var content = '';
    jQuery(tstmls).each(function(i){
      this.created_at = new Date(this.created_at).toDateString();
      this.image_src  = (false === this.image_src) ? this.image_stock : this.image_src; 
      this.url        = (0 === this.url.length) ? '' : 'http://' + this.url;
      this.alt        = (0 === (i+1) % 2) ? 'even' : 'odd';
      this.tag_name   = (this.tag_name)? this.tag_name : '';
      content  += pandaThemeConfig.testimonialHTML(this);
    });
    panda.$testimonials.find(".ajax_loading").replaceWith(content);
    if(panda.debug) console.log(content);
    panda.clean();
  },

  /* callback to update display with pagination, counts, etc */
  update: function (data){
    if (panda.debug){console.log("update called, expecting total count and pagination updated.");console.log(data);}
    panda.$totals.html(data.total);
    if(!data.nextPage) return false;
    var link = '<a href="' + data.nextPageUrl + '" class="show-more">Show More</a>';
    panda.$testimonials.append(link);
  }
}
window.onload = panda.init();