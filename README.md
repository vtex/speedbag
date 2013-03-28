# Speedbag

A grunt coffee/less/live-reload/cssmin/uglify/connect/bootstrap/zepto/lodash boilerplate.

Requires [node](http://nodejs.org/) and [grunt](http://gruntjs.com/) (`npm i -g grunt-cli`).

### Speedstart

    npm i
    grunt

Have fun! Changes to your coffee, less or html files will reload the page automatically. Nice.

The compiled files can be found in the `/build` folder.

### Production build

    grunt prod

### Folder structure

- `src` - most of your files will be here.
	- `coffee` - CoffeeScript source files
	- `style` - CSS and LESS source files
	- `lib` - Third-party libs
	- `includes` - Your css and js includes. They will be replaced into your index file. See note on includes below.
	- `index.html` - Your app entry point.
- `test` - Unit tests source files.
- `Gruntfile.json` - This is the configuration file for grunt. Contains all the build tasks.
- `remote.json` - The configuration file for [Remote](https://github.com/gadr90/remote), if you need it.
- `build` - this folder will be created after you run a grunt task.
	-	`index.debug.html` - this is the same index as generated on the dev task. Useful for debugging in production.

### Includes

The `includes` folder contains pieces of markup that will be included in your index.html on the `@@include<js|css>` tags.

This boilerplate includes a bit of custom functionality on the includes syntax when running a `prod` build.

You can specify two tags on each included file:

 - `data-min`, containing the label used by the minified version of this file.
 - `data-ignore`, which will remove this tag on prod builds.

So, for example, this:

			<script type="text/javascript" src="no-minified-version-available.js"></script>
			<script type="text/javascript" data-ignore src="js/ignore-on-prod.js"></script>
			<script type="text/javascript" data-min=".min" src="js/main.js"></script>

Will be rendered as:

			<script type="text/javascript" data-min=".min" src="no-minified-version-available.js"></script>
			<script type="text/javascript" data-min=".min" src="js/main.min.js"></script>

On the compiled index.html.


------

VTEX - 2013
