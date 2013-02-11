require 'spec_helper'

describe PageNavigationWidget do

  let(:user)  { double(:user) }
  let(:arguments)   { [] }

  def html_options
    {class: 'custom_class'}
  end

    describe "locals" do
    subject{ presenter.locals }
    it do
      should == {
        block: nil,
        presenter: presenter,
        user: nil,
        project: nil,
        multify_link_url: view.root_url,
      }
    end
    context "when given a user" do
      def html_options
        super.merge(user: user)
      end
      it do
        should == {
          block: nil,
          presenter: presenter,
          user: user,
          project: nil,
          multify_link_url: view.root_url,
        }
      end
      context "when given a project" do
        def html_options
          super.merge(project: project)
        end
        context "that is not persisted" do
          let(:project){ double(:project, persisted?: false) }
          it do
            should == {
              block: nil,
              presenter: presenter,
              user: user,
              project: project,
              multify_link_url: view.root_url,
            }
          end
        end
        context "that is persisted" do
          let(:project){ double(:project, persisted?: true) }
          it do
            should == {
              block: nil,
              presenter: presenter,
              user: user,
              project: project,
              multify_link_url: view.project_conversations_url(project),
            }
          end
        end
      end
    end
  end

  describe "html_options" do
    it "should return the expected hash" do
      subject.html_options.should == {
        class: "page_navigation custom_class",
      }
    end
  end

end
