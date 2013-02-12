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
      multify_link_url: 'http://www.fark.com/',
    }
  end

  describe "the brand link" do
    subject{ html.css('a.brand').first[:href] }
    it { should == locals[:multify_link_url] }
  end

  context "when given a current_user" do
    let(:current_user){ double(:current_user, name: 'Jared', projects: projects) }

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
            [project.name, view.project_conversations_url(project)]
          end

          project_links.should == expected_project_links
        end

        describe "text" do
          subject{ html.css('.projects button').first.text }
          it { should =~ /\s*Projects\s*/ }
        end
      end

    end

  end

  context "when not given a current_user" do
    let(:current_user){ nil }
    it "should just have a login link" do
      link = html.css('ul.nav.pull-right > li > a').first
      link[:href].should == view.new_user_session_url
      link.text .should == 'Login'
    end
  end

end
