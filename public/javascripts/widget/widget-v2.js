var panda = (function() {
    var loadingMessage = '<div class="ajax_loading">Loading...</div>',
        $container,
        $testimonials,
        $total,
        $showMore,
        pollTry = 0,
        isAdmin = false
        ;

    // noop
    function log(message) { }

    function init() {
        if (window.location.hash === '#panda.admin') isAdmin = true;
        if (window.location.hash === '#panda.debug') {
            log = function(message) { console.log(message) };
        }
        log("init called, expecting jQuery, then setup()");

        if (typeof jQuery === 'undefined') { 
            log('no jQuery, expecting google cdn and poll(), then setup()');
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
        log("polling, expecting jQuery. Try#:" + pollTry);

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
        log("setup called, expecting css, $container, delegation, then getTestimonials()");

        var cssUrl = pandaThemeConfig.cssUrl + ( isAdmin ? ('?r=' + Math.random()) : '' );
        if(pandaThemeConfig.cssUrl.length > 0) {
            jQuery('head').append('<link type="text/css" href="' + cssUrl + '" media="screen" rel="stylesheet" />');
        }

        $container = jQuery('#plusPandaYes').html(pandaThemeConfig.wrapperHTML);
        $testimonials = $container.find('span.pandA-tWrapper_ness');
        $totals = $container.find("span.pandA-tCount_ness");

        var version = jQuery.fn.jquery.split('.');
        version = parseInt(version[0] + version[1]);

        var $formContainer = $container.find('.panda-form-container');

        $container.find("a.pandA-addForm_ness").click(function(e) {
            e.preventDefault();

            if ($formContainer.find('iframe').length > 0) {
                $formContainer.toggle();
            }
            else {
                $formContainer.html(
                    jQuery('<iframe width="100%" height="390px" frameborder="0" scrolling="auto" allowtransparency="true">Iframe not Supported</iframe>')
                        .attr('src',  pandaSettings.formEndpoint)
                );
            }
        });

        var $showMoreTemplate = $container.find(".show-more");
        if($showMoreTemplate.length > 0) {
            $showMore = $showMoreTemplate.clone();
            $showMoreTemplate.remove();
        } 
        else {
            $showMore = $('<a>show more</a>');
        }

        log(cssUrl);
        log($container);

        getTestimonials('all','newest',1);
    }

    // get the testimonials as json.
    function getTestimonials(tag, sort, page) {
        log('expecting callbacks: display(), update()');
        log("getTestimonials called with");
        var url, data = {};

        if (arguments.length === 1) {
            url = arguments[0];
            log(url);
        }
        else {
            url = pandaSettings.testimonialsEndpoint;
            data = {
                apikey: pandaSettings.apikey,
                tag: tag,
                sort: sort,
                page: page
            }
            log(data);
        }

        $testimonials.append(loadingMessage);
        return jQuery.ajax({
            type:'GET', 
            url: url,
            data: data, 
            dataType:'jsonp'
        }); 
    }

    function clean() {
        jQuery('head script[src^="' + pandaSettings.apiUrl + '"]').remove();
    }

    // callback to format and inject testimonials data.
    function display(tstmls) {
        log("display called, expecting updated content");
        log(tstmls);

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

        log(content);

        $testimonials.find(".ajax_loading").replaceWith(content);
        clean();
    }

    // callback to update display with pagination, counts, etc
    function update(data) {
        log("update called, expecting total count and pagination updated.");
        log(data);

        $totals.html(data.total);
        if(data.nextPage) {
            $showMore
                .clone()
                .attr('href', '#')
                .appendTo($testimonials)
                .click(function(e) {
                    e.preventDefault();
                    getTestimonials(data.nextPageUrl);
                    jQuery(this).remove();
                });
        }
    }

    return {
        init: init,
        display: display,
        update: update
    }
}());

window.onload = panda.init();
