define([
    'jquery',
    'underscore',
    'mustache',
    'lib/showStatus',
    'app',
], function($, _, Mustache, ShowStatus, App) {
    var Testimonial = Backbone.Model.extend({
        urlRoot: '/v1/testimonials'
    })

    var Testimonials = Backbone.Collection.extend({
        model : Testimonial
        ,
        filters : ['new', 'published', 'hidden', 'trash']
        ,
        loadTestimonials : function(filter) {
            if($.inArray(filter, this.filters) === -1) return false;
            this.filterName = filter;
            var self = this;
            return  $.ajax({
                        dataType: "JSON",
                        url : '/admin/testimonials.json',
                        data : { filter: filter },
                    })
                    .done(function(data) {
                        self.next_page = data.next_page;
                        self.reset(data.testimonials);
                    })
        }
        ,
        loadNext : function() {
            var self = this;
            return  $.ajax({
                        dataType: "JSON",
                        url : '/admin/testimonials.json',
                        data : { filter: this.filterName, page: this.next_page },
                    })
                    .done(function(data) {
                        self.next_page = data.next_page;
                        self.add(data.testimonials);
                    })
        }
        ,
        savePositions : function(order) {
            return  $.ajax({
                        dataType: "JSON",
                        url : '/admin/testimonials/save_positions',
                        data : order,
                    })
        },

        // action (string) : what action to carry out.
        batchUpdate : function(action) {
            var selected = this.where({ selected : true }),
                ids = _.pluck(selected, "id");

            return  $.ajax({
                        dataType: "JSON",
                        url : '/admin/testimonials/update',
                        data : { 'do': action, 'id': ids },
                    })
                    .done(function() {
                        _.each(selected, function(model) {
                            if(action === "lock")
                                model.set('lock', true)
                            else if(action === 'unlock')
                                model.set('lock', false)
                            else if(action === 'publish')
                                model.set('publish', true)
                            else if(action === 'hide')
                                model.set('publish', false)
                            else if(action === 'trash')
                                model.set('trash', true)
                            else if(action === 'unlock')
                                model.set('trash', false)

                            // trigger sync manually =(
                            model.trigger('sync');
                        })
                    })
        }
    })

    var TestimonialView = Backbone.View.extend({
        tagName : 'tr'
        ,
        className :  'manage-testimonial'
        ,
        model : Testimonial
        ,
        template : $("#testimonial-manage-template").html()
        ,
        events : {
            'click .checkboxes input' : 'setSelected',
            'change select' : 'updateRating',
            'keyup input' : 'autoSave',
            'click .toggle-publish' : 'togglePublish',
            'click .toggle-lock' : 'toggleLock',
            'click .share-link' : 'shareLink'
        }
        ,
        initialize : function() {
            this.model.on('change:selected', this.toggleSelect, this);
            this.model.on('change:lock change:publish', this.render, this);

            this.autoSave = _.debounce(function(e) {
                var $input = $(e.currentTarget),
                    name = $input.prop('name')
                    value = $input.val();

                if(this.model.get(name) === value) return;

                ShowStatus.submitting();
                this.model.set(name, value)
                    .save()
                    .done(function() {
                        ShowStatus.respond({ msg :'Testimonial Saved', status: "good" });
                    })
                    .error(function(){
                        ShowStatus.respond({ msg :'There was an error! Please try again' });
                    })
            }, 900)
        }
        ,
        render : function() {
            this.$el
                .html(Mustache.render(this.template, this.model.attributes))
                .find('abbr.timeago').timeago();
            this.toggleSelect();
            this.$('select').val(this.model.get('rating'));

            return this.$el;
        }
        ,
        setSelected : function() {
            this.model.set('selected', this.$(".checkboxes input").is(':checked'))
        }
        ,
        toggleSelect : function() {
            this.$el.toggleClass('selected', !!this.model.get('selected'));
            this.$(".checkboxes input").attr('checked', !!this.model.get('selected'));
        }
        ,
        togglePublish : function(e) {
            e.preventDefault();
            this.model.save({ publish : !this.model.get('publish') })
                .done(function() {
                    ShowStatus.respond({ msg :'Testimonial Saved', status: "good" });
                })
                .error(function(){
                    ShowStatus.respond({ msg :'There was an error! Please try again' });
                })
        }
        ,
        toggleLock : function(e) {
            e.preventDefault();
            this.model.save({ lock : !this.model.get('lock') })
                .done(function() {
                    ShowStatus.respond({ msg :'Testimonial Saved', status: "good" });
                })
                .error(function(){
                    ShowStatus.respond({ msg :'There was an error! Please try again' });
                })
        }
        ,
        updateRating : function(e) {
            this.model.save({ rating : $(e.currentTarget).val() })
                .done(function() {
                    ShowStatus.respond({ msg :'Testimonial Saved', status: "good" });
                })
                .error(function(){
                    ShowStatus.respond({ msg :'There was an error! Please try again' });
                })
        }
        ,
        shareLink : function() {
            // TODO
        }
    })

    var TestimonialsView = Backbone.View.extend({
        el : '#js-testimonials-pager'
        ,
        events : {
            'click' : 'loadNext'
        }
        ,
        initialize : function() {
            this.$container = $('#t-data');
            this.collection.on('reset', this.render, this);
            this.collection.on('add', this.add, this);
            this.collection.on('reset add', this.toggle, this);

            this.collection.loadTestimonials("published");
        }
        ,
        toggle : function() {
            if(this.collection.next_page > 0) {
                this.$el.show();
            }
            else {
                this.$el.hide();
            }
        }
        ,
        loadNext : function(e) {
            e.preventDefault();
            this.collection.loadNext();
        }
        ,
        render : function() {
            this.$container.empty();
            if(this.collection.length > 0) {
                var cache = [];
                this.collection.each(function(model) {
                    cache.push(new TestimonialView({ model : model }).render());
                })
                $.fn.append.apply(this.$container, cache);
            }
            else {
                this.$container.html('<tr><td colspan="13"><h4>No results</h4></td></tr>');
            }
        }
        ,
        add : function(model) {
            this.$container.append( new TestimonialView({ model : model }).render() );
        }
    })

    var NewTestimonialView = Backbone.View.extend({
        el : '#new-testimonial-view'
        ,
        events : {
            'click a.js-cancel' : 'reset',
            'submit' : 'save'
        }
        ,
        render : function() {
            this.$el.show();
        }
        ,
        // Todo: Make this use the backbone model. Can't do it cuz it's namespaced =/
        // and I don't know how to easily update it.
        save : function(e) {
            e.preventDefault();
            var self = this,
                testimonial = new Testimonial(),
                params = this.$el.serializeArray(),
                data = {};
            _.each(params, function(param){ data[param.name] = param.value })

            $.ajax({
                type : "POST",
                dataType: "JSON",
                url : '/v1/testimonials',
                data : { testimonial : data },
            })
            .done(function() {
                ShowStatus.respond({ msg :'Testimonial Saved', status: "good" });
                self.reset();
                self.collection.loadTestimonials('new');
                delete testimonial;
            })
            .error(function(){
                ShowStatus.respond({ msg :'There was an error! Please try again' });
            })
        }
        ,
        reset : function(e) {
            if(e) e.preventDefault();
            this.$el.hide()[0].reset();
        }
    })

    var SelectedTestimonials = Backbone.View.extend({
        el : '.admin-new-testimonials-list'
        ,
        events : {
            'click a.select.all' : 'selectAll',
            'click a.select.none' : 'selectNone',
            'click a.do' : 'batchUpdate',
            'click a.save-positions' : 'savePositions',
        }
        ,
        selectAll : function(e) {
            e.preventDefault();
            this.collection.each(function(model) {
                model.set("selected", true);
            })
        }
        ,
        selectNone : function(e) {
            e.preventDefault();
            this.collection.each(function(model) {
                model.set("selected", false);
            })
        }
        ,
        batchUpdate : function(e) {
            e.preventDefault();
            var any = this.collection.findWhere({ selected : true })

            if (any) {
                var action = e.currentTarget.innerHTML.toLowerCase();
                var filter = $('.manage-testimonial-filters a.active').html().toLowerCase();

                ShowStatus.submitting();
                this.collection.batchUpdate(action)
                    .done(function(rsp) {
                        ShowStatus.respond(rsp);
                        mpmetrics.track(action);
                    })
                    .error(function() {
                        ShowStatus.respond({ msg :'There was an error! Please try again' });
                    })
            }
            else {
                ShowStatus.respond({ msg :'Nothing selected.' });
            }
        }
        ,
        savePositions : function(e) {
            e.preventDefault();
            var order = $("table.t-data").sortable("serialize");
            if (order) {
                ShowStatus.submitting();
                this.collection.savePositions(order)
                    .done(function(rsp){
                        ShowStatus.respond(rsp);
                        mpmetrics.track("savePositions");
                    })
                    .error(function() {
                        ShowStatus.respond({ msg :'There was an error! Please try again' });
                    })
            }
            else {
                ShowStatus.respond({"msg":'No items to sort'});
            }
        }
    })

    var Filters = Backbone.View.extend({
        el : '.manage-testimonial-filters'
        ,
        events : {
            'click a' : 'filter'
        }
        ,
        initialize : function() {
            this.collection.on('reset', this.render, this);
        }
        ,
        render : function() {
            this.$('a').removeClass('active');
            var $node = this.$('.js-' + this.collection.filterName).addClass('active');
            $(".data-description").html($node.prop('title'));
        }
        ,
        filter : function(e) {
            e.preventDefault();
            this.collection.loadTestimonials(e.currentTarget.innerHTML.toLowerCase());
        }
    });

    return Backbone.View.extend({
        initialize : function() {
            var testimonials = new Testimonials();

            new SelectedTestimonials({ collection: testimonials });
            new Filters({ collection: testimonials });
            new TestimonialsView({ collection : testimonials });
            var newTestimonial = new NewTestimonialView({ collection : testimonials });

            $("#new-testimonial-button").click(function(e) {
                e.preventDefault();
                newTestimonial.render();
            })
        }
    });
})
