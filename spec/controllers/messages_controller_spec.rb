require 'spec_helper'

describe MessagesController do

  before { sign_in! find_user_by_email_address('tom@ucsd.covered.io') }
  let(:project){ current_user.projects.find_by_slug! 'raceteam' }
  let(:conversation) { project.conversations.find_by_slug! 'layup-body-carbon' }

  let(:message){
    double(:message,
      persisted?: message_errors.blank?,
      errors: message_errors,
      as_json: {message:'as_json'},
      root?: true,
    )
  }

  def expect_message_to_be_rendered_as_json!
    expect(message).to receive(:as_json).and_return("message"=>"as_json")
    expect(controller).to receive(:render_widget).with(:message, message).and_return('<message>html</message>')
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
      expect_any_instance_of(Covered::Project::Conversation::Messages).to receive(:create).with(
        sent_via_web: true,
        body:        params[:message][:body],
        attachments: params[:message][:attachments],
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

    let(:message){ double(:message, errors: message_errors, persisted?: message_errors.blank?) }
    before do
      expect_any_instance_of(Covered::Project::Conversation::Messages).to receive(:find_by_id!).with('1').and_return(message)
      expect(message).to receive(:update).with(
        shareworthy: true,
        knowledge:   true,
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

  end

end
