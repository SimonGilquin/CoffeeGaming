tests = (file for own file of window.__karma__.files when /helpers\/.*\.js$/.test file)
tests.push file for own file of window.__karma__.files when /Spec\.js$/.test file

requirejs.config
  # Karma serves files from '/base'
  baseUrl: '/base/js'

#  paths:
#    'jquery': '../lib/jquery'
#    'underscore': '../lib/underscore'
#
#  shim:
#    'underscore':
#      exports: '_'

  # ask Require.js to load these files (all our tests)
  deps: tests

  # start test run, once Require.js is done
  callback: window.__karma__.start
