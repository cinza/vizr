# Packaging

## Key Files

* css/main.css
* css/test.css
* js/main.js
* js/spec.js
* js/test.js

## CSS

#### main.css

This file should import (or contain) all CSS that is used when your package is installed.

#### test.css

Use this to specify any additonal CSS for testing your component in isolation.  You might use this to emulate some styles from a typical viz / other package that you are installed in.

#### Notes

* Package CSS should be wrapped in some parent selector to minimize surprises
  * Easy to do with Stylus / SASS / LESS

## JavaScript

#### main.js

This file is the entry point for your package's functionality.  When client code (viz / other package) adds a dependency on your package name in a define statement:

    define(['cool-package'], function(coolPackage))

they'll get whatever object this file returns passed to them as `coolPackage`.

#### spec.js

Use this file to define options that your module requires.  In many cases this may be all or most of your packaage's external API.

#### test.js

Include any code here to exercise your package in isolation.  The sample package exposes the contents of `spec.js` as the variable `spec`, so you can use that to call your package.

#### Notes

* If you want to reference other JS files inside your package, use relative paths like `./utils`

## Build

    vizr build [--dev] .

## Other Tips

* Don't reference image paths in a template
  * Use relative background paths in a CSS file
