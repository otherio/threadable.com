Rails.widget('new_conversation_message', function(Widget){

  Widget.initialize = function(page){
    page.on('click',        Widget.selector+' .attach-files', this.curry('attachFiles', true));
    page.on('click',        Widget.selector+' .attachment-preview .remove', removeAttachment);
    page.on('click',        Widget.selector+' .body_field textarea', this.curry('focus', true));
    page.on('ajax:before',  Widget.selector+' form', beforeSubmit);
    page.on('submit',       Widget.selector+' form', beforeSubmit);
    page.on('ajax:success', Widget.selector+' form', this.curry('reset'));
  };

  var ATTACHMENT_PREVIEW_TEMPLATE;

  this.initialize = function(){
    ATTACHMENT_PREVIEW_TEMPLATE = this.node.find('.hidden.attachment-preview').remove().removeClass('hidden');

    this.send_button = this.node.find('input.btn[type=submit]').attr('disabled', true);
    this.subject_input = this.node.find('.subject_field :input');
    this.message_body_textarea = this.node.find('textarea').trigger('keyup');

    this.subject_input.on('keyup change', onChange.bind(this));
    this.message_body_textarea.on('keyup change', onChange.bind(this));

    this.node.find('.recipients .avatar').tooltip();

    if (this.data.autoexpand){
      this.focus();
    }else{
      this.message_body_textarea.click(this.expand.bind(this));
    }
  };

  this.expand = function() {
    this.node.addClass('expanded');
    setupNewMessageInput.apply(this);
    return this;
  };

  this.focus = function(){
    this.expand();
    if (this.subject_input.length) this.subject_input.focus();
    return this;
  };

  this.reset = function(){
    this.reset();
    var form = $(this);

    form.find('.attachments').empty();
    $('ul.wysihtml5-toolbar').remove();
    $('iframe.wysihtml5-sandbox').off('onload').remove();
    form.find('textarea').css('height', '40px').show();
    form.find('input[type=submit]').attr('disabled', true);
  };

  this.getMessageBody = function(){
    return this.message_body ?
      this.message_body.editor.composer.getValue() :
      this.message_body_textarea.val();
  };

  this.setMessageBody = function(value) {
    if (this.message_body){
      this.message_body.editor.composer.setValue(value);
    }else{
      this.message_body_textarea.val(value);
    }
    this.message_body_textarea.change();
    return this;
  };

  this.attachFiles = function(){
    filepicker.pickAndStore({multiple:true}, {}, function(fpfiles){
      this.addFiles(fpfiles);
    }.bind(this));
  };

  this.addFiles = function(files){
    var nodes = $();
    files.forEach(function(file){
      var node = ATTACHMENT_PREVIEW_TEMPLATE.clone();
      var preview = node.find('.preview');
      node.data('data', file);
      node.attr('title', file.name);

      node.find('input.url'      ).val(file.url);
      node.find('input.filename' ).val(file.filename);
      node.find('input.mimetype' ).val(file.mimetype);
      node.find('input.size'     ).val(file.size);
      node.find('input.writeable').val(file.isWriteable);

      preview.attr('href', file.url);
      if (file.mimetype.indexOf("image") !== -1){
        var img = $('<img>');
        img.attr('src', file.url+'/convert?h=43&w=43&fit=crop');
        preview.html(img);
      }
      nodes = nodes.add(node);
    });
    this.node.find('form .attachments').append(nodes);
  };

  this.isValid = function() {
    if (this.subject_input.length === 0){
      return !!this.getMessageBody()
    }else{
      return !!this.getMessageBody() && !!this.subject_input.val();
    }
  };

  // private

  function setupNewMessageInput(){
    if (this.message_body) return;
    this.message_body_textarea.wysihtml5({'image': false});
    this.message_body = this.message_body_textarea.data('wysihtml5');
    this.message_body.editor.on("change", onChange.bind(this));
    detectChangeInEditor.apply(this);
  }

  function detectChangeInEditor() {
    // if we're no longer in the DOM stop.
    if (this.node.parents('html').length === 0) return;
    // copy content from the WYSIWYG editor to the textarea
    if (this.message_body.editor.synchronizer){
      this.message_body.editor.synchronizer.fromComposerToTextarea();
      // trigger a change event
      this.message_body_textarea.change();
    }
    setTimeout(detectChangeInEditor.bind(this), 500);
  }

  function onChange() {
    this.send_button.attr('disabled', !this.isValid());
  }

  function removeAttachment(event){
    event.preventDefault();
    $(this).closest('.attachment-preview').remove();
  }

  function beforeSubmit(event) {
    var widget = $(this).widget(Widget);
    if (!widget.isValid()){
      event.preventDefault();
      Covered.page.flash.notice('your message must contain a subject and a body');
    }
  }

});
