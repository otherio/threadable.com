define(function(require) {

  return {
    login: {
      success:{
        status: 202,
        responseText: '{"success":true,"user":{"created_at":"2012-12-16T19:35:34Z","email":"jared@change.org","id":1,"name":null,"slug":"","updated_at":"2012-12-16T19:35:34Z"},"authentication_token":"k9QvnfP8zePxrpN9MZCf"}'
      }
    },
    projects: {
      success: {
        status: 200,
        responseText: '[{"created_at":"2012-12-02T03:01:04Z","description":null,"id":11,"name":"Project 1","slug":"project-1","updated_at":"2012-12-02T03:01:04Z"},{"created_at":"2012-12-02T03:01:07Z","description":null,"id":12,"name":"Project 2","slug":"project-2","updated_at":"2012-12-02T03:01:07Z"},{"created_at":"2012-12-02T03:01:47Z","description":null,"id":13,"name":"Occupy","slug":"occupy-1","updated_at":"2012-12-02T03:01:47Z"},{"created_at":"2012-12-02T03:05:22Z","description":null,"id":14,"name":"Foo","slug":"foo","updated_at":"2012-12-02T03:05:22Z"},{"created_at":"2012-12-02T03:05:25Z","description":null,"id":15,"name":"Bar","slug":"bar","updated_at":"2012-12-02T03:05:25Z"},{"created_at":"2012-12-02T03:05:34Z","description":null,"id":16,"name":"Love it","slug":"love-it","updated_at":"2012-12-02T03:05:34Z"},{"created_at":"2012-12-02T03:18:35Z","description":null,"id":17,"name":"boosh","slug":"boosh","updated_at":"2012-12-02T03:18:35Z"},{"created_at":"2012-12-02T03:27:08Z","description":null,"id":18,"name":"asdsadsa","slug":"asdsadsa","updated_at":"2012-12-02T03:27:08Z"},{"created_at":"2012-12-02T03:27:10Z","description":null,"id":19,"name":"asdsa","slug":"asdsa","updated_at":"2012-12-02T03:27:10Z"},{"created_at":"2012-12-02T03:59:45Z","description":null,"id":20,"name":"Fuck a Duck","slug":"fuck-a-duck","updated_at":"2012-12-02T03:59:45Z"},{"created_at":"2012-12-02T06:41:36Z","description":null,"id":21,"name":"ZOMG","slug":"zomg","updated_at":"2012-12-02T06:41:36Z"},{"created_at":"2012-12-05T03:24:45Z","description":null,"id":22,"name":"eat fish","slug":"eat-fish","updated_at":"2012-12-05T03:24:45Z"}]'
      }
    }
  };
});
