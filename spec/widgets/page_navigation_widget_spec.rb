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
        current_organization: nil,
        covered_link_url: view.root_url,
        organizations: nil,
      }
    end

    context "when given a user" do

      let(:organizations){
        organizations = 8.times.map{|i| double("organization#{i}", :persisted? => i%2==0) }
        double(:organizations, all: organizations)
      }
      let(:current_user){ double(:current_user, organizations: organizations) }

      def html_options
        super.merge(current_user: current_user)
      end

      it do
        should == {
          block: nil,
          presenter: presenter,
          current_user: current_user,
          current_organization: nil,
          covered_link_url: view.root_url,
          organizations: organizations.all,
        }
      end

      context "when given a organization" do

        let(:current_organization){ organizations.all.sample }

        def html_options
          super.merge(current_organization: current_organization)
        end

        it do
          should == {
            block: nil,
            presenter: presenter,
            current_user: current_user,
            current_organization: current_organization,
            covered_link_url: view.organization_conversations_url(current_organization),
            organizations: organizations.all,
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
