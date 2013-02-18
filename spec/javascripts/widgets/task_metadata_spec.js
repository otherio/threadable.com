describe("widgets/task_metadata", function(){

  beforeEach(function(){
    loadFixture('widgets/task_metadata');
    this.widget = Multify.Widget('task_metadata');
    delete this.widget.users;  // this is messy, but avoids test pollution
  });

  describe("Init", function() {
    xit("sets up tooltips for doers", function() {

    });
  });

  describe("getCurrentProjectMembers", function() {
    var spy;
    beforeEach(function() {
      ENV = {
        currentProject: {slug: 'project-slug'},
        currentConversation: {slug: 'conversation-slug'}
      };
      Multify.initialize();  // reset current project
      jasmine.Ajax.useMock();
      spy = jasmine.createSpy();
    });

    it("gets the current project members and returns them in the right format", function() {
      this.widget.getCurrentProjectMembers(spy);
      mostRecentAjaxRequest().response({status: 200, responseText: '[{"name": "foo", "email": "foo@example.com", "id": 1}]'});
      expect(spy).toHaveBeenCalledWith([ { name: 'foo', email: 'foo@example.com', id: 1 } ]);
    });

    it("fetches from the right url", function() {
      this.widget.getCurrentProjectMembers(spy);
      expect(mostRecentAjaxRequest().url).toEqual('/project-slug/members');
    });

    it("only gets the project members once", function() {
      clearAjaxRequests();
      this.widget.getCurrentProjectMembers(spy);
      expect(ajaxRequests.length).toEqual(1);
    });
  });

  describe("addDoersPopup", function() {
    describe("initialize", function() {
      it("binds the popover to add doers", function() {
        var popoverSpy = spyOn($.prototype, 'popover');
        this.widget.initialize();
        expect(popoverSpy).toHaveBeenCalledWith({ html: true, content: $('.add-others-popover').html() });
      });
    });

    describe("user list", function() {
      beforeEach(function() {
        this.widget.initialize();
      });

      it("fetches the user list when the control is opened", function() {
        spyOn(this.widget, "getCurrentProjectMembers");
        $('.add-others').click();
        expect(this.widget.getCurrentProjectMembers).toHaveBeenCalled();
      });

      describe("with the user list open", function() {
        beforeEach(function() {
          $('.add-others').click();
          mostRecentAjaxRequest().response({status: 200, responseText: '[{"avatar_url":"http://gravatar.com/avatar/45b9d367acf9f3165389cb47d66b086d.png?s=48","created_at":"2013-02-18T00:50:44Z","email":"alice@ucsd.edu","id":1,"name":"Alice Neilson","slug":"alice-neilson","updated_at":"2013-02-18T00:51:27Z"},{"avatar_url":"http://gravatar.com/avatar/205511b09c34f87e73551c5d1323c7e3.png?s=48","created_at":"2013-02-18T00:50:45Z","email":"tom@ucsd.edu","id":2,"name":"Tom Canver","slug":"tom-canver","updated_at":"2013-02-18T00:50:45Z"},{"avatar_url":"http://gravatar.com/avatar/77cdc97fe3b7dc8e9a70d766bb334ecd.png?s=48","created_at":"2013-02-18T00:50:45Z","email":"yan@ucsd.edu","id":3,"name":"Yan Hzu","slug":"yan-hzu","updated_at":"2013-02-18T00:50:45Z"},{"avatar_url":"http://gravatar.com/avatar/e7389b0cd051a081509fdb134045a51b.png?s=48","created_at":"2013-02-18T00:50:46Z","email":"bethany@ucsd.edu","id":4,"name":"Bethany Pattern","slug":"bethany-pattern","updated_at":"2013-02-18T00:50:46Z"},{"avatar_url":"http://gravatar.com/avatar/b09a1a251e7c5bb5915c9e577bc562f8.png?s=48","created_at":"2013-02-18T00:50:46Z","email":"bob@ucsd.edu","id":5,"name":"Bob Cauchois","slug":"bob-cauchois","updated_at":"2013-02-18T00:50:46Z"}]'});
        });

        it("focuses the input field immediately", function() {
          expect($("input.user-search")).toBeFocused();
        });

        xit("disables scrolling for the page when open", function() {

        });

        it("closes when pressing escape", function() {
          runs(function() {
            var press = jQuery.Event("keyup");
            press.ctrlKey = false;
            press.which = 27;
            $("body").trigger(press);
          });

          waits(300);

          runs(function() {
            expect($('.task-controls')).not.toContain('.popover');
          });
        });

        it("closes when clicking outside the popover", function() {
          runs(function() {
            $('html').click();
          });

          waits(300);

          runs(function() {
            expect($('.task-controls')).not.toContain('.popover');
          });
        });

        describe("rendering user list", function() {
          it("displays a complete list of users", function() {
            expect($('.popover-content .user-list li').length).toBeGreaterThan(0);
          });

          it("includes emails, names, and icons", function() {
            expect($('.popover-content .user-list li').text()).toMatch(/Alice Neilson/);
            expect($('.popover-content .user-list li').text()).toMatch(/alice@ucsd\.edu/);
            expect($('.popover-content .user-list li').html()).toMatch(/http:\/\/gravatar.com\/avatar\//);
          });

          xit("only generates the list when opening the control", function() {

          });
        });

        describe("filtering the user list", function() {
          it("filters the list of users", function() {
            expect($('.popover-content .user-list li').length).toEqual(5);
            $('input.user-search').val('can').keyup();
            expect($('.popover-content .user-list li').length).toEqual(1);
          });

          it("highlights the entered text in the user list", function() {
            $('input.user-search').val('can').keyup();
            expect($('.popover-content .user-list li').html()).toMatch(/<strong>Can<\/strong>/);
          });
        });

        describe("adding doers", function() {
          beforeEach(function() {
            $('.popover-content .user-list li').first().click();
          });

          it("adds the clicked doer", function() {
            var request = mostRecentAjaxRequest();
            expect(request.url).toEqual(Multify.project_task_doers_path(ENV.currentProject.slug, ENV.currentConversation.slug));
            expect(request.method).toEqual('POST');
            expect(request.params).toEqual('doer_id=1')
          });

          it("closes the popover", function() {
            waits(300);

            runs(function() {
              expect($('.task-controls')).not.toContain('.popover');
            });
          });

          it("updates the displayed list of doers on the task", function() {
            expect($('.doers')).toContain('i.icon-spinner');
            mostRecentAjaxRequest().response({status: 201, responseText: ''});
            expect($('.doers')).not.toContain('i.icon-spinner');
            expect($('.doers')).toContain('img[alt="Alice Neilson"]');
          });

          it("removes the spinner on failure", function() {
            expect($('.doers')).toContain('i.icon-spinner');
            mostRecentAjaxRequest().response({status: 500, responseText: ''});
            expect($('.doers')).not.toContain('i.icon-spinner');
          });

          it("puts a tooltip on the new doer icon", function() {
            var tipSpy = spyOn($.prototype, 'tooltip');
            mostRecentAjaxRequest().response({status: 201, responseText: ''});
            expect(tipSpy).toHaveBeenCalled();
          });
        });
      });
    });
  });
});
