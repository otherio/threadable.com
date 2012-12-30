define(function(require) {
  var
    Marionette   = require('marionette'),
    Index        = require('views/logged_in/Index'),
    User         = require('models/User'),
    Project      = require('models/Project'),
    ProjectsView = require('views/logged_in/index/Projects'),
    FeedView     = require('views/logged_in/index/Feed'),
    MainView     = require('views/logged_in/index/Main');

  describe("logged in index view", function(){
    var index, user;

    beforeEach(function() {
      user = new User;
      this.setCurrentUser(user);
      index = new Index;
    });

    it("should have three regions", function(){
      expect(index.regions).toEqual({
        projectsRegion: '.panels > .left .projects',
        feedRegion:     '.panels > .left .feed',
        mainRegion:     '.panels > .main',
      });
    });


    describe("#initialize", function() {
      it("should get the current user and their projects and feed", function() {
        expect(index.current_user).toBe(user);
        expect(index.projects).toBe(user.projects);
        expect(index.feed).toBe(user.feed);
      });
    });

    describe("#show", function() {
      var options;

      beforeEach(function() {
        options = {
          projectSlug: 'eat-a-taco'
        };
      });

      describe("when the projects are not loaded", function() {
        it("should call delayShow with the given options", function() {
          spyOn(index, 'delayShow');
          index.show(options);
          expect(index.delayShow).toHaveBeenCalledWith(options);
        });
      });

      describe("when the projects are loaded", function() {
        var project
        beforeEach(function() {
          user.projects.loaded = true;
          project = new Project({slug: options.projectSlug});
          spyOn(index.projects, 'findBySlug').andReturn(project);
        });

        describe("when options doesn't have a projectSlug", function() {
          beforeEach(function() {
            delete options.projectSlug;
          });
          it("should call initializeMainRegion with the given options", function() {
            spyOn(index, 'initializeMainRegion');
            index.show(options);
            expect(index.initializeMainRegion).not.toHaveBeenCalledWith(options);
          });
        });

        describe("when options has a projectSlug", function() {
          it("should call initializeMainRegion with the given options", function() {
            spyOn(index, 'initializeMainRegion');
            index.show(options);
            expect(index.initializeMainRegion).toHaveBeenCalledWith(options);
          });
        });

        describe("and projectsRegion doesn't have a current view", function() {
          it("should initialize the projects region", function() {
            spyOn(index, 'initializeProjectsRegion');
            index.show(options);
            expect(index.initializeProjectsRegion).toHaveBeenCalledWith('eat-a-taco');
          });
        });

        describe("and projectsRegion has a current view", function() {
          beforeEach(function() {
            index.projectsRegion.currentView = {};
          });

          it("should not initialize the projects region", function() {
            spyOn(index, 'initializeProjectsRegion');
            index.projectsRegion.currentView.selectProject = jasmine.createSpy();
            index.show(options);
            expect(index.initializeProjectsRegion).not.toHaveBeenCalled();
            expect(index.projectsRegion.currentView.selectProject).toHaveBeenCalledWith('eat-a-taco');
          });
        });

        describe("and feedRegion doesn't have a current view", function() {
          it("should call initializeFeedRegion", function() {
            spyOn(index, 'initializeFeedRegion');
            index.show(options);
            expect(index.initializeFeedRegion).toHaveBeenCalledWith();
          });
        });

        describe("and feedRegion has a current view", function() {
          beforeEach(function() {
            index.feedRegion.currentView = {};
          });

          it("should not call initializeFeedRegion", function() {
            spyOn(index, 'initializeFeedRegion');
            index.feedRegion.currentView.selectProject = jasmine.createSpy();
            index.show(options);
            expect(index.initializeFeedRegion).not.toHaveBeenCalled();
          });
        });

      });

    });

    describe("#delayShow", function() {
      it("it should attach a callback on the projects reset event", function() {
        var options = {};
        spyOn(index.projects, 'on').andCallThrough();
        spyOn(index.projects, 'off');
        spyOn(index, 'render').andReturn(index);
        spyOn(index, 'show');
        index.delayShow(options);
        expect(index.projects.on).toHaveBeenCalledWith('reset', jasmine.any(Function));
        index.projects.trigger('reset');
        expect(index.render).toHaveBeenCalled();
        expect(index.show).toHaveBeenCalledWith(options);
      });
    });

    describe("initializeProjectsRegion", function() {
      it("should make a new projects view and show it", function() {
        spyOn(index.projectsRegion, 'show');
        index.initializeProjectsRegion('eat-that-taco');
        expect(index.projectsRegion.show).toHaveBeenCalledWith(jasmine.any(ProjectsView));
        var projectsView = index.projectsRegion.show.mostRecentCall.args[0];
        expect(projectsView.options.projects).toBe(index.projects);
        expect(projectsView.options.selectedProject).toEqual('eat-that-taco');
      });
    });

    describe("initializeFeedRegion", function() {
      it("should make a new feed view and show it", function() {
        spyOn(index.feedRegion, 'show');
        index.initializeFeedRegion();
        expect(index.feedRegion.show).toHaveBeenCalledWith(jasmine.any(FeedView));
        var feedView = index.feedRegion.show.mostRecentCall.args[0];
        expect(feedView.options.collection).toBe(index.feed);
      });
    });

    describe("initializeMainRegion", function() {
      var options;
      it("should make a new main view and show it", function() {
        var project = new Project;
        options = {
          projectSlug: 'love-a-duck',
          something: 'else'
        };
        spyOn(index.mainRegion, 'show');
        spyOn(index.projects, 'findBySlug').andReturn(project);

        index.initializeMainRegion(options);
        expect(index.projects.findBySlug).toHaveBeenCalledWith('love-a-duck');
        expect(index.mainRegion.show).toHaveBeenCalledWith(jasmine.any(MainView));

        var mainView = index.mainRegion.show.mostRecentCall.args[0];
        expect(mainView.model).toBe(project);
        expect(mainView.options.something).toBe('else');
      });

      describe("when a project does not exist for that slug", function() {
        beforeEach(function() {
          options = {
            projectSlug: 'love-two-ducks'
          };
          spyOn(index.projects, 'findBySlug').andReturn(undefined);
        });
        it("should redirect to /", function() {
          spyOn(index.mainRegion, 'show');
          App.router = jasmine.createSpyObj('App.router', ['navigate']);
          // spyOn(App, 'router').andReturn(router);
          index.initializeMainRegion(options);
          expect(index.mainRegion.show).not.toHaveBeenCalled();
          expect(App.router.navigate).toHaveBeenCalledWith("/", {trigger:true});
        });
        afterEach(function() {
          delete App.router;
        });
      });


    });

    describe("#getTemplate", function() {
      describe("when the projects are not loaded", function() {
        it("should return a loading template", function() {
          expect(index.getTemplate().source).toContain('Loading...');
        });
      });
      describe("when the projects are loaded", function() {
        beforeEach(function() {
          index.projects.loaded = true;
        });
        it("should render the loaded template", function() {
          expect(index.getTemplate().source).not.toContain('Loading...');
        });
      });
    });

  });


});
