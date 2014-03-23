var panda = function() {
    var loadingMessage = '<div class="ajax_loading">Loading...</div>',
        $container,
        $testimonials,
        $total,
        pollTry = 0,
        isAdmin = false,
        isDebug = false
        ;

    function init() {
        if (window.location.hash === '#panda.admin') isAdmin = true;
        if (window.location.hash === '#panda.debug') isDebug = true;
        if (isDebug) {
            console.log("init called, expecting jQuery, then setup()");
        }

        if (typeof jQuery === 'undefined') { 
            if(isDebug) {
                console.log('no jQuery, expecting google cdn and poll(), then setup()');
            } 
            var script = document.createElement("script");
            script.type = "text/javascript";
            script.src = "https://ajax.googleapis.com/ajax/libs/jquery/1.9.0/jquery.min.js";
            document.body.appendChild(script);
            poll();
        }
        else {
            setup();
        }
    }

    function poll() {
        if (isDebug) {
            console.log("polling, expecting jQuery. Try#:" + pollTry);
        }

        pollTry += 1;

        if (pollTry > 25) {
            var container = document.getElementById('plusPandaYes');
            container.innerHTML = 'pluspanda error! Could not load jquery';
        }
        else if (typeof jQuery === 'undefined') {
            setTimeout(function() { poll() }, 150);
        }
        else {
           setup();
        }
    }

    function setup() {
        if(isDebug) {
            console.log("setup called, expecting css, $container, delegation, then getTestimonials()");
        }
        var cssUrl = pandaThemeConfig.cssUrl + ( isAdmin ? ('?r=' + Math.random()) : '' );
        if(pandaThemeConfig.cssUrl.length > 0) {
            jQuery('head').append('<link type="text/css" href="' + cssUrl + '" media="screen" rel="stylesheet" />');
        }

        $container = jQuery('#plusPandaYes').html(pandaThemeConfig.wrapperHTML);
        $testimonials = $container.find('span.pandA-tWrapper_ness');
        $totals = $container.find("span.pandA-tCount_ness");
        $tags = $container.find("ul.pandA-tTags_ness");

        var version = jQuery.fn.jquery.split('.');
        version = parseInt(version[0] + version[1]);

        if(version >= 17) {
            $container.on("click", 'a.show-more', showMore);
            $tags.on("click", 'a', showTags);
        }
        else {
            $container.find("a.show-more").live("click", showMore);
            $tags.find("a").live("click", showTags);
        }

        initFacebox(jQuery);

        if(isDebug) {
            console.log(cssUrl);console.log($container)
        }

        getTestimonials('all','newest',1);
    }

    function showMore(e) {
        e.preventDefault();
        var is_sort = e.currentTarget.href.indexOf('#');
        var parent = (-1 == is_sort) ? 'a.show-more' : '.panda-testimonials-sorters a';
        var spltr = (-1 == is_sort) ? '?' : '#';

        // get GET params from links TOD0: optimize this?
        var arr = e.currentTarget.href.split(spltr)[1].split('&');
        var params = {"tag":"all","sort":"newest","page":1};
        jQuery.each(arr, function() {
            var pair = this.toString().split('=');
            params[pair[0]] = pair[1]; 
        })

        jQuery(e.currentTarget).remove();
        getTestimonials(params.tag, params.sort, params.page);
    }

    function showTags (e) {
        e.preventDefault();
        var tag = e.currentTarget.hash.substring(1);
        $tags.find('a').removeClass('active');
        jQuery(e.currentTarget).addClass('active');

        $testimonials.empty();
        getTestimonials(tag, 'newest', 1);
    }

    // get the testimonials as json.
    function getTestimonials(tag, sort, page) {
        if(isDebug) {
            console.log("getTestimonials called(" + tag + '/' + sort + '/' + page+ ')');
            console.log('expecting callbacks: display(), update()')
        }

        $testimonials.append(loadingMessage);
        jQuery.ajax({
            type:'GET', 
            url: pandaSettings.apiUrl + '/' + pandaSettings.apiVrsn + '/testimonials.js', 
            data:"apikey="+pandaSettings.apikey+"&tag="+tag+"&sort="+sort+"&page="+page, 
            dataType:'jsonp'
        }); 
    }

    function clean() {
        jQuery('head script[src^="' + pandaSettings.apiUrl + '"]').remove();
    }

    // callback to format and inject testimonials data.
    function display(tstmls) {
        if(isDebug) {
            console.log("display called, expecting updated content.");console.log(tstmls)
        }

        var content = '';
        jQuery(tstmls).each(function(i) {
            this.created_at = new Date(this.created_at).toDateString();
            this.image  = (false === this.image) ? this.image_stock : this.image; 
            this.image  = '<img src="'+ this.image +'" />';
            if(this.url.length > 0) {
                this.url    = '<a href="http://' + this.url + '" target="_blank">http://' + this.url + ' </a>';
            }
            this.alt = (0 === (i+1) % 2) ? 'even' : 'odd';
            this.tag_name = (this.tag_name)? this.tag_name : '';
            content  += pandaThemeConfig.testimonialHTML(this);
        });
        if(isDebug) {
            console.log(content)
        }

        $testimonials.find(".ajax_loading").replaceWith(content);
        clean();
    }

    // callback to update display with pagination, counts, etc
    function update(data) {
        if (isDebug) {
            console.log("update called, expecting total count and pagination updated.");
            console.log(data);
        }

        $totals.html(data.total);
        if(!data.nextPage) return false;

        var link = '<a href="' + data.nextPageUrl + '" class="show-more">Show More</a>';
        $testimonials.append(link);
    }

    // Facebox (for jQuery)
    // @homepage https://github.com/defunkt/facebox
    function initFacebox($) {
      $.facebox = function(data, klass) {
        $.facebox.loading()

        if (data.ajax) fillFaceboxFromAjax(data.ajax, klass)
        else if (data.image) fillFaceboxFromImage(data.image, klass)
        else if (data.div) fillFaceboxFromHref(data.div, klass)
        else if ($.isFunction(data)) data.call($)
        else $.facebox.reveal(data, klass)
      }

      /*
       * Public, $.facebox methods
       */

      $.extend($.facebox, {
        settings: {
          opacity      : 0.7,
          overlay      : true,
          loadingImage : '/images/loading.gif',
          closeImage   : '/images/closelabel.png',
          imageTypes   : [ 'png', 'jpg', 'jpeg', 'gif' ],
          faceboxHtml  : '\
        <div id="facebox" style="display:none;"> \
          <div class="popup"> \
            <div class="content"> \
            </div> \
            <a href="#" class="close">CLOSE</a> \
          </div> \
        </div>'
        },

        loading: function() {
          init()
          if ($('#facebox .loading').length == 1) return true
          showOverlay()

          $('#facebox .content').empty()
          $('#facebox .body').children().hide().end().
            append('<div class="loading"><img src="'+$.facebox.settings.loadingImage+'"/></div>')

          $('#facebox').css({
            top:    getPageScroll()[1] + (getPageHeight() / 10),
            left:   $(window).width() / 2 - 205
          }).show()

          $(document).bind('keydown.facebox', function(e) {
            if (e.keyCode == 27) $.facebox.close()
            return true
          })
          $(document).trigger('loading.facebox')
        },

        reveal: function(data, klass) {
          $(document).trigger('beforeReveal.facebox')
          if (klass) $('#facebox .content').addClass(klass)
          $('#facebox .content').append(data)
          $('#facebox .loading').remove()
          $('#facebox .body').children().fadeIn('normal')
          $('#facebox').css('left', $(window).width() / 2 - ($('#facebox .popup').width() / 2))
          $(document).trigger('reveal.facebox').trigger('afterReveal.facebox')
        },

        close: function() {
          $(document).trigger('close.facebox')
          return false
        }
      })

      /*
       * Public, $.fn methods
       */

      $.fn.facebox = function(settings) {
        if ($(this).length == 0) return

        init(settings)

        function clickHandler() {
          $.facebox.loading(true)

          // support for rel="facebox.inline_popup" syntax, to add a class
          // also supports deprecated "facebox[.inline_popup]" syntax
          var klass = this.rel.match(/facebox\[?\.(\w+)\]?/)
          if (klass) klass = klass[1]

          fillFaceboxFromHref(this.href, klass)
          return false
        }

        return this.bind('click.facebox', clickHandler)
      }

      /*
       * Private methods
       */

      // called one time to setup facebox on this page
      function init(settings) {
        if ($.facebox.settings.inited) return true
        else $.facebox.settings.inited = true

        $(document).trigger('init.facebox')
        makeCompatible()

        var imageTypes = $.facebox.settings.imageTypes.join('|')
        $.facebox.settings.imageTypesRegexp = new RegExp('\.(' + imageTypes + ')$', 'i')

        if (settings) $.extend($.facebox.settings, settings)
        $('body').append($.facebox.settings.faceboxHtml)

        var preload = [ new Image(), new Image() ]
        preload[0].src = $.facebox.settings.closeImage
        preload[1].src = $.facebox.settings.loadingImage

        $('#facebox').find('.b:first, .bl').each(function() {
          preload.push(new Image())
          preload.slice(-1).src = $(this).css('background-image').replace(/url\((.+)\)/, '$1')
        })

        $('#facebox .close').click($.facebox.close)
        $('#facebox .close_image').attr('src', $.facebox.settings.closeImage)
      }

      // getPageScroll() by quirksmode.com
      function getPageScroll() {
        var xScroll, yScroll;
        if (self.pageYOffset) {
          yScroll = self.pageYOffset;
          xScroll = self.pageXOffset;
        } else if (document.documentElement && document.documentElement.scrollTop) {     // Explorer 6 Strict
          yScroll = document.documentElement.scrollTop;
          xScroll = document.documentElement.scrollLeft;
        } else if (document.body) {// all other Explorers
          yScroll = document.body.scrollTop;
          xScroll = document.body.scrollLeft;
        }
        return new Array(xScroll,yScroll)
      }

      // Adapted from getPageSize() by quirksmode.com
      function getPageHeight() {
        var windowHeight
        if (self.innerHeight) { // all except Explorer
          windowHeight = self.innerHeight;
        } else if (document.documentElement && document.documentElement.clientHeight) { // Explorer 6 Strict Mode
          windowHeight = document.documentElement.clientHeight;
        } else if (document.body) { // other Explorers
          windowHeight = document.body.clientHeight;
        }
        return windowHeight
      }

      // Backwards compatibility
      function makeCompatible() {
        var $s = $.facebox.settings

        $s.loadingImage = $s.loading_image || $s.loadingImage
        $s.closeImage = $s.close_image || $s.closeImage
        $s.imageTypes = $s.image_types || $s.imageTypes
        $s.faceboxHtml = $s.facebox_html || $s.faceboxHtml
      }

      // Figures out what you want to display and displays it
      // formats are:
      //     div: #id
      //   image: blah.extension
      //    ajax: anything else
      function fillFaceboxFromHref(href, klass) {
        // div
        if (href.match(/#/)) {
          var url    = window.location.href.split('#')[0]
          var target = href.replace(url,'')
          if (target == '#') return
          $.facebox.reveal($(target).html(), klass)

        // image
        } else if (href.match($.facebox.settings.imageTypesRegexp)) {
          fillFaceboxFromImage(href, klass)
        // ajax
        } else {
          fillFaceboxFromAjax(href, klass)
        }
      }

      function fillFaceboxFromImage(href, klass) {
        var image = new Image()
        image.onload = function() {
          $.facebox.reveal('<div class="image"><img src="' + image.src + '" /></div>', klass)
        }
        image.src = href
      }

      function fillFaceboxFromAjax(href, klass) {
        $.get(href, function(data) { $.facebox.reveal(data, klass) })
      }

      function skipOverlay() {
        return $.facebox.settings.overlay == false || $.facebox.settings.opacity === null
      }

      function showOverlay() {
        if (skipOverlay()) return

        if ($('#facebox_overlay').length == 0)
          $("body").append('<div id="facebox_overlay" class="facebox_hide"></div>')

        $('#facebox_overlay').hide().addClass("facebox_overlayBG")
          .css('opacity', $.facebox.settings.opacity)
          .click(function() { $(document).trigger('close.facebox') })
          .fadeIn(200)
        return false
      }

      function hideOverlay() {
        if (skipOverlay()) return

        $('#facebox_overlay').fadeOut(200, function(){
          $("#facebox_overlay").removeClass("facebox_overlayBG")
          $("#facebox_overlay").addClass("facebox_hide")
          $("#facebox_overlay").remove()
        })

        return false
      }

      /*
       * Bindings
       */

      $(document).bind('close.facebox', function() {
        $(document).unbind('keydown.facebox')
        $('#facebox').fadeOut(function() {
          $('#facebox .content').removeClass().addClass('content')
          $('#facebox .loading').remove()
          $(document).trigger('afterClose.facebox')
        })
        hideOverlay()
      })

      bindFacebox();
    }

    function bindFacebox() {
        var $iframe = jQuery('<iframe width="600px" height="390px" frameborder="0" scrolling="auto">Iframe not Supported</iframe>')
                        .attr('src',  pandaSettings.apiUrl + '/' + pandaSettings.apiVrsn + '/testimonials/new.iframe?apikey='+pandaSettings.apikey);

        $container.find("a.pandA-addForm_ness").click(function() {
            jQuery.facebox($iframe);
            return false;
        });
    }

    return {
        init: init,
        display: display,
        update: update
    }
}();

window.onload = panda.init();
