describe("Threadable.Flash", function(){

  var flash, node;

  beforeEach(function(){
    node = $('<div>');
    flash = new Threadable.Flash(node);
  });

  describe("#create", function() {

    it("should return a flash alert html object", function(){
      var alert = flash.create('message', '<span>hello world</span>');
      expect(alert.attr('class')).toEqual('alert message alert-success');
      expect(alert.find('strong').text()).toEqual('Hey!');
      expect(alert.find('span').text()).toEqual('hello world');
      expect(alert.find('button').length).toEqual(1);
      expect(node.html()).toEqual('');
    });

  });

  describe("#empty", function() {

    it("should empty the node", function(){
      flash.append('<strong>box</strong>');
      expect(node.html()).toEqual('<strong>box</strong>');
      flash.empty();
      expect(node.html()).toEqual('');
    });

  });

  describe("#append", function() {

    it("should append the given thing into the node", function(){
      flash.append('<strong>box</strong>');
      expect(node.html()).toEqual('<strong>box</strong>');
      flash.append('<p>boyakasha</p>');
      expect(node.html()).toEqual('<strong>box</strong><p>boyakasha</p>');
    });

  });

  describe("#message", function() {

    it("should create and append a flash from text", function(){
      flash.message('this is text <not> html');
      var expected_html = '<div class="alert message alert-success">  <button type="button" class="close" data-dismiss="alert">×</button>  <strong>Hey!</strong> <span>this is text &lt;not&gt; html</span></div>';
      expect(node.html()).toEqual(expected_html);
    });

  });

});
