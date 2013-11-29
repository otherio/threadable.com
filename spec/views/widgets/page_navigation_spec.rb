require 'spec_helper'

describe "page_navigation" do

  let(:current_project){ nil }
  let(:projects){ [] }
  let(:current_user){ nil }

  def locals
    {
      current_user: current_user,
      current_project: current_project,
      projects: projects,
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
    let(:current_user){ double(:current_user, name: 'Jared', projects: projects, admin?: false) }

    context "and the current_user is an admin" do
      let(:current_user){ double(:current_user, name: 'Jared', projects: projects, admin?: true) }
      it "should have an admin link" do
        expect( html.css(%(a[href="#{admin_path}"])) ).to be_present
      end
    end

    context "and the current_user is not an admin" do
      let(:current_user){ double(:current_user, name: 'Jared', projects: projects, admin?: false) }
      it "should have an admin link" do
        expect( html.css(%(a[href="#{admin_path}"])) ).to_not be_present
      end
    end

    context "and that current_user has projects" do
      let(:projects){
        4.times.map do |i|
          double(:"project #{i}",
            persisted?: true,
            name: "PROJECT #{i}",
            to_param: i,
          )
        end
      }

      describe "the projects dropdown menu" do
        it "should list all the projects" do
          project_links = html.css('.projects .dropdown-menu > li > a').map do |link|
            [link.text, link[:href]]
          end

          expected_project_links = projects.map do |project|
            [project.name, view.project_conversations_path(project)]
          end

          expected_project_links << ["All Projects", root_path]

          project_links.should == expected_project_links
        end

        describe "text" do
          subject{ html.css('.projects .dropdown-toggle').first.text }
          it { should =~ /\s*Projects\s*/ }
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
