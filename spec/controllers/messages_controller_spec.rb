require 'spec_helper'

describe MessagesController do

  before { sign_in_as find_user("alice-neilson") }

  let(:message){
    double(:message,
      persisted?: message_errors.blank?,
      errors: message_errors,
      as_json: {message:'as_json'},
      root?: true,
    )
  }

  let(:fake_view_context){ double :view_context }

  def expect_message_to_be_rendered_as_json!
    expect(controller).to receive(:view_context).and_return(fake_view_context)
    expect(fake_view_context).to receive(:render_widget).with(:message, message).and_return('<message>html</message>')
  end

  def expect_message_not_to_be_rendered_as_json!
    expect(controller).to_not receive(:view_context)
  end

  describe "POST create" do

    def params
      {
        project_id:      'raceteam',
        conversation_id: 'layup-body-carbon',
        message: {
          body:  "<b>hello</b><span>there people</span>",
          attachments: [
            {
              url:       "https://www.filepicker.io/api/file/g88HcWEkSN68EwKKIBTm",
              filename:  "2013-06-14 13.05.02.jpg",
              mimetype:  "image/jpeg",
              size:      "1830234",
              writeable: true,
            }
          ],
          extra: "ignored param",
        }
      }
    end

    def request!
      expect(covered.messages).to receive(:create).with(
        project_slug:      'raceteam',
        conversation_slug: 'layup-body-carbon',
        message_attributes: {
          body:        params[:message][:body],
          attachments: params[:message][:attachments],
        }
      ).and_return(message)

      post :create, params
    end


    context "when the message creation is successful" do
      let(:message_errors){ {} }
      it "renderes the message as json" do
        expect_message_to_be_rendered_as_json!
        request!
        expect( response.status              ).to eq 201
        expect( response.body                ).to eq({"message"=>"as_json", "as_html"=>"<message>html</message>"}.to_json)
        expect( response.headers['Location'] ).to eq project_conversation_messages_path('raceteam','layup-body-carbon')
      end
    end

    context "when the message creation is unsuccessful" do
      let(:message_errors){ {:body_plain=>["can't be blank"], :conversation=>["can't be blank"]} }
      it "renderes status unprocessable_entity with errors" do
        expect_message_not_to_be_rendered_as_json!
        request!
        expect( response.status ).to eq 422
        expect( response.body ).to eq %({"body_plain":["can't be blank"],"conversation":["can't be blank"]})
      end
    end

  end

  describe "PUT update" do
    # let(:message) { FactoryGirl.create(:message, subject: nil, conversation: conversation) }
    # let(:message_params) { valid_attributes }

    def params
      {
        project_id:      'raceteam',
        conversation_id: 'layup-body-carbon',
        id:              1,
        message: {
          shareworthy: true,
          knowledge:   true,
          extra:       "ignored param",
        }
      }
    end

    before do
      expect(covered.messages).to receive(:update).with(
        id: '1',
        attributes: {
          shareworthy: true,
          knowledge:   true,
        }
      ).and_return(message)
    end

    def request!
      put :update, params
    end

    context "when the update is successful" do
      let(:message_errors){ {} }
      it "renderes the message as json" do
        expect_message_to_be_rendered_as_json!
        request!
        expect( response.status ).to eq 200
        expect( response.body   ).to eq({"message"=>"as_json", "as_html"=>"<message>html</message>"}.to_json)
      end
    end

    context "when the update is not successful" do
      let(:message_errors){ {:shareworthy=>["can't be blank"], :knowledge=>["can't be blank"]} }
      it "renderes status unprocessable_entity with errors" do
        expect_message_not_to_be_rendered_as_json!
        request!
        expect( response.status ).to eq 422
        expect( response.body   ).to eq %({"shareworthy":["can't be blank"],"knowledge":["can't be blank"]})
      end
    end

    # def request!
    #   xhr :put, :update, valid_params.merge(id: message.id, message: message_params)
    # end

    # context "setting shareworthy and knowledge" do
    #   let(:message_params) { {shareworthy: true, knowledge: true} }
    #   it "marks the message correctly" do
    #     request!
    #     assigns(:message).shareworthy.should == true
    #     assigns(:message).knowledge.should == true
    #   end
    # end

  end




  # def valid_attributes
  #   {
  #     "body" => "<b>hello</b><span>there people</span>",
  #     "attachments"=> [
  #       {
  #         "url"=>"https://www.filepicker.io/api/file/g88HcWEkSN68EwKKIBTm",
  #         "filename"=>"2013-06-14 13.05.02.jpg",
  #         "mimetype"=>"image/jpeg",
  #         "size"=> 1830234,
  #         "writeable"=>true,
  #       },{
  #         "url"=>"https://www.filepicker.io/api/file/SavvNKdkTI2fDlyNKbab",
  #         "filename"=>"4816514863_20dc8027c6_o.jpg",
  #         "mimetype"=>"image/jpeg",
  #         "size"=> 3733625,
  #         "writeable"=>true,
  #       }
  #     ]
  #   }
  # end

  # def valid_params
  #   {
  #     conversation_id: conversation.slug,
  #     project_id: project.slug
  #   }
  # end

  # describe "POST create" do

  #   def request!
  #     xhr :post, :create, valid_params.merge(message: valid_attributes)
  #   end

  #   it "creates a new Message" do
  #     expect{ request! }.to change(conversation.messages, :count).by(1)
  #     response.status.should == 201
  #     message = assigns(:message)
  #     expect(message.subject).to eq(conversation.subject)
  #     expect(message.parent_message).to be_nil
  #     expect(message.body_html).to      eq(valid_attributes["body"])
  #     expect(message.stripped_html).to  eq(valid_attributes["body"])
  #     expect(message.body_plain).to     eq("hellothere people")
  #     expect(message.stripped_plain).to eq("hellothere people")
  #     attachments = message.attachments.map do |attachment|
  #       attachment.attributes.slice(*%w{url filename mimetype size writeable})
  #     end
  #     expect(attachments).to eq(valid_attributes["attachments"])
  #   end

  #   context "with special characters in the message" do

  #     def valid_attributes
  #       super.merge("body" => '<b>foo &amp; bar</b>')
  #     end

  #     it "transforms entities for the text part" do
  #       request!
  #       message = assigns(:message)
  #       expect(message.body_html).to      eq(valid_attributes["body"])
  #       expect(message.stripped_html).to  eq(valid_attributes["body"])
  #       expect(message.body_plain).to     eq("foo & bar")
  #       expect(message.stripped_plain).to eq("foo & bar")
  #     end
  #   end

  #   context "with more than one message in the conversation" do
  #     let!(:first_message) { FactoryGirl.create(:message, conversation: conversation) }

  #     it "sets the parent message if present" do
  #       request!
  #       assigns(:message).parent_message.id.should == first_message.id
  #     end
  #   end

  #   context "sending emails" do
  #     before { SendConversationMessageWorker.any_instance.stub(:enqueue) }

  #     it "enqueues emails for members" do
  #       SendConversationMessageWorker.should_receive(:enqueue).at_least(:once)
  #       request!
  #     end
  #   end
  # end

  # describe "PUT update" do
  #   let(:message) { FactoryGirl.create(:message, subject: nil, conversation: conversation) }
  #   let(:message_params) { valid_attributes }

  #   def request!
  #     xhr :put, :update, valid_params.merge(id: message.id, message: message_params)
  #   end

  #   context "setting shareworthy and knowledge" do
  #     let(:message_params) { {shareworthy: true, knowledge: true} }
  #     it "marks the message correctly" do
  #       request!
  #       assigns(:message).shareworthy.should == true
  #       assigns(:message).knowledge.should == true
  #     end
  #   end

  # end
end
