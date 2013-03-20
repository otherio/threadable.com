describe("widgets/task_metadata", function(){

  beforeEach(function(){
    loadFixture('widgets/task_metadata');
    this.widget = Multify.Widget('task_metadata');
    delete this.widget.users;  // this is messy, but avoids test pollution

    ENV = {
      currentProject: {slug: 'project-slug'},
      currentConversation: {slug: 'conversation-slug'},
      currentUser: {id: 1, name: 'Alice Neilson', avatar_url: "/assets/fixtures/alice.jpg"},
      currentTaskDoers: JSON.parse('[{"avatar_url":"http://gravatar.com/avatar/205511b09c34f87e73551c5d1323c7e3.png?s=48","created_at":"2013-02-18T00:50:45Z","email":"tom@ucsd.edu","id":2,"name":"Tom Canver","slug":"tom-canver","updated_at":"2013-02-18T00:50:45Z"}]')
    };
    Multify.initialize();  // reset current project
    jasmine.Ajax.useMock();
  });

  describe("Init", function() {
    xit("sets up tooltips for doers", function() {

    });

  });

  describe("toggle the user as a doer", function() {
    describe("clicking the sign me up link", function() {
      beforeEach(function() {
        $('.toggle-doer-self').click();
      });

      it("adds the current user as a doer", function() {
        var request = mostRecentAjaxRequest();
        expect(request.url).toEqual(Multify.project_task_doers_path(ENV.currentProject.slug, ENV.currentConversation.slug));
        expect(request.method).toEqual('POST');
        expect(request.params).toEqual('doer_id=1')
      });

      it("updates the displayed list of doers on the task", function() {
        expect($('.doers')).toContain('i.icon-spinner');
        mostRecentAjaxRequest().response({status: 201, responseText: ''});
        expect($('.doers')).not.toContain('i.icon-spinner');
        expect($('.doers')).toContain('img[alt="Alice Neilson"]');
        expect(_.find(Multify.currentTaskDoers, function(doer) { return doer.name == "Alice Neilson"})).toBeTruthy();
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

      it("updates the link text", function() {
        expect($('.toggle-doer-self').text()).toEqual(' remove me');
      });
    });

    describe("clicking the remove me link", function() {
      beforeEach(function() {
        Multify.currentTaskDoers.push(Multify.currentUser);
        Multify.Widget('task_metadata').appendDoerIcon(Multify.currentUser);
        $('.toggle-doer-self').click();
      });

      it("removes the current user as a doer", function() {
        var request = mostRecentAjaxRequest();
        expect(request.url).toEqual(Multify.project_task_doer_path(ENV.currentProject.slug, ENV.currentConversation.slug, Multify.currentUser.id));
        expect(request.method).toEqual('DELETE');
      });

      it("updates the displayed list of doers on the task", function() {
        expect($('.doers')).toContain('i.icon-spinner');
        mostRecentAjaxRequest().response({status: 204, responseText: ''});
        expect($('.doers')).not.toContain('i.icon-spinner');
        expect($('.doers')).not.toContain('img[alt="Alice Neilson"]');
        expect(_.find(Multify.currentTaskDoers, function(doer) { return doer.name == "Alice Neilson"})).toBeFalsy();
      });

      it("removes the spinner on failure", function() {
        expect($('.doers')).toContain('i.icon-spinner');
        mostRecentAjaxRequest().response({status: 500, responseText: ''});
        expect($('.doers')).not.toContain('i.icon-spinner');
      });

      it("updates the link text", function() {
        expect($.trim($('.toggle-doer-self').text())).toEqual('sign me up');
      });
    });
  });

  describe("getCurrentProjectMembers", function() {
    var spy;
    beforeEach(function() {
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
      it("binds the popover to add others", function() {
        var popoverSpy = spyOn($.prototype, 'popover');
        this.widget.initialize();
        expect(popoverSpy).toHaveBeenCalledWith({ html: true, trigger: 'manual', content: $('.add-others-popover').html() });
      });
    });

    describe("user list", function() {
      it("fetches the user list when the control is opened", function() {
        spyOn(this.widget, "getCurrentProjectMembers");
        $('.add-others').click();
        expect(this.widget.getCurrentProjectMembers).toHaveBeenCalled();
      });

      describe("with the user list open", function() {
        beforeEach(function() {
          // dummy dom element for the scroll disabling behavior to work on.
          $('body').append('<div class="conversations_layout"><div class="right"></div></div>');
          $('.conversations_layout .right').css('overflow', 'scroll');

          $('.add-others').click();
          mostRecentAjaxRequest().response({status: 200, responseText: '[{"avatar_url":"http://gravatar.com/avatar/45b9d367acf9f3165389cb47d66b086d.png?s=48","created_at":"2013-02-18T00:50:44Z","email":"alice@ucsd.edu","id":1,"name":"Alice Neilson","slug":"alice-neilson","updated_at":"2013-02-18T00:51:27Z"},{"avatar_url":"http://gravatar.com/avatar/205511b09c34f87e73551c5d1323c7e3.png?s=48","created_at":"2013-02-18T00:50:45Z","email":"tom@ucsd.edu","id":2,"name":"Tom Canver","slug":"tom-canver","updated_at":"2013-02-18T00:50:45Z"},{"avatar_url":"http://gravatar.com/avatar/77cdc97fe3b7dc8e9a70d766bb334ecd.png?s=48","created_at":"2013-02-18T00:50:45Z","email":"yan@ucsd.edu","id":3,"name":"Yan Hzu","slug":"yan-hzu","updated_at":"2013-02-18T00:50:45Z"},{"avatar_url":"http://gravatar.com/avatar/e7389b0cd051a081509fdb134045a51b.png?s=48","created_at":"2013-02-18T00:50:46Z","email":"bethany@ucsd.edu","id":4,"name":"Bethany Pattern","slug":"bethany-pattern","updated_at":"2013-02-18T00:50:46Z"},{"avatar_url":"http://gravatar.com/avatar/b09a1a251e7c5bb5915c9e577bc562f8.png?s=48","created_at":"2013-02-18T00:50:46Z","email":"bob@ucsd.edu","id":5,"name":"Bob Cauchois","slug":"bob-cauchois","updated_at":"2013-02-18T00:50:46Z"}]'});
        });

        afterEach(function(){
          $('.conversations_layout').remove();
        });

        it("focuses the input field immediately", function() {
          expect($("input.user-search")).toBeFocused();
        });

        it("disables scrolling for the page when open", function() {
          expect($('.conversations_layout .right').css('overflow')).toEqual('hidden');
        });

        it("re-enables scrolling when closed", function() {
          $('.add-others').click();
          expect($('.conversations_layout .right').css('overflow')).toEqual('scroll');
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

          it("disables users who are already doers", function() {
            expect($('.popover-content .user-list li.disabled').text()).toMatch(/Tom Canver/);
            $('.popover-content .user-list li.disabled').click();
            waits(300);

            runs(function() {
              expect($('.task-controls')).toContain('.popover');
            });
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
            expect(_.find(Multify.currentTaskDoers, function(doer) { return doer.name == "Alice Neilson"})).toBeTruthy();
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

        describe("invite", function() {
          it("can open the invite modal", function() {
            // runs(function() {
            //   $('.task_metadata .add-others').click();
            // });

            // waits(300);

            runs(function() {
              spyOn(Multify,'trigger');
              expect($('.task_metadata .popover').is(':visible')).toBe(true);
              $('.task_metadata .user-search').val('"Jared Grippe" <jared@foo.com>');
              $('.task_metadata .controls .invite-link').click();
              expect(Multify.trigger).toHaveBeenCalledWith('show_invite_modal', {
                name: 'Jared Grippe', email: 'jared@foo.com'
              });
            });
          });

          it("includes the search term", function() {
            expect($('.popover .invite-link-text').text()).toMatch(/Invite\.\.\./);
            $('input.user-search').val('can').keyup();
            expect($('.popover .invite-link-text').text()).toMatch(/Invite can/);
          });
        });
      });
    });
  });
});
