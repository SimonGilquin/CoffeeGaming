// Karma configuration
// Generated on Sat Aug 10 2013 14:22:27 GMT+0200 (Romance Daylight Time)

module.exports = function(config) {
  config.set({

    // base path, that will be used to resolve files and exclude
    basePath: '',


    // list of files / patterns to load in the browser
    files: [
        'lib/require.js',
        'tests/test-main.js',
        {pattern: 'lib/*.js', included: false},
        {pattern: 'js/*.js', included: false},
        {pattern: 'tests/helpers/*.js', included: false},
        {pattern: 'tests/**/*Spec.js', included: false}
    ],

    // list of files to exclude
    exclude: [
        'js/main.js'
    ],

    // frameworks to use
    frameworks: ['jasmine'],

    plugins: ['karma-jasmine', 'karma-osx-reporter'],


    // tests results reporter to use
    // possible values: 'dots', 'progress', 'junit', 'growl', 'coverage'
    reporters: ['progress', 'osx', 'coverage', 'growl'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // Start these browsers, currently available:
    // - Chrome
    // - ChromeCanary
    // - Firefox
    // - Opera
    // - Safari (only Mac)
    // - PhantomJS
    // - IE (only Windows)
    browsers: ['Chrome'],


    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,


    // Continuous Integration mode
    // if true, it capture browsers, run tests and exit
    singleRun: false
  });
};
