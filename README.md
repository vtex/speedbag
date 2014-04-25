# Speedbag 2.0

A grunt coffee/less/live-reload/cssmin/uglify/connect/angular/bootstrap/jquery/underscore boilerplate.

Check out the [live demo](http://vtex.github.io/speedbag)

Requires [node](http://nodejs.org/) and [grunt](http://gruntjs.com/).

### Speedstart

    npm i -g grunt-cli # dependencies

    cd speedbag
    npm i
    grunt

Have fun! Changes to your coffee, less or html files will reload the page automatically. Nice.

The compiled files can be found in the `/build` folder.

### Distributable build (minifies, etc.)

    grunt dist

The deploy-ready files can be found in the `/deploy` folder.

### Folder structure

- `src` - most of your files will be here.
	- `coffee` - CoffeeScript source files
	- `style` - CSS and LESS source files
	- `index.html` - Your app entry point.
- `Gruntfile.coffee` - This is the configuration file for grunt. Contains all the build tasks.
- `build` - this folder will be created after you run a grunt task.

#### Checking dependencies

https://david-dm.org/vtex/speedbag#info=devDependencies&view=table

------

### Common issues:

**EADDRINUSE** - Someone is already using one of the ports used by this app, either [connect](https://github.com/gruntjs/grunt-contrib-connect)'s 9001 or [LiveReload](https://github.com/gruntjs/grunt-contrib-livereload)'s 35729.
Shut down interfering services or change the ports on Gruntfile.coffee.

------

VTEX - 2014
