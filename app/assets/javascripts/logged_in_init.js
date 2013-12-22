whenReady(function() {

  if (Covered.page.current_user) {
    var user = Covered.page.current_user;
    var organization = Covered.page.current_organization || {};
    // Identify the user and pass traits
    // To enable, replace sample data with actual user traits and uncomment the line
    UserVoice.push(['identify', {
      email:      user.email_address, // User’s email address
      name:       user.name, // User’s real name
      id:         user.id, // Optional: Unique id of the user (if set, this should not change)

      //created_at: 1364406966, // Unix timestamp for the date the user signed up
      //type:       'Owner', // Optional: segment your users by type
      account: {
        id:           organization.id, // Optional: associate multiple users with a single account
        name:         organization.name, // Account name
        // created_at:   1364406966, // Unix timestamp for the date the account was created
        // monthly_rate: 9.99, // Decimal; monthly rate of the account
        // ltv:          1495.00, // Decimal; lifetime value of the account
        // plan:         'Enhanced' // Plan name for the account
      }
    }]);

    // Add default trigger to the bottom-right corner of the window:
    UserVoice.push(['addTrigger', { mode: 'contact', trigger_style: 'tab', trigger_position: 'right' }]);
  }

});

