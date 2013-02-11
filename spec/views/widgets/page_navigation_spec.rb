require 'spec_helper'

describe "page_navigation" do

  let(:project){ nil }
  let(:projects){ [] }
  let(:user){ nil }

  def locals
    {
      user: user,
      project: project,
      multify_link_url: 'http://www.fark.com/',
    }
  end

  describe "the brand link" do
    subject{ html.css('a.brand').first[:href] }
    it { should == locals[:multify_link_url] }
  end

  context "when given a user" do
    let(:user){ double(:user, name: 'Jared', projects: projects) }

    context "and that user has projects projects" do
      let(:projects){
        4.times.map do |i|
          double(:"project #{i}",
            persisted?: true,
            name: "PROJECT #{i}",
            to_param: i,
          )
        end
      }

      it "should list all the projects" do
        project_links = html.css('.dropdown ul.projects > li')
        project_links.zip(projects).each do |project_link, project|
          project_link.css('a').first[:href].should == view.project_conversations_url(project)
        end
      end

      describe "the projects dropdown" do
        subject{ html.css('.dropdown a.projects').first.text }
        it { should =~ /\s*Projects\s*/ }
        context "when given a project" do
          let(:project){ projects[1] }
          it { should =~ /\s*PROJECT 1\s*/ }
        end
      end

    end

  end

  context "when not given a user" do
    let(:user){ nil }
    it "should just have a login link" do
      link = html.css('ul.nav.pull-right > li > a').first
      link[:href].should == view.new_user_session_url
      link.text .should == 'Login'
    end
  end

end
