var panda = {
  loading: '<div class="ajax_loading">Loading...</div>',
  $container : null,
  $tweets : null,
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
      var container = document.getElementById('plusPandaTweets');
      container.innerHTML = 'pluspanda error! Could not load jquery';
    } else if (typeof jQuery === 'undefined') {  
      setTimeout("panda.poll()", 150);
    } else {
      panda.setup()
    }
  }, 

  setup: function(){ 
    if(panda.debug){console.log("setup called, expecting css, $container, delegation, then getTweets()")}
    var cssUrl = pandaTweetThemeConfig.cssUrl + ( panda.admin ? ('?r=' + Math.random()) : '' );
    if(pandaTweetThemeConfig.cssUrl.length > 0) jQuery('head').append('<link type="text/css" href="' + cssUrl + '" media="screen" rel="stylesheet" />');

    panda.$container = jQuery('#plusPandaTweets').html(pandaTweetThemeConfig.wrapperHTML);
    panda.$tweets = panda.$container.find('span.pandA-tWrapper_ness');
    panda.$totals = panda.$container.find("span.pandA-tCount_ness");

    panda.$container.find("a.show-more").live("click",function(){  
      var is_sort = this.href.indexOf('#');    
      var parent = (-1 == is_sort) ? 'a.show-more' : '.panda-testimonials-sorters a';
      var spltr = (-1 == is_sort) ? '?' : '#';

      // get GET params from links TOD0: optimize this?
      var arr = this.href.split(spltr)[1].split('&');
      var params = {"tag":"all","sort":"newest","page":1};
      jQuery.each(arr, function(){
        var pair = this.toString().split('=');
        params[pair[0]] = pair[1]; 
      })
      jQuery(this).remove();
      panda.getTweets(params.tag, params.sort, params.page);
      return false;
    });


    if(panda.debug){console.log(cssUrl);console.log(panda.$container)}
    panda.getTweets('all','newest',1)
  },


  /* get the testimonials as json. */
  getTweets: function (tag, sort, page){
    if(panda.debug){console.log("getTweets called(" + tag + '/' + sort + '/' + page+ ')');console.log('expecting callbacks: display(), update()')}
    panda.$tweets.append(panda.loading);
    jQuery.ajax({ 
        type:'GET', 
        url: pandaTweetSettings.apiUrl + '/' + pandaTweetSettings.apiVrsn + '/tweets.js', 
        data:"apikey="+pandaTweetSettings.apikey+"&tag="+tag+"&sort="+sort+"&page="+page, 
        dataType:'jsonp'
    }); 
  },
  
  clean: function (){
    jQuery('head script[src^="' + pandaTweetSettings.apiUrl + '"]').remove();
  },  
  
  /* callback to format and inject tweet data. */
  display: function (tweets){
    if(panda.debug){console.log("display called, expecting updated content.");console.log(tweets)}
    var content = '';
    jQuery(tweets).each(function(i){
      this.user.profile_image_url = '<img src="'+ this.user.profile_image_url +'" />';
      this.alt = (0 === (i+1) % 2) ? 'even' : 'odd';
      content += pandaTweetThemeConfig.tweetHTML(this);
    });
    panda.$tweets.find(".ajax_loading").replaceWith(content);
    if(panda.debug) console.log(content);
    panda.clean();
  },

  /* callback to update display with pagination, counts, etc */
  update: function (data){
    if (panda.debug){console.log("update called, expecting total count and pagination updated.");console.log(data);}
    panda.$totals.html(data.total);
    if(!data.nextPage) return false;
    var link = '<a href="' + data.nextPageUrl + '" class="show-more">Show More</a>';
    panda.$tweets.append(link);
  }
}
window.onload = panda.init();