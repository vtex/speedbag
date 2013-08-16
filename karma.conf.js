preprocessors = {
	"**/*.coffee": "coffee"
};

files = [
	JASMINE,
	JASMINE_ADAPTER,
	'build/js/people.js',
	'spec/**/*.coffee'
];
browsers = [
	'PhantomJS'
];