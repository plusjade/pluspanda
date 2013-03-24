require.config({
  baseUrl : "/javascripts/require-js/",
  urlArgs: "bust=" + (new Date()).getTime(),
  paths : {
    'jquery' : 'libs/jquery-1.8.3',
    'underscore': 'libs/underscore-1.3.1-amd', // AMD support
    'backbone': 'libs/backbone-0.9.1-amd', // AMD support
    'mustache' : 'libs/mustache-0.7.2',
  }  
});

require(['app'], function(App){
  App.start();
});