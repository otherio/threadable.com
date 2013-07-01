//= require jasmine
//= require jasmine-html
//= require jasmine-jsreporter
//= require mock-ajax
//= require jasmine-jquery

context = describe;

beforeEach(function(){
  localStorage.clear();
  jasmine.Ajax.useMock();
  $('.page').replaceWith( $('<div>').addClass('page') );
});

afterEach(function(){
  $('.page').hide();
});

$(window).load(function() {

  $('.page').css({'position':'relative'});

  setTimeout(function(){
    Covered // raise error if it's not loaded

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

});

function loadFixture(name, env){
  var fixture = fixtures[name];
  if (!fixture) throw new Error('fixtures '+name+' not found.');
  $('.page').html(fixture);
  Covered.initialize(env || {});
  return Covered.page;
}

function describeWidget(widget_name, block){
  describe(widget_name+" widget", function(){

    beforeEach(function(){
      this.Widget = Rails.widget(widget_name);
      this.page   = loadFixture('widgets/'+widget_name);
      this.widget = this.page.node.find(this.Widget.selector).widget();
    });

    block.call(this);
  });
}
