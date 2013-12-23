describeWidget("conversation_list", function(){

  it("allows you to toggle muted and not muted conversations", function(){
    var     muted_conversations = this.widget.$('.conversations.muted');
    var not_muted_conversations = this.widget.$('.conversations.not_muted');

    var     muted_button = this.widget.$('.mute-controls .muted_conversations');
    var not_muted_button = this.widget.$('.mute-controls .not_muted_conversations');

    expect( not_muted_conversations.is(':visible') ).toBe(true );
    expect(     muted_conversations.is(':visible') ).toBe(false);

    muted_button.click();

    expect( not_muted_conversations.is(':visible') ).toBe(false);
    expect(     muted_conversations.is(':visible') ).toBe(true );

    not_muted_button.click();

    expect( not_muted_conversations.is(':visible') ).toBe(true );
    expect(     muted_conversations.is(':visible') ).toBe(false);
  });

});
