require 'spec_helper'

describe PageNavigationWidget do

  def html_options
    {class: 'custom_class'}
  end

  describe "locals" do

    subject{ presenter.locals }

    it do
      should == {
        block: nil,
        presenter: presenter,
        current_user: nil,
        current_project: nil,
        covered_link_url: view.root_url,
        projects: nil,
      }
    end

    context "when given a user" do

      let(:projects){
        projects = 8.times.map{|i| double("project#{i}", :persisted? => i%2==0) }
        double(:projects, all: projects)
      }
      let(:current_user){ double(:current_user, projects: projects) }

      def html_options
        super.merge(current_user: current_user)
      end

      it do
        should == {
          block: nil,
          presenter: presenter,
          current_user: current_user,
          current_project: nil,
          covered_link_url: view.root_url,
          projects: projects.all,
        }
      end

      context "when given a project" do

        let(:current_project){ projects.all.sample }

        def html_options
          super.merge(current_project: current_project)
        end

        it do
          should == {
            block: nil,
            presenter: presenter,
            current_user: current_user,
            current_project: current_project,
            covered_link_url: view.project_conversations_url(current_project),
            projects: projects.all,
          }
        end

      end

    end

  end

  describe "html_options" do
    it "should return the expected hash" do
      subject.html_options.should == {
        class: "page_navigation custom_class",
        widget: "page_navigation",
      }
    end
  end

end
