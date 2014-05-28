# Speedbag 3

A grunt coffee/less/live-reload/cssmin/uglify/connect/angular/bootstrap/jquery/underscore boilerplate.

Requires [node](http://nodejs.org/) and [grunt](http://gruntjs.com/).

### Quickstart

    npm i -g grunt-cli releasy

    cd speedbag
    npm i
    grunt

Have fun! Changes to your coffee, less or html files will reload the page automatically. Nice.

The compiled files can be found in the `/build` folder.

### Distributable build (minifies, etc.)

    grunt dist

The deploy-ready files can be found in the `/deploy` folder.

### Deploying

    releasy

[TeamCity](http://pachamama.vtexlab.com.br) should pick up your new tag and start a deploy.
(For details, see [Releasy](https://github.com/vtex/releasy))

### Folder structure

- `src` - most of your files will be here.
	- `script` - CoffeeScript and JS source files
	- `style` - CSS and LESS source files
	- `templates` - Knockout JS style templates examples
	- `views` and `partials` - Angular templates examples
	- `i18n` - Translations for usage with ng-translate
	- `index.html` - Your app entry point.
- `Gruntfile.coffee` - This is the configuration file for grunt. Contains all the build tasks.
- `build` - this folder will be created after you run a grunt task.

### Grunt VTEX

The Speedbag Gruntfile is actually quite empty.  
This is because all tasks are defined in the meta-project [grunt-vtex](https://github.com/vtex/grunt-vtex).  
If you want to contribute an improvement to a task, please do so on that repo.  
Your Gruntfile should only contain customizations that are very specific to your project.


#### Checking dependencies

https://david-dm.org/vtex/speedbag#info=devDependencies&view=table

------

### Common issues:

**EADDRINUSE** - Someone is already using one of the ports used by this app, either [connect](https://github.com/gruntjs/grunt-contrib-connect)'s 9001 or [LiveReload](https://github.com/gruntjs/grunt-contrib-livereload)'s 35729.
Shut down interfering services or change the ports on Gruntfile.coffee.

------

VTEX - 2014
