//= require jasmine
//= require jasmine-html
//= require jasmine-jsreporter
//= require jasmine-console_reporter
//= require mock-ajax
//= require jasmine-jquery

context = describe;

beforeEach(function(){
  localStorage.clear();
  jasmine.Ajax.useMock();
  $('.page').replaceWith( $('<div>').addClass('page') );

  this.addMatchers({
    toBeAnInstanceOf: function(clazz) {
      return this.actual instanceof clazz;
    },
    toBeA: function(clazz) {
      return this.actual instanceof clazz;
    },
    toBeAn: function(clazz) {
      return this.actual instanceof clazz;
    }
  });
});

afterEach(function(){
  $('.modal-backdrop').remove();
  $('.page').hide();
});

// whenReady(function() {
$(window).load(function() {

  $('.page').css({'position':'relative'});

  setTimeout(function(){
    if (!window.jasmine) throw new Error('jasmine failed to load');
    if (!window.Covered) throw new Error('Covered failed to load');

    var jasmineEnv = jasmine.getEnv();
    jasmineEnv.updateInterval = 1000;

    jasmineEnv.htmlReporter    = new jasmine.HtmlReporter();
    jasmineEnv.jsReporter      = new jasmine.JSReporter();
    jasmineEnv.consoleReporter = new jasmine.ConsoleReporter();

    jasmineEnv.addReporter(jasmineEnv.htmlReporter);
    jasmineEnv.addReporter(jasmineEnv.jsReporter);
    jasmineEnv.addReporter(jasmineEnv.consoleReporter);
    // this is not the best.
    //jasmineEnv.addReporter(new jasmine.ConsoleReporter);

    jasmineEnv.specFilter = function(spec) {
      return jasmineEnv.htmlReporter.specFilter(spec);
    };

    jasmineEnv.execute();

  });

});

function loadFixture(name, env){
  var fixture = fixtures[name];
  if (!fixture) throw new Error('fixtures '+name+' not found.');
  $('.page').html(fixture).show();
  Covered.initialize(env || {});
  return Covered.page;
}

function describeWidget(widget_name, block){
  describe(widget_name+" widget: ", function(){

    beforeEach(function(){
      this.Widget = Rails.widget(widget_name);
      this.page   = loadFixture('widgets/'+widget_name);
      this.widget = this.page.node.find(this.Widget.selector).widget();
    });

    block.call(this);
  });
}


