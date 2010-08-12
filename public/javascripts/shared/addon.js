
/* Event delegation*/
jQuery.delegate = function(rules) {return function(e) { var target = $(e.target); for (var selector in rules) if (target.is(selector)) return rules[selector].apply(this, $.makeArray(arguments));}}

/* Public Form Validation */
jQuery.fn.jade_validate=function(){$(this).removeClass("input_error");$(this).parent('fieldset').removeClass("field_error");$("span.error_msg").remove();var nameRegex=/^[a-zA-Z]+(([\'\,\.\- ][a-zA-Z ])?[a-zA-Z]*)*$/;var emailRegex=/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;var urlRegex=/^[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}$/;var phoneRegex=/^[0-9\-\.\(\)\s]+$/;var errors=false;this.each(function(){var rel=$(this).attr("rel");var val=$.trim(this.value);switch(rel){case"text_req":if(!val){$(this).addClass("input_error");$(this).parent('fieldset').addClass("field_error");$(this).after(' <span class="error_msg">Cannot be blank</span>');errors=true;} break;case"email_req":if(!val.match(emailRegex)){$(this).addClass("input_error");$(this).parent('fieldset').addClass("field_error");$(this).after(' <span class="error_msg">Invalid email</span>');errors=true;} break;case"url_req":if(!val.match(urlRegex)){$(this).addClass("input_error");$(this).parent('fieldset').addClass("field_error");$(this).after(' <span class="error_msg">Invalid url</span>');errors=true;} break;case"phone_req":if(!val.match(phoneRegex)){$(this).addClass("input_error");$(this).parent('fieldset').addClass("field_error");$(this).after(' <span class="error_msg">Numbers, spaces, and () - . only please.</span>');errors=true;} break;}});if(errors)return false;else return true;};

/*
 * timeago: a jQuery plugin, version: 0.7.1 (2009-02-18)
 * @requires jQuery v1.2 or later
 * Timeago is a jQuery plugin that makes it easy to support automatically
 * updating fuzzy timestamps (e.g. "4 minutes ago" or "about 1 day ago").
 * For usage and examples, visit:
 * http://timeago.yarp.com/
 * Licensed under the MIT:
 * http://www.opensource.org/licenses/mit-license.php
 * Copyright (c) 2008-2009, Ryan McGeary (ryanonjavascript -[at]- mcgeary [*dot*] org)
 */
;(function($){$.timeago=function(timestamp){if(timestamp instanceof Date)return inWords(timestamp);else if(typeof timestamp=="string")return inWords($.timeago.parse(timestamp));else return inWords($.timeago.parse($(timestamp).attr("title")));};var $t=$.timeago;$.extend($.timeago,{settings:{refreshMillis:60000,allowFuture:false,strings:{prefixAgo:null,prefixFromNow:null,suffixAgo:"ago",suffixFromNow:"from now",ago:null,fromNow:null,seconds:"seconds",minute:"a minute",minutes:"%d minutes",hour:"an hour",hours:"%d hours",day:"a day",days:"%d days",month:"a month",months:"%d months",year:"a year",years:"%d years"}},inWords:function(distanceMillis){var $l=this.settings.strings;var prefix=$l.prefixAgo;var suffix=$l.suffixAgo||$l.ago;if(this.settings.allowFuture){if(distanceMillis<0){prefix=$l.prefixFromNow;suffix=$l.suffixFromNow||$l.fromNow;} distanceMillis=Math.abs(distanceMillis);} var seconds=distanceMillis/1000;var minutes=seconds/60;var hours=minutes/60;var days=hours/24;var years=days/365;var words=seconds<45&&substitute($l.seconds,Math.round(seconds))||seconds<90&&substitute($l.minute,1)||minutes<45&&substitute($l.minutes,Math.round(minutes))||minutes<90&&substitute($l.hour,1)||hours<24&&substitute($l.hours,Math.round(hours))||hours<48&&substitute($l.day,1)||days<30&&substitute($l.days,Math.floor(days))||days<60&&substitute($l.month,1)||days<365&&substitute($l.months,Math.floor(days/30))||years<2&&substitute($l.year,1)||substitute($l.years,Math.floor(years));return $.trim([prefix,words,suffix].join(" "));},parse:function(iso8601){var s=$.trim(iso8601);s=s.replace(/-/,"/").replace(/-/,"/");s=s.replace(/T/," ").replace(/Z/," UTC");s=s.replace(/([\+-]\d\d)\:?(\d\d)/," $1$2");return new Date(s);}});$.fn.timeago=function(){var self=this;self.each(refresh);var $s=$t.settings;if($s.refreshMillis>0){setInterval(function(){self.each(refresh);},$s.refreshMillis);} return self;};function refresh(){var date=$t.parse(this.title);if(!isNaN(date)){$(this).text(inWords(date));} return this;} function inWords(date){return $t.inWords(distance(date));} function distance(date){return(new Date().getTime()-date.getTime());} function substitute(stringOrFunction,value){var string=$.isFunction(stringOrFunction)?stringOrFunction(value):stringOrFunction;return string.replace(/%d/i,value);} if($.browser.msie&&$.browser.version<7.0){document.createElement('abbr');}})(jQuery);

// Adapted from getPageSize() by quirksmode.com
jQuery.getPageHeight = function() {
	var windowHeight;
	if (self.innerHeight) { windowHeight = self.innerHeight; }
	else if (document.documentElement && document.documentElement.clientHeight) {windowHeight = document.documentElement.clientHeight;}
	else if (document.body) { windowHeight = document.body.clientHeight;}	
	return windowHeight
};

// getPageScroll() by quirksmode.com
jQuery.getPageScroll = function() {
  var xScroll, yScroll;
  if (self.pageYOffset) {
    yScroll = self.pageYOffset;
    xScroll = self.pageXOffset;
  } else if (document.documentElement && document.documentElement.scrollTop) {	 // Explorer 6 Strict
    yScroll = document.documentElement.scrollTop;
    xScroll = document.documentElement.scrollLeft;
  } else if (document.body) {// all other Explorers
    yScroll = document.body.scrollTop;
    xScroll = document.body.scrollLeft;
  }
  return new Array(xScroll,yScroll)
};

/*
 * jQuery Form Plugin
 * version: 2.21 (08-FEB-2009)
 * @requires jQuery v1.2.2 or later
 * Examples and documentation at: http://malsup.com/jquery/form/
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 */
;(function($) {
$.fn.ajaxSubmit = function(options) {
    if (!this.length) {
        log('ajaxSubmit: skipping submit process - no element selected');
        return this;
    }
    if (typeof options == 'function')
        options = { success: options };
    options = $.extend({
        url:  this.attr('action') || window.location.toString(),
        type: this.attr('method') || 'GET'
    }, options || {});
    var veto = {};
    this.trigger('form-pre-serialize', [this, options, veto]);
    if (veto.veto) {
        log('ajaxSubmit: submit vetoed via form-pre-serialize trigger');
        return this;
    }
    if (options.beforeSerialize && options.beforeSerialize(this, options) === false) {
        log('ajaxSubmit: submit aborted via beforeSerialize callback');
        return this;
    }      
    var a = this.formToArray(options.semantic);
    if (options.data) {
        options.extraData = options.data;
        for (var n in options.data) {
          if(options.data[n] instanceof Array) {
            for (var k in options.data[n])
              a.push( { name: n, value: options.data[n][k] } )
          }  
          else
             a.push( { name: n, value: options.data[n] } );
        }
    }
    if (options.beforeSubmit && options.beforeSubmit(a, this, options) === false) {
        log('ajaxSubmit: submit aborted via beforeSubmit callback');
        return this;
    }    
    this.trigger('form-submit-validate', [a, this, options, veto]);
    if (veto.veto) {
        log('ajaxSubmit: submit vetoed via form-submit-validate trigger');
        return this;
    }    
    var q = $.param(a);
    if (options.type.toUpperCase() == 'GET') {
        options.url += (options.url.indexOf('?') >= 0 ? '&' : '?') + q;
        options.data = null;  
    }
    else
        options.data = q; 
    var $form = this, callbacks = [];
    if (options.resetForm) callbacks.push(function() { $form.resetForm(); });
    if (options.clearForm) callbacks.push(function() { $form.clearForm(); });
    if (!options.dataType && options.target) {
        var oldSuccess = options.success || function(){};
        callbacks.push(function(data) {
            $(options.target).html(data).each(oldSuccess, arguments);
        });
    }
    else if (options.success)
        callbacks.push(options.success);
    options.success = function(data, status) {
        for (var i=0, max=callbacks.length; i < max; i++)
            callbacks[i].apply(options, [data, status, $form]);
    };
    var files = $('input:file', this).fieldValue();
    var found = false;
    for (var j=0; j < files.length; j++)
        if (files[j])
            found = true;
   if (options.iframe || found) { 
       if (options.closeKeepAlive)
           $.get(options.closeKeepAlive, fileUpload);
       else
           fileUpload();
       }
   else
       $.ajax(options);
    this.trigger('form-submit-notify', [this, options]);
    return this;
    function fileUpload() {
        var form = $form[0];
        
        if ($(':input[name=submit]', form).length) {
            alert('Error: Form elements must not be named "submit".');
            return;
        }
        
        var opts = $.extend({}, $.ajaxSettings, options);
		var s = jQuery.extend(true, {}, $.extend(true, {}, $.ajaxSettings), opts);
        var id = 'jqFormIO' + (new Date().getTime());
        var $io = $('<iframe id="' + id + '" name="' + id + '" src="about:blank" />');
        var io = $io[0];
        $io.css({ position: 'absolute', top: '-1000px', left: '-1000px' });
        var xhr = { // mock object
            aborted: 0,
            responseText: null,
            responseXML: null,
            status: 0,
            statusText: 'n/a',
            getAllResponseHeaders: function() {},
            getResponseHeader: function() {},
            setRequestHeader: function() {},
            abort: function() { 
                this.aborted = 1; 
                $io.attr('src','about:blank'); // abort op in progress
            }
        };
        var g = opts.global;
        // trigger ajax global events so that activity/block indicators work like normal
        if (g && ! $.active++) $.event.trigger("ajaxStart");
        if (g) $.event.trigger("ajaxSend", [xhr, opts]);
		if (s.beforeSend && s.beforeSend(xhr, s) === false) {
			s.global && jQuery.active--;
			return;
        }
        if (xhr.aborted)
            return;
        
        var cbInvoked = 0;
        var timedOut = 0;
        var sub = form.clk;
        if (sub) {
            var n = sub.name;
            if (n && !sub.disabled) {
                options.extraData = options.extraData || {};
                options.extraData[n] = sub.value;
                if (sub.type == "image") {
                    options.extraData[name+'.x'] = form.clk_x;
                    options.extraData[name+'.y'] = form.clk_y;
                }
            }
        }
        setTimeout(function() {
            var t = $form.attr('target'), a = $form.attr('action');
			form.setAttribute('target',id);
			if (form.getAttribute('method') != 'POST')
				form.setAttribute('method', 'POST');
			if (form.getAttribute('action') != opts.url)
				form.setAttribute('action', opts.url);
            if (! options.skipEncodingOverride) {
                $form.attr({
                    encoding: 'multipart/form-data',
                    enctype:  'multipart/form-data'
                });
            }
            if (opts.timeout)
                setTimeout(function() { timedOut = true; cb(); }, opts.timeout);
            var extraInputs = [];
            try {
                if (options.extraData)
                    for (var n in options.extraData)
                        extraInputs.push(
                            $('<input type="hidden" name="'+n+'" value="'+options.extraData[n]+'" />')
                                .appendTo(form)[0]);
                $io.appendTo('body');
                io.attachEvent ? io.attachEvent('onload', cb) : io.addEventListener('load', cb, false);
                form.submit();
            }
            finally {
				form.setAttribute('action',a);
                t ? form.setAttribute('target', t) : $form.removeAttr('target');
                $(extraInputs).remove();
            }
        }, 10);
        var nullCheckFlag = 0;
		
        function cb() {
            if (cbInvoked++) return;
            
            io.detachEvent ? io.detachEvent('onload', cb) : io.removeEventListener('load', cb, false);
            var ok = true;
            try {
                if (timedOut) throw 'timeout';
                var data, doc;
                doc = io.contentWindow ? io.contentWindow.document : io.contentDocument ? io.contentDocument : io.document;
                
                if ((doc.body == null || doc.body.innerHTML == '') && !nullCheckFlag) {
                    nullCheckFlag = 1;
                    cbInvoked--;
                    setTimeout(cb, 100);
                    return;
                }
                
                xhr.responseText = doc.body ? doc.body.innerHTML : null;
                xhr.responseXML = doc.XMLDocument ? doc.XMLDocument : doc;
                xhr.getResponseHeader = function(header){
                    var headers = {'content-type': opts.dataType};
                    return headers[header];
                };
                if (opts.dataType == 'json' || opts.dataType == 'script') {
                    var ta = doc.getElementsByTagName('textarea')[0];
                    xhr.responseText = ta ? ta.value : xhr.responseText;
                }
                else if (opts.dataType == 'xml' && !xhr.responseXML && xhr.responseText != null) {
                    xhr.responseXML = toXml(xhr.responseText);
                }
                data = $.httpData(xhr, opts.dataType);
            }
            catch(e){
                ok = false;
                $.handleError(opts, xhr, 'error', e);
            } 
            if (ok) {
                opts.success(data, 'success');
                if (g) $.event.trigger("ajaxSuccess", [xhr, opts]);
            }
            if (g) $.event.trigger("ajaxComplete", [xhr, opts]);
            if (g && ! --$.active) $.event.trigger("ajaxStop");
            if (opts.complete) opts.complete(xhr, ok ? 'success' : 'error');
            setTimeout(function() {
                $io.remove();
                xhr.responseXML = null;
            }, 100);
        };
        function toXml(s, doc) {
            if (window.ActiveXObject) {
                doc = new ActiveXObject('Microsoft.XMLDOM');
                doc.async = 'false';
                doc.loadXML(s);
            }
            else
                doc = (new DOMParser()).parseFromString(s, 'text/xml');
            return (doc && doc.documentElement && doc.documentElement.tagName != 'parsererror') ? doc : null;
        };
    };
};
$.fn.ajaxForm = function(options) {
    return this.ajaxFormUnbind().bind('submit.form-plugin',function() {
        $(this).ajaxSubmit(options);
        return false;
    }).each(function() {
        $(":submit,input:image", this).bind('click.form-plugin',function(e) {
            var form = this.form;
            form.clk = this;
            if (this.type == 'image') {
                if (e.offsetX != undefined) {
                    form.clk_x = e.offsetX;
                    form.clk_y = e.offsetY;
                } else if (typeof $.fn.offset == 'function') { // try to use dimensions plugin
                    var offset = $(this).offset();
                    form.clk_x = e.pageX - offset.left;
                    form.clk_y = e.pageY - offset.top;
                } else {
                    form.clk_x = e.pageX - this.offsetLeft;
                    form.clk_y = e.pageY - this.offsetTop;
                }
            }
            // clear form vars
            setTimeout(function() { form.clk = form.clk_x = form.clk_y = null; }, 10);
        });
    });
};
$.fn.ajaxFormUnbind = function() {
    this.unbind('submit.form-plugin');
    return this.each(function() {
        $(":submit,input:image", this).unbind('click.form-plugin');
    });
};
$.fn.formToArray = function(semantic) {
    var a = [];
    if (this.length == 0) return a;
    var form = this[0];
    var els = semantic ? form.getElementsByTagName('*') : form.elements;
    if (!els) return a;
    for(var i=0, max=els.length; i < max; i++) {
        var el = els[i];
        var n = el.name;
        if (!n) continue;
        if (semantic && form.clk && el.type == "image") {
            if(!el.disabled && form.clk == el)
                a.push({name: n+'.x', value: form.clk_x}, {name: n+'.y', value: form.clk_y});
            continue;
        }
        var v = $.fieldValue(el, true);
        if (v && v.constructor == Array) {
            for(var j=0, jmax=v.length; j < jmax; j++)
                a.push({name: n, value: v[j]});
        }
        else if (v !== null && typeof v != 'undefined')
            a.push({name: n, value: v});
    }
    if (!semantic && form.clk) {
        var inputs = form.getElementsByTagName("input");
        for(var i=0, max=inputs.length; i < max; i++) {
            var input = inputs[i];
            var n = input.name;
            if(n && !input.disabled && input.type == "image" && form.clk == input)
                a.push({name: n+'.x', value: form.clk_x}, {name: n+'.y', value: form.clk_y});
        }
    }
    return a;
};
$.fn.formSerialize = function(semantic) {
    return $.param(this.formToArray(semantic));
};
$.fn.fieldSerialize = function(successful) {
    var a = [];
    this.each(function() {
        var n = this.name;
        if (!n) return;
        var v = $.fieldValue(this, successful);
        if (v && v.constructor == Array) {
            for (var i=0,max=v.length; i < max; i++)
                a.push({name: n, value: v[i]});
        }
        else if (v !== null && typeof v != 'undefined')
            a.push({name: this.name, value: v});
    });
    return $.param(a);
};
$.fn.fieldValue = function(successful) {
    for (var val=[], i=0, max=this.length; i < max; i++) {
        var el = this[i];
        var v = $.fieldValue(el, successful);
        if (v === null || typeof v == 'undefined' || (v.constructor == Array && !v.length))
            continue;
        v.constructor == Array ? $.merge(val, v) : val.push(v);
    }
    return val;
};
$.fieldValue = function(el, successful) {
    var n = el.name, t = el.type, tag = el.tagName.toLowerCase();
    if (typeof successful == 'undefined') successful = true;
    if (successful && (!n || el.disabled || t == 'reset' || t == 'button' ||
        (t == 'checkbox' || t == 'radio') && !el.checked ||
        (t == 'submit' || t == 'image') && el.form && el.form.clk != el ||
        tag == 'select' && el.selectedIndex == -1))
            return null;
    if (tag == 'select') {
        var index = el.selectedIndex;
        if (index < 0) return null;
        var a = [], ops = el.options;
        var one = (t == 'select-one');
        var max = (one ? index+1 : ops.length);
        for(var i=(one ? index : 0); i < max; i++) {
            var op = ops[i];
            if (op.selected) {
				var v = op.value;
				if (!v) // extra pain for IE...
                	v = (op.attributes && op.attributes['value'] && !(op.attributes['value'].specified)) ? op.text : op.value;
                if (one) return v;
                a.push(v);
            }
        }
        return a;
    }
    return el.value;
};
$.fn.clearForm = function() {
    return this.each(function() {
        $('input,select,textarea', this).clearFields();
    });
};
$.fn.clearFields = $.fn.clearInputs = function() {
    return this.each(function() {
        var t = this.type, tag = this.tagName.toLowerCase();
        if (t == 'text' || t == 'password' || tag == 'textarea')
            this.value = '';
        else if (t == 'checkbox' || t == 'radio')
            this.checked = false;
        else if (tag == 'select')
            this.selectedIndex = -1;
    });
};
$.fn.resetForm = function() {
    return this.each(function() {
        if (typeof this.reset == 'function' || (typeof this.reset == 'object' && !this.reset.nodeType))
            this.reset();
    });
};
$.fn.enable = function(b) { 
    if (b == undefined) b = true;
    return this.each(function() { 
        this.disabled = !b 
    });
};
$.fn.selected = function(select) {
    if (select == undefined) select = true;
    return this.each(function() { 
        var t = this.type;
        if (t == 'checkbox' || t == 'radio')
            this.checked = select;
        else if (this.tagName.toLowerCase() == 'option') {
            var $sel = $(this).parent('select');
            if (select && $sel[0] && $sel[0].type == 'select-one') {
                $sel.find('option').selected(false);
            }
            this.selected = select;
        }
    });
};
function log() {
    if ($.fn.ajaxSubmit.debug && window.console && window.console.log)
        window.console.log('[jquery.form] ' + Array.prototype.join.call(arguments,''));
};
})(jQuery);


