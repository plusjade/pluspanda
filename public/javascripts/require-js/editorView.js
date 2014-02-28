define([
    'jquery',
    'underscore',
    'backbone',
    'mustache',

    'previewView',

    'lib/showStatus'
], function($, _, Backbone, Mustache,
    PreviewView,
    ShowStatus) {

    var ThemeAttribute = Backbone.Model.extend({
        urlRoot: '/admin/theme_attribute'
        ,
        parse : function(data) {
            data['fetch-entropy'] = Date.now();
            return data;
        }
    })
    var ThemeAttributes = Backbone.Collection.extend({
        model : ThemeAttribute
    })

    var ThemeAttributeView = Backbone.View.extend({
        model : ThemeAttribute
        ,
        tagName : 'a'
        ,
        className : 'btn btn-primary'
        ,
        events : {
            'click' : 'select'
        }
        ,
        initialize : function() {
            this.model.on('change', this.setActive, this);
        }
        ,
        render : function() {
            return this.$el.html(this.model.id);
        }
        ,
        select : function() {
            this.model.fetch();
        }
        ,
        setActive : function() {
            this.$el.siblings('a').removeClass('active');
            this.$el.addClass('active');
        }
    })

    var ThemeAttributesView = Backbone.View.extend({
        el : '#layout-editor'
        ,
        events :  {
            'click .js-save' : 'save'
        }
        ,
        initialize : function(attrs) {
            this.previewView = attrs.previewView;
            var self = this,
                options = {
                mode: { name: "xml", htmlMode: true },
                theme: "ambiance",
                path: "/codemirror-3.1/",
                continuousScanning: 500,
                lineNumbers: true
            };
            this.editor = window.CodeMirror.fromTextArea(document.getElementById('code-editor'), options);
            this.editor.addKeyMap({
                'Cmd-S' : function(cm) {
                    self.save();
                }
            })

            this.collection
                .on('change:fetch-entropy', function(model) {
                    var mode = model.id.split('.')[1] == 'css' ? 'css' : 'xml';
                    this.editor.setOption("mode", mode);
                    this.editor.setValue(model.get('body'));
                    this.model = model;

                    var content = Mustache.render(
                            '<select><option>Available Tokens</option>{{# tokens }}<option>{{.}}</option>{{/ tokens }}</select>',
                            { tokens : model.get('tokens') }
                        );
                    $('#token-list').html(content);
                }, this)
                .on('sync', function() {
                    this.previewView.staging();
                }, this)
        }
        ,
        render : function() {
            var cache = [];
            this.collection.each(function(model) {
                cache.push(new ThemeAttributeView({ model: model }).render());
            })
            $.fn.append.apply(this.$el.find('.attribute-list'), cache);

            this.collection.at(0).fetch();
        }
        ,
        save : function() {
            if(this.model) {
                ShowStatus.submitting();
                this.model.set('body', this.editor.getValue());
                this.model.save().done(function() {
                    ShowStatus.respond({ msg :'Template Saved!', status: "good" });
                });
            }
        }
    })

    return Backbone.View.extend({
        initialize : function() {
            var attributes = new ThemeAttributes([
                { id: "wrapper.html" },
                { id: "testimonial.html" },
                { id: "style.css" }
            ]);

            new ThemeAttributesView({ 
                    collection: attributes,
                    previewView : new PreviewView()
                }).render();
        }
    })
})
