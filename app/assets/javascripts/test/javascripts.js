// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require application
//= require jasmine
//= require jasmine-html
//= require jasmine-jsreporter
//= require jasmine.console_reporter
//= require mock-ajax

context = describe;

afterEach(function(){
  $('#body').html('');
})

$(window).load(function() {
  var jasmineEnv = jasmine.getEnv();
  jasmineEnv.updateInterval = 1000;

  var htmlReporter = new jasmine.HtmlReporter();

  jasmineEnv.addReporter(htmlReporter);
  jasmineEnv.addReporter(new jasmine.JSReporter);
  // this is not the best.
  //jasmineEnv.addReporter(new jasmine.ConsoleReporter);

  jasmineEnv.specFilter = function(spec) {
    return htmlReporter.specFilter(spec);
  };

  var finishCallback = jasmine.getEnv().currentRunner().finishCallback;
  jasmine.getEnv().currentRunner().finishCallback = function(){
    finishCallback.apply(this, arguments);
    jasmine.results = jasmine.getJSReport();
  }

  jasmineEnv.execute();

});

function loadFixture(name){
  var fixture = fixtures[name];
  $('#body').html(fixture);
}
