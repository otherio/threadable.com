//= require jasmine
//= require jasmine-html
//= require jasmine-jsreporter
//= require mock-ajax
//= require jasmine-jquery

context = describe;

beforeEach(function(){
  form_submissions = [];
  localStorage.clear();
  jasmine.Ajax.useMock();
  $('.page').replaceWith( $('<div>').addClass('page') );
});

afterEach(function(){
  $('.page').hide();
});

function lastFormSubmission() {
  return form_submissions[form_submissions.length-1];
}

$(window).load(function() {

  $('.page').css({'position':'relative'});

  form_submissions = [];
  $(document).on('submit', 'form', function(event){
    if (event.isDefaultPrevented()) return;
    form_submissions.push({form: this, event: event});
    event.preventDefault();
  });

  setTimeout(function(){
    if (!window.jasmine) throw new Error('jasmine failed to load');
    if (!window.Covered) throw new Error('Covered failed to load');

    var jasmineEnv = jasmine.getEnv();
    jasmineEnv.updateInterval = 1000;

    jasmineEnv.htmlReporter = new jasmine.HtmlReporter();
    jasmineEnv.jsReporter = new jasmine.JSReporter();

    jasmineEnv.addReporter(jasmineEnv.htmlReporter);
    jasmineEnv.addReporter(jasmineEnv.jsReporter);
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
  $('.page').html(fixture);
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


