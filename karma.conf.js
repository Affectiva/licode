// Karma configuration
// Generated on Fri Oct 16 2015 15:36:24 GMT-0400 (EDT)

module.exports = function(config) {
  var configuration = {

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],

    // list of files / patterns to load in the browser
    files: [

    // source files
    'erizo_controller/erizoClient/dist/erizo.js',
    'licode_config.js',
    
    // test files
    {pattern: 'test/*test.js'}
    ],


    // list of files to exclude
    exclude: [
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
    },


    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['spec'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_DEBUG,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome_with_fake_media'],

    customLaunchers: {
      Chrome_with_fake_media: {
        base: 'Chrome',
        flags: ['--use-fake-ui-for-media-stream', '--use-fake-device-for-media-stream', '--allow-file-access']
      },
      Chrome_travis_ci: {
        base: 'Chrome',
        flags: ['--use-fake-ui-for-media-stream', '--use-fake-device-for-media-stream', '--no-sandbox']
      }
    },
    // If browser does not capture in given timeout [ms], kill it
    captureTimeout: 60000,
    // needed for recording test
    browserNoActivityTimeout: 100000,
    
    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: true
  };

  // Travis CI uses chromium which requires the --no-sandbox flag
  if (process.env.TRAVIS){
    configuration.browsers = ['Chrome_travis_ci'];
  }
  config.set(configuration);
}
