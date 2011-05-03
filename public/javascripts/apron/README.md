# Apron

**Purpose**

Provide organization to javascript and css files.

**What it Does**

- create directory structure from which it automatically load files in a particular order.     
- Loads jquery engine locally when in development and a cdn when in production.    
- Bundles your javascript files when you are ready to deploy.

## Installation:

``rails generate apron:install``

Apron installs the following directory structure:
<pre>
|-- public/javascripts/apron/    
  |-- engines    
    |-- jquery.js    
  |-- vendor    
  |-- lib    
  |-- pages    
  |-- bundle    
</pre>

## Usage

### public/javascripts/apron/engines/

By default we use the jquery engine. All this means is the engine is loaded first.    
In development engine/jquery.js is served locally. In production this file is omitted and http://code.jquery.com/jquery-1.5.1.min.js is used.

### public/javascripts/apron/vendor/

3rd party libraries should go into the vendor directory.    
All files with a .js extension will load first and in alphabetical order within the bundle.

### public/javascripts/apron/lib/

Use this directory to include javascript libraries, objects etc.    
We shouldn't be initializing anything in the bundle.    
All files with .js extenstion will load in alphabetical order and after files in vendor.

### public/javascripts/apron/pages/*

Use this directory to include javascript initializer code and document.ready type stuff, event bindings, etc. javascripts here should be included via the controller.
    
Use ``ApplicationController#add_javascripts()``
    Example usage:
``  
    before_filter { |c| add_javascripts("pages/businesses") }
    #this will add "pages/businesses" to all rendered views in the controller
  
    #You can also add pages per method by including:
      add_javascripts("pages/businesses")
``
  
    Note they don't actually need to have anything to do with a "page" and you can name them whatever you want.

  /public/javascripts/pages/_global.js
 
This javascript actually gets appended to the bundle.
Use this for global document.ready type stuff. Stuff that is part of the template
or called in a variety of places.

### public/javascripts/apron/bundle/

This directory contains the bundled files created by the rails generator.    
To bundle your files for production run:

``
rails g apron:bundle_js
``

## Important Notes

Apron loads all files in development mode so changes are realtime.
In production mode apron loads:

``
public/javascripts/apron/bundle/all.js
``

Create this file by running 

``
rails g apron:bundle_js
``




  
  
