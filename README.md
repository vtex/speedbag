# Speedbag

A grunt coffee/less/live-reload/cssmin/uglify/connect/bootstrap/zepto/lodash boilerplate.

Check out the [live demo](http://vtex.github.io/speedbag)

Requires [node](http://nodejs.org/), [grunt](http://gruntjs.com/), bower and bower-installer (`npm i -g grunt-cli bower bower-installer`).

### Speedstart

    npm i
    bower-installer
    grunt

Have fun! Changes to your coffee, less or html files will reload the page automatically. Nice.

The compiled files can be found in the `/build` folder.

### Testing

    grunt test

### Distributable build (minifies, etc.)

    grunt dist

### Folder structure

- `src` - most of your files will be here.
	- `coffee` - CoffeeScript source files
	- `style` - CSS and LESS source files
	- `lib` - Third-party libs
	- `index.html` - Your app entry point.
- `spec` - Unit tests source files.
- `Gruntfile.coffee` - This is the configuration file for grunt. Contains all the build tasks.
- `remote.json` - The configuration file for [Remote](https://github.com/gadr90/remote), if you need it.
- `build` - this folder will be created after you run a grunt task.
	- `index.debug.html` - this is the same index as generated on the dev task. Useful for debugging in production.
- `build-raw` - this folder contains your built app before any string-replacements.

------

### Common issues:

**EADDRINUSE** - Someone is already using one of the ports used by this app, either [connect](https://github.com/gruntjs/grunt-contrib-connect)'s 9001 or [LiveReload](https://github.com/gruntjs/grunt-contrib-livereload)'s 35729.
Shut down interfering services or change the ports on Gruntfile.coffee.

------

VTEX - 2013
