# require 'spec_helper'

# describe Covered::Operations::StripUserSpecificContentFromEmailMessageBody do

#   def self.texts
#     [
#       [
#       # ------------------------------------------------------------------------
# <<-BEFORE,
# BEFORE
#       # ------------------------------------------------------------------------
# <<-AFTER
# AFTER
#       # ------------------------------------------------------------------------
#       ],

#       # ========================================================================

#       [
#       # ------------------------------------------------------------------------
# <<-BEFORE,
# <div dir="ltr">I am a banana.</div>
# <div class="gmail_extra">
# <br><br><div class="gmail_quote">On Sun, Sep 15, 2013 at 4:11 PM,  <span dir="ltr"><<a href="mailto:ian@sonic.net" target="_blank">ian@sonic.net</a>></span> wrote:<br><blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
# <u></u>


# <div>
# <p>This is an email. See it mail.
# </p>
# <div style="margin-top:1em">
# <div style="display:none!important">
# ##CovMid: 52363e8651497_63f95ece01e947396a ##
# </div>
# <table border="0" cellpadding="0" color="dark grey" style="font-weight:200" width="480"><tbody>
# <tr>
# <td>
# <table align="left" border="0" cellpadding="2" cellspacing="0" height="27" width="234"><tbody><tr>
# <td>
# <div>

# <a href="mailto:mars.rover@staging.covered.io" style="color:#3498db;text-decoration:none!important;background-color:#16a085;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">New conversation</a>

# </div>
# </td>
# <td>
# <div>

# <a href="mailto:mars.rover@staging.covered.io?subject=%E2%9C%94+" style="color:#3498db;text-decoration:none!important;background-color:#16a085;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">New task</a>

# </div>
# </td>
# </tr></tbody></table>
# </td>
# </tr>
# <tr>
# <td>
# <table align="left" border="0" cellpadding="2" cellspacing="0" width="115"><tbody><tr>
# <td>
# <div>

# <a href="http://www-staging.covered.io/mars-rover/conversations/im-curious-about-this-first-message#message-201" style="color:#3498db;text-decoration:none!important;background-color:#7f8c8d;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">View on Covered</a>

# </div>
# </td>
# </tr></tbody></table>
# <table align="right" border="0" cellpadding="2" cellspacing="0" width="357"><tbody><tr>
# <td style="color:#95a5a6;text-align:right">
# <div style="font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:12px">
# <a href="http://www-staging.covered.io/mars-rover" style="color:#3498db;text-decoration:none!important" target="_blank">Mars Exploration Rover</a>
# |
# <a href="mailto:mars.rover@staging.covered.io" style="color:#3498db;text-decoration:none!important" target="_blank">mars.rover@staging.covered.io</a>
# </div>
# <div style="font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:10px">
# sent to <a href="mailto:coveredthrowaway1@gmail.com" target="_blank">coveredthrowaway1@gmail.com</a> | mute conversation | <a href="http://www-staging.covered.io/mars-rover/unsubscribe" style="color:#3498db;text-decoration:none!important" target="_blank">unsubscribe</a>
# </div>
# </td>
# </tr></tbody></table>
# </td>
# </tr>
# </tbody></table>
# <div style="display:none!important">
# ##CovMid: 52363e8651497_63f95ece01e947396a ##
# </div>
# </div>
# </div>
# BEFORE
#       # ------------------------------------------------------------------------
# <<-AFTER
# <div dir="ltr">I am a banana.</div>
# <div class="gmail_extra">
# <br><br><div class="gmail_quote">On Sun, Sep 15, 2013 at 4:11 PM,  <span dir="ltr"><<a href="mailto:ian@sonic.net" target="_blank">ian@sonic.net</a>></span> wrote:<br><blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
# <u></u>


# <div>
# <p>This is an email. See it mail.
# </p>
# <div style="margin-top:1em">
# <div style="display:none!important">

# </div>
# </div>
# </div>
# AFTER
#       # ------------------------------------------------------------------------
#       ],

#       # ========================================================================

#       [
#       # ------------------------------------------------------------------------
# <<-BEFORE,
# <div dir="ltr">I am a banana.</div>
# <div class="gmail_extra">
# <br><br><div class="gmail_quote">On Sun, Sep 15, 2013 at 4:11 PM,  <span dir="ltr"><<a href="mailto:ian@sonic.net" target="_blank">ian@sonic.net</a>></span> wrote:<br><blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
# <u></u>


# <div>
# <p>This is an email. See it mail.
# </p>
# <div style="margin-top:1em">
# <div style="display:none!important">
# ##CovMid:=2052363e8651497_63f95ece01e947396a=20##
# </div>
# <table border="0" cellpadding="0" color="dark grey" style="font-weight:200" width="480"><tbody>
# <tr>
# <td>
# <table align="left" border="0" cellpadding="2" cellspacing="0" height="27" width="234"><tbody><tr>
# <td>
# <div>

# <a href="mailto:mars.rover@staging.covered.io" style="color:#3498db;text-decoration:none!important;background-color:#16a085;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">New conversation</a>

# </div>
# </td>
# <td>
# <div>

# <a href="mailto:mars.rover@staging.covered.io?subject=%E2%9C%94+" style="color:#3498db;text-decoration:none!important;background-color:#16a085;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">New task</a>

# </div>
# </td>
# </tr></tbody></table>
# </td>
# </tr>
# <tr>
# <td>
# <table align="left" border="0" cellpadding="2" cellspacing="0" width="115"><tbody><tr>
# <td>
# <div>

# <a href="http://www-staging.covered.io/mars-rover/conversations/im-curious-about-this-first-message#message-201" style="color:#3498db;text-decoration:none!important;background-color:#7f8c8d;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">View on Covered</a>

# </div>
# </td>
# </tr></tbody></table>
# <table align="right" border="0" cellpadding="2" cellspacing="0" width="357"><tbody><tr>
# <td style="color:#95a5a6;text-align:right">
# <div style="font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:12px">
# <a href="http://www-staging.covered.io/mars-rover" style="color:#3498db;text-decoration:none!important" target="_blank">Mars Exploration Rover</a>
# |
# <a href="mailto:mars.rover@staging.covered.io" style="color:#3498db;text-decoration:none!important" target="_blank">mars.rover@staging.covered.io</a>
# </div>
# <div style="font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:10px">
# sent to <a href="mailto:coveredthrowaway1@gmail.com" target="_blank">coveredthrowaway1@gmail.com</a> | mute conversation | <a href="http://www-staging.covered.io/mars-rover/unsubscribe" style="color:#3498db;text-decoration:none!important" target="_blank">unsubscribe</a>
# </div>
# </td>
# </tr></tbody></table>
# </td>
# </tr>
# </tbody></table>
# <div style="display:none!important">
# ##CovMid:=2052363e8651497_63f95ece01e947396a=20##
# </div>
# </div>
# </div>
# BEFORE
#       # ------------------------------------------------------------------------
# <<-AFTER
# <div dir="ltr">I am a banana.</div>
# <div class="gmail_extra">
# <br><br><div class="gmail_quote">On Sun, Sep 15, 2013 at 4:11 PM,  <span dir="ltr"><<a href="mailto:ian@sonic.net" target="_blank">ian@sonic.net</a>></span> wrote:<br><blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">
# <u></u>


# <div>
# <p>This is an email. See it mail.
# </p>
# <div style="margin-top:1em">
# <div style="display:none!important">

# </div>
# </div>
# </div>
# AFTER
#       # ------------------------------------------------------------------------
#       ],
#       [
#       # ------------------------------------------------------------------------
# <<-BEFORE,
# BEFORE
#       # ------------------------------------------------------------------------
# <<-AFTER
# AFTER
#       # ------------------------------------------------------------------------
#       ],

#       # ========================================================================

#       [
#       # ------------------------------------------------------------------------
# <<-BEFORE,
# <div><br></div><div><br></div></div>


# <pre>_____
# View on Covered: <a href=3D"http://beta.covered.io/covered/conversations/=
# show-dont-tell" target=3D"_blank">http://beta.covered.io/covered/conversa=
# tions/show-dont-tell</a>
# Unsubscribe:  <a href=3D"http://beta.covered.io/covered/unsubscribe" targ=
# et=3D"_blank">http://beta.covered.io/covered/unsubscribe/jqxMBUz0fz_8Majl=
# KaPbf9E=</a>
# </pre>

# </blockquote></div><br></div>
# BEFORE
#       # ------------------------------------------------------------------------
# <<-AFTER
# <div><br></div><div><br></div></div>


# <pre>_____
# View on Covered: <a href=3D"http://beta.covered.io/covered/conversations/=
# show-dont-tell" target=3D"_blank">http://beta.covered.io/covered/conversa=
# tions/show-dont-tell</a>
# Unsubscribe:  <a href=3D"http://beta.covered.io/covered/unsubscribe" targ=
# et=3D"_blank">http://beta.covered.io/covered/unsubscribe=
# </a>
# </pre>

# </blockquote></div><br></div>
# AFTER
#       # ------------------------------------------------------------------------
#       ],

#       # ========================================================================

#       [
#       # ------------------------------------------------------------------------
# <<-BEFORE,
# "Sorry I sent that blank mail. Shouldn't be possible in the future. derp.


# On Sun, Apr 21, 2013 at 5:58 PM, Ian Baker <ian@sonic.net> wrote:

# > This is a response!
# >
# > So there!
# >
# > On Sunday, April 21, 2013, Nicole Aptekar wrote:
# >
# > > Another test. Mail back plz?
# > > _____
# > > View on Covered:
# > > http://beta.covered.io/covered-testing/conversations/testing
# > > Unsubscribe:
# > >
# > http://beta.covered.io/covered-testing/unsubscribe
# > >
# > >
# > _____
# > View on Covered:
# > http://beta.covered.io/covered-testing/conversations/testing
# > Unsubscribe:
# > http://beta.covered.io/covered-testing/unsubscribe/jqxMBUz0fz_8MajlKaPbf9E=
# >
# BEFORE
#       # ------------------------------------------------------------------------
# <<-AFTER
# "Sorry I sent that blank mail. Shouldn't be possible in the future. derp.


# On Sun, Apr 21, 2013 at 5:58 PM, Ian Baker <ian@sonic.net> wrote:

# > This is a response!
# >
# > So there!
# >
# > On Sunday, April 21, 2013, Nicole Aptekar wrote:
# >
# > > Another test. Mail back plz?
# > > _____
# > > View on Covered:
# > > http://beta.covered.io/covered-testing/conversations/testing
# > > Unsubscribe:
# > >
# > http://beta.covered.io/covered-testing/unsubscribe
# > >
# > >
# > _____
# > View on Covered:
# > http://beta.covered.io/covered-testing/conversations/testing
# > Unsubscribe:
# > http://beta.covered.io/covered-testing/unsubscribe
# >
# AFTER
#       # ------------------------------------------------------------------------
#       ]

#     ]
#   end

#   texts.each_with_index do |(before, expected_after), index|
#     it "should strip example #{index} correctly" do
#       after = described_class.call(covered: covered, body: before)
#       expect(after).to eq expected_after
#     end
#   end

# end
