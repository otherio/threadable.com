//= require modernizr
//= require ga
//= require mixpanel
//= require rails_env
//= require user_voice
//= require jquery
//= require_tree ../../../vendor/assets/javascripts/uikit
//= require docent
//= require iconic.min
//= require_self

UserVoice.push(['set', {
  accent_color: '#448dd6',
  trigger_color: 'white',
  trigger_background_color: '#448dd6'
}]);

UserVoice.push(['autoprompt', {}]);

$(document).on('click', 'a[href=""]', function(e){ e.preventDefault(); });
