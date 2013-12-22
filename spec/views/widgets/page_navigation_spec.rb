require 'spec_helper'

describe "page_navigation" do

  let(:current_organization){ nil }
  let(:organizations){ [] }
  let(:current_user){ nil }

  def locals
    {
      current_user: current_user,
      current_organization: current_organization,
      organizations: organizations,
      covered_link_url: 'http://www.fark.com/',
    }
  end

  before do
    view.stub(:signup_enabled?).and_return(true)
  end

  describe "the brand link" do
    subject{ html.css('a.brand').first[:href] }
    it { should == locals[:covered_link_url] }
  end

  context "when given a current_user" do
    let(:current_user){ double(:current_user, name: 'Jared', organizations: organizations, admin?: false) }

    context "and the current_user is an admin" do
      let(:current_user){ double(:current_user, name: 'Jared', organizations: organizations, admin?: true) }
      it "should have an admin link" do
        expect( html.css(%(a[href="#{admin_path}"])) ).to be_present
      end
    end

    context "and the current_user is not an admin" do
      let(:current_user){ double(:current_user, name: 'Jared', organizations: organizations, admin?: false) }
      it "should have an admin link" do
        expect( html.css(%(a[href="#{admin_path}"])) ).to_not be_present
      end
    end

    context "and that current_user has organizations" do
      let(:organizations){
        4.times.map do |i|
          double(:"organization #{i}",
            persisted?: true,
            name: "ORGANIZATION #{i}",
            to_param: i,
          )
        end
      }

      describe "the organizations dropdown menu" do
        it "should list all the organizations" do
          organization_links = html.css('.organizations .dropdown-menu > li > a').map do |link|
            [link.text, link[:href]]
          end

          expected_organization_links = organizations.map do |organization|
            [organization.name, view.organization_conversations_path(organization)]
          end

          expected_organization_links << ["All Organizations", root_path]

          organization_links.should == expected_organization_links
        end

        describe "text" do
          subject{ html.css('.organizations .dropdown-toggle').first.text }
          it { should =~ /\s*Organizations\s*/ }
        end
      end

    end

  end

  context "when not given a current_user" do
    let(:current_user){ nil }
    it "should just have a sign in link" do
      link = html.css('ul.nav.pull-right > li > a').first
      link[:href].should == view.sign_in_path
      link.text .should == 'Sign in'
    end
  end

end
