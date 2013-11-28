require 'spec_helper'

describe ConversationsController do

  before{ sign_in! find_user_by_email_address('bob@ucsd.covered.io') }

  let(:project){ current_user.projects.find_by_slug! 'raceteam' }
  let(:conversation) { project.conversations.oldest }


  def valid_attributes
    {
      "subject" => "how are we going to build this thing?",
      "creator" => current_user,
    }
  end

  def valid_params
    {project_id: project.to_param}
  end

  def xhr_valid_params
    valid_params.merge({format: 'json'})
  end

  def expected_conversation
    project.conversations.find_by_subject(valid_attributes["subject"])
  end

  describe "GET index" do
    it "assigns all conversations as @conversations" do
      get :index, valid_params
      assigns(:conversations).should eq(project.conversations.all)
      assigns(:tasks).should eq(project.tasks.all)
    end
  end

  describe "GET new" do
    it "assigns a new conversation as @conversation" do
      get :new, valid_params
      assigns(:conversation).should be_a Covered::Project::Conversation
      assigns(:conversation).should_not be_persisted
    end
  end

  describe "GET show" do
    it "assigns the requested conversation as @conversation" do
      get :show, valid_params.merge(:id => conversation.to_param)
      assigns(:conversation).should eq(conversation)
    end
  end

  describe "POST create" do

    context "when given invalid params" do
      it "should raise an error" do
        expect{ post :create, {project_id: project.to_param} }.to raise_error(ActionController::ParameterMissing)
      end
    end

    context "when given valid params" do
      let(:subject){ 'we need more wood' }
      let(:body   ){ 'hey guys are are going to need like 10x more wood. '}
      let(:attachments){
        [
          {
            url:       "https://www.filepicker.io/api/file/JCYexCRERtybKeRozhAC",
            filename:  "some.gif",
            mimetype:  "image/gif",
            size:      "376649",
            writeable: "true",
          }, {
            url:        "https://www.filepicker.io/api/file/JCYexCRERtybKeRozhAC",
            filename:   "some.jpg",
            mimetype:   "image/jpeg",
            size:       "376649",
            writeable:  "true",
          },
        ]
      }
      def params
        {
          format: format,
          project_id: project.to_param,
          message: {
            subject: subject,
            body: body,
            attachments: attachments,
          }
        }
      end

      before do
        expect_any_instance_of(Covered::Project::Conversations).to receive(:create).
          with(subject: subject).
          and_return(conversation)

        if conversation.persisted?
          messages_double = double(:messages)
          expect(conversation).to receive(:messages).and_return(messages_double)
          expect(messages_double).to receive(:create).with(html: body, attachments: attachments).and_return(message)
        end
      end

      let(:message){ double(:message, persisted?: true) }


      context "when the format is html" do
        let(:format){ :html }
        context "and the conversation saves successfully" do
          let(:conversation){ double(:conversation, to_param: 'we-need-more-wood', persisted?: true) }

          it "should redirect to the project conversation url with a successfull flash notice" do
            post :create, params
            expect(response).to redirect_to project_conversation_url(project, conversation)
            expect(flash[:notice]).to eq 'Conversation was successfully created.'
          end

          context "but the message doesnt save successfully" do
            let(:message){ double(:message, persisted?: false) }
            it "should render the new action" do
              post :create, params
              expect(response).to render_template :new
            end
          end
        end

        context "but the conversation doesnt save successfully" do
          let(:conversation){ double(:conversation, to_param: 'we-need-more-wood', persisted?: false) }
          it "should render the new action" do
            post :create, params
            expect(response).to render_template :new
          end
        end
      end

      context "when the format is json" do
        let(:format){ :json }
        context "and the conversation saves successfully" do
          let(:conversation){ double(:conversation, to_param: 'we-need-more-wood', persisted?: true) }

          it "should redirect to the project conversation url with a successfull flash notice" do
            post :create, params
            expect(response.status).to eq 201
            expect(response.body).to eq conversation.to_json
            expect(response.location).to eq project_conversation_url(project, conversation)
          end

          context "but the message doesnt save successfully" do
            let(:errors){ {message_errors: 942} }
            let(:message){ double(:message, persisted?: false, errors: errors) }
            it "should render the message errors" do
              post :create, params
              expect(response.status).to eq 422
              expect(response.body).to eq errors.to_json
            end
          end
        end

        context "but the conversation doesnt save successfully" do
          let(:errors){ {conversation_errors: 942} }
          let(:conversation){ double(:conversation, to_param: 'we-need-more-wood', persisted?: false, errors: errors) }
          it "should render the conversation errors" do
            post :create, params
            expect(response.status).to eq 422
            expect(response.body).to eq errors.to_json
          end
        end
      end

    end

  end


  describe "PUT update" do
    # let!(:conversation){ Conversation.create!(valid_attributes.merge(project:project, creator: current_user)) }

    def valid_update_params
      {
        "subject" => valid_attributes["subject"],
      }
    end

    describe "with valid params" do
      it "updates the requested conversation" do
        now = Time.now
        Time.stub(:now).and_return(now)
        Conversation.any_instance.should_receive(:update_attributes).with({
          "subject" => "How aren't we going to build this thing?",
          "done_at" => Time.now,
        })
        put :update, valid_params.merge(:id => conversation.to_param, :conversation => {
          "subject" => "How aren't we going to build this thing?",
          "done" => "true",
        })
      end

      it "assigns the requested conversation as @conversation" do
        put :update, valid_params.merge(:id => conversation.to_param, :conversation => valid_update_params)
        assigns(:conversation).should eq(conversation)
      end

      it "redirects to the conversation" do
        put :update, valid_params.merge(:id => conversation.to_param, :conversation => valid_update_params)
        response.should redirect_to project_conversation_url(project, conversation)
      end
    end

    describe "with invalid params" do
      def invalid_params
        {
          id: conversation.to_param,
          conversation: {
            subject: ""
          }
        }
      end

      it "assigns the conversation as @conversation" do
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        put :update, valid_params.update(invalid_params)
        assigns(:conversation).should eq(conversation)
      end

      it "redirect to the project conversation page" do
        # Trigger the behavior that occurs when invalid params are submitted
        Conversation.any_instance.stub(:save).and_return(false)
        put :update, valid_params.update(invalid_params)
        response.should redirect_to project_conversation_url(project, conversation)
      end
    end
  end

end
