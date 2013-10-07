'use strict';
var util = require('util');
var path = require('path');
var yeoman = require('yeoman-generator');


var Generator = module.exports = function Generator(args, options) {
  yeoman.generators.Base.apply(this, arguments);
	this.argument('appname', { type: String, required: false });
  this.appname = this.appname || path.basename(process.cwd());

	if (typeof this.env.options.appPath === 'undefined') {
		try {
			this.env.options.appPath = require(path.join(process.cwd(), 'bower.json')).appPath;
		} catch (e) {}
		this.env.options.appPath = this.env.options.appPath || 'app';
	}

	this.appPath = this.env.options.appPath;

	this.on('end', function () {
    this.installDependencies({ skipInstall: options['skip-install'] });
  });

  this.pkg = JSON.parse(this.readFileAsString(path.join(__dirname, '../package.json')));
};

util.inherits(Generator, yeoman.generators.Base);

Generator.prototype.askFor = function askFor() {
  var cb = this.async();

	this.prompt([{
		type: 'confirm',
		name: 'bootstrap',
		message: 'Would you like to include Twitter Bootstrap?',
		default: true
	}, {
		type: 'confirm',
		name: 'jquery',
		message: 'Would you like to include jQuery?',
		default: true
	}, {
		type: 'confirm',
		name: 'utils',
		message: 'Would you like to include front.utils?',
		default: true
	}, {
		type: 'confirm',
		name: 'lodash',
		message: 'Would you like to include Lodash?',
		default: true
	}],	function (props) {
		this.bootstrap = props.bootstrap;
		this.jquery = props.jquery;
		this.utils = props.utils;
		this.lodash = props.lodash;

		cb();
	}.bind(this));
};

Generator.prototype.askForAngular = function askForAngular() {
	var cb = this.async();

	this.prompt([{
		type: 'confirm',
		name: 'angular',
		message: 'Would you like to include Angular?',
		default: true
	}, {
		type: 'checkbox',
		name: 'angularMocksAndScenario',
		message: 'Would you like Angular Scenario and/or Angular Mocks?',
		when: function (props) {
			return props.angular;
		},
		choices: [{
			value: 'angularMocks',
			name: 'angular-mocks',
			checked: true
		}, {
			value: 'angularScenario',
			name: 'angular-scenario',
			checked: true
		}]
	}], function (props) {
		this.angular = props.angular;

		var hasMod = function (mod) { return props.angularMocksAndScenario.indexOf(mod) !== -1; };
		this.angularMocks = hasMod('angularMocks');
		this.angularScenario = hasMod('angularScenario');

		cb();
	}.bind(this));
};

Generator.prototype.askForModules = function askForModules() {
	var cb = this.async();

	if (this.angular){
		var prompts = [{
			type: 'checkbox',
			name: 'modules',
			message: 'Which modules would you like to include?',
			choices: [{
				value: 'resourceModule',
				name: 'angular-resource.js',
				checked: true
			}, {
				value: 'cookiesModule',
				name: 'angular-cookies.js',
				checked: true
			}, {
				value: 'sanitizeModule',
				name: 'angular-sanitize.js',
				checked: true
			},{
				value: 'bootstrapBower',
				name: 'bootstrap-bower.js',
				checked: true
			}]
		}];
	}

	this.prompt(prompts, function (props) {
		var hasMod = function (mod) { return props.modules.indexOf(mod) !== -1; };
		this.resourceModule = hasMod('resourceModule');
		this.cookiesModule = hasMod('cookiesModule');
		this.sanitizeModule = hasMod('sanitizeModule');
		this.bootstrapBower = hasMod('bootstrapBower');

		cb();
	}.bind(this));
};

Generator.prototype.readIndex = function readIndex() {
	this.indexFile = this.engine(this.read('index.html'), this);
};

Generator.prototype.bootstrapIndex = function bootstrapJS() {

	this.indexFile = this.appendScripts(this.indexFile, 'scripts/plugins.js', [
		// Aqui eu tenho que settar todas as propriedade que vão entrar no index
		// com ifs para verificar as respostas do usuario
	]);
};

Generator.prototype.extraModules = function extraModules() {
	var modules = [];
	if (this.resourceModule) {
		modules.push('bower_components/angular-resource/angular-resource.js');
	}

	if (this.cookiesModule) {
		modules.push('bower_components/angular-cookies/angular-cookies.js');
	}

	if (this.sanitizeModule) {
		modules.push('bower_components/angular-sanitize/angular-sanitize.js');
	}

	if (this.bootstrapBower){
		modules.push('bower_components/bootstrap-bower/ui-bootstrap.min.js')
	}

	if (modules.length) {
		this.indexFile = this.appendScripts(this.indexFile, 'scripts/modules.js',
			modules);
	}
};

Generator.prototype.createIndexHtml = function createIndexHtml() {
	this.write(path.join(this.appPath, 'index.html'), this.indexFile);
};

Generator.prototype.packageFiles = function () {
	this.template('_bower.json', 'bower.json');
	this.template('_package.json', 'package.json');
	this.template('Gruntfile.js', 'Gruntfile.js');
	this.template('pachamama.config', 'pachamama.config');
};