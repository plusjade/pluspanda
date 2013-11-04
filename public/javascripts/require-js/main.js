require.config({
  baseUrl : "/javascripts/require-js/",
  urlArgs: "bust=" + (new Date()).getTime(),
  shim: {
    underscore: {
      exports: '_'
    },
    backbone: {
      deps: ["underscore", "jquery"],
      exports: "Backbone"
    }
  },
  paths : {
    'jquery' : 'libs/jquery-1.8.3',
    'underscore': 'libs/underscore.1.5.2.min',
    'backbone': 'libs/backbone.1.1.0.min',
    'mustache' : 'libs/mustache-0.7.2',
  }  
});

require(['jquery', 'underscore', 'backbone', 'app'], function ($, _, Backbone, App) {
    App.start();
});
