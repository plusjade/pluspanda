var Testimonial = Backbone.Model.extend({
    url : function() {
        return '/v1/testimonials/' + this.id + '?apikey=' + this.collection.user.get('apikey');
    }
})

var Testimonials = Backbone.Collection.extend({
    model : Testimonial
    ,
    filters : ['new', 'published', 'hidden', 'trash']
    ,
    initialize : function(args) {
        this.user = args.user;
    }
    ,
    loadTestimonials : function(filter, page) {
        filter = filter.toLowerCase();
        if($.inArray(filter, this.filters) === -1) return false;
        this.filterName = filter;
        var self = this;
        return  $.ajax({
                    dataType: "JSON",
                    url : this.user.url() + '/testimonials.json',
                    data : { filter: filter, page: page || 1 },
                })
                .done(function(data) {
                    self.next_page = data.next_page;
                    self.reset(data.testimonials);
                })
    }
    ,
    loadNext : function(filter, page) {
        filter = filter.toLowerCase();
        var self = this;
        return  $.ajax({
                    dataType: "JSON",
                    url : this.user.url() + '/testimonials.json',
                    data : { filter: filter, page: page },
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
                    type : "PUT",
                    url : this.user.url() + '/testimonials/save_positions',
                    data : order,
                })
    },

    selectedCount: function() {
        return this.where({ selected : true }).length;
    }
    ,
    // action (string) : what action to carry out.
    batchUpdate : function(action) {
        action = action.toLowerCase();
        var selected = this.where({ selected : true }),
            ids = _.pluck(selected, "id"),
            self = this;
        return  $.ajax({
                    dataType: "JSON",
                    type: "PUT",
                    url : this.user.url() + '/testimonials',
                    data : { 'do': action, 'ids': ids },
                })
                .done(function() {
                    _.each(selected, function(model) {
                        if(action === "lock")
                            model.set('lock', true, {silent: true})
                        else if(action === 'unlock')
                            model.set('lock', false, {silent: true})
                        else if(action === 'publish')
                            model.set('publish', true, {silent: true})
                        else if(action === 'hide')
                            model.set('publish', false, {silent: true})
                        else if(action === 'trash')
                            model.set('trash', true, {silent: true})
                        else if(action === 'unlock')
                            model.set('trash', false, {silent: true})
                    })
                    self.trigger("reset");
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

App.ManageView = Backbone.View.extend({
    initialize : function(args) {
        var testimonials = new Testimonials({ user: args.user });
        var props = {
            user: args.user,
            testimonials: testimonials
        }

        ReactDOM.render(React.createElement(Manage, props), document.getElementById("manage-pane"));
    }
});
