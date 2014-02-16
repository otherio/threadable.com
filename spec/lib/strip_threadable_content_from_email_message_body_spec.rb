require 'spec_helper'

describe StripThreadableContentFromEmailMessageBody do

  delegate :call, to: :described_class

  let :body do
<<-BODY
<div dir="ltr">Someone bug me tonight if I haven&#39;t already dealt with it and I&#39;ll handle mine. Sorry for being such a jerk!</div><div class="gmail_extra"><br><br><div class="gmail_quote">On Mon, Sep 23, 2013 at 1:09 PM,  <span dir="ltr">&lt;<a href="mailto:sfslim@gmail.com" target="_blank">sfslim@gmail.com</a>&gt;</span> wrote:<br>

<blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><u></u>


<div>
<p>Bumping this for tonight&#39;s worknight.<br><br></p>
<div style="margin-top:1em">
<div style="display:none!important">
##CovMid: Q0FMTzB0UzBnMU9UR1l1clplUUx1dHc9UHV3bmEwZ1EybW5DTGZDVGZ0NXl1VVZ4enNBQG1haWwuZ21haWwuY29t ##
</div><div class="im">
<table border="0" cellpadding="0" color="dark grey" style="font-weight:200" width="480">
<tbody><tr>
<td>
<table align="left" border="0" cellpadding="2" cellspacing="0" height="27" width="234"><tbody><tr>
<td>
<div>

<a href="http://emailbtn.net/do_this_task" style="color:#3498db;text-decoration:none!important;background-color:#1abc9c;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">I\&#39;ll do this!</a>

</div>
</td>
<td>
<div>

<a href="http://emailbtn.net/mark_task_done" style="color:#3498db;text-decoration:none!important;background-color:#1abc9c;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">Mark as done</a>

</div>
</td>
</tr></tbody></table>
<table align="right" border="0" cellpadding="2" cellspacing="0" height="27" width="234"><tbody><tr>
<td>
<div>

<a href="mailto:warehome@threadable.com" style="color:#3498db;text-decoration:none!important;background-color:#16a085;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">New conversation</a>

</div>
</td>
<td>
<div>

<a href="mailto:warehome@threadable.com?subject=%E2%9C%94+" style="color:#3498db;text-decoration:none!important;background-color:#16a085;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">New task</a>

</div>
</td>
</tr></tbody></table>
</td>
</tr>
<tr>
<td>
<table align="left" border="0" cellpadding="2" cellspacing="0" width="115"><tbody><tr>
<td>
<div>

<a href="http://threadable.com/warehome/conversations/clean-up-the-entryway#message-334" style="color:#3498db;text-decoration:none!important;background-color:#7f8c8d;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">View on Threadable</a>

</div>
</td>
</tr></tbody></table>
<table align="right" border="0" cellpadding="2" cellspacing="0" width="357"><tbody><tr>
<td style="color:#95a5a6;text-align:right">
<div style="font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:12px">
<a href="http://threadable.com/warehome" style="color:#3498db;text-decoration:none!important" target="_blank">Warehome</a>
|
<a href="mailto:warehome@threadable.com" style="color:#3498db;text-decoration:none!important" target="_blank">warehome@threadable.com</a>
</div>
<div style="font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:10px">
sent to <a href="mailto:nicoletbn@gmail.com" target="_blank">nicoletbn@gmail.com</a> | mute conversation | <a href="http://threadable.com/warehome/unsubscribe/59Vza2e6Xk_6NvDpad-DFtjZzXTvqJ9jDO4-7ujje3rVJ5Zrt6srB91D-2VnXrwXQki1VywguAcuO69QnSzNMWT_" style="color:#3498db;text-decoration:none!important" target="_blank">unsubscribe</a>
</div>
</td>
</tr></tbody></table>
</td>
</tr>
</tbody></table>
</div><div style="display:none!important">
##CovMid: Q0FMTzB0UzBnMU9UR1l1clplUUx1dHc9UHV3bmEwZ1EybW5DTGZDVGZ0NXl1VVZ4enNBQG1haWwuZ21haWwuY29t ##
</div>
</div>
</div>

</blockquote></div><br></div>
BODY
  end

  let :stripped_body do
<<-BODY
<div dir="ltr">Someone bug me tonight if I haven&#39;t already dealt with it and I&#39;ll handle mine. Sorry for being such a jerk!</div><div class="gmail_extra"><br><br><div class="gmail_quote">On Mon, Sep 23, 2013 at 1:09 PM,  <span dir="ltr">&lt;<a href="mailto:sfslim@gmail.com" target="_blank">sfslim@gmail.com</a>&gt;</span> wrote:<br>

<blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><u></u>


<div>
<p>Bumping this for tonight&#39;s worknight.<br><br></p>
<div style="margin-top:1em">
<div style="display:none!important">

</div>
</div>
</div>

</blockquote></div><br></div>
BODY
  end

  it "should strip unsubscribe tokens and threadable controls" do
    expect(call(body)).to eq stripped_body
  end

  context "with Lyra's crazy broken gmail forward" do
    let :body do
<<-BODY
<div dir="ltr"><div class="gmail_default" style="font-family:arial,helvetica,sans-serif">We can do group chats in gtalk - if we all invite/accept each other&#39;s chat requests, the workflow is:</div><div class="gmail_default" style="font-family:arial,helvetica,sans-serif">

<br></div><blockquote class="gmail_quote" style="margin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;padding-left:1ex"><ol style="margin:1em 0px;padding:0px;border:0px;outline:0px;font-size:13px;font-family:&#39;Helvetica Neue&#39;,HelveticaNeue,Helvetica,sans-serif;vertical-align:baseline;line-height:18.1875px">

<li style="margin:0px 0px 0px 2em;padding:0px;border:0px;outline:0px;font-weight:inherit;font-style:inherit;font-size:13px;font-family:inherit;vertical-align:baseline">Start a chat with a single person in your Chat list.</li>

<li style="margin:0px 0px 0px 2em;padding:0px;border:0px;outline:0px;font-weight:inherit;font-style:inherit;font-size:13px;font-family:inherit;vertical-align:baseline">Once you&#39;ve started the chat, click the person icon at the top of the chat window.</li>

<li style="margin:0px 0px 0px 2em;padding:0px;border:0px;outline:0px;font-weight:inherit;font-style:inherit;font-size:13px;font-family:inherit;vertical-align:baseline">In the field labeled &#39;Add people to this chat&#39;, enter the names of the contacts you want to add to your group chat.</li>

</ol></blockquote><div><br></div><div class="gmail_default" style="font-family:arial,helvetica,sans-serif">There are also stand-alone options like GroupMe. They&#39;ll keep our transcripts and might not have as creepy emoticons.</div>

<div class="gmail_default"><font face="arial, helvetica, sans-serif"><a href="https://groupme.com/">https://groupme.com/</a></font><br></div></div><div class="gmail_extra"><br><br><div class="gmail_quote">On 3 December 2013 13:13, Lyra Levin <span dir="ltr">&lt;<a href="mailto:lyralevin@gmail.com" target="_blank">lyralevin@gmail.com</a>&gt;</span> wrote:<br>

<blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div dir="ltr"><div class="gmail_default" style="font-family:arial,helvetica,sans-serif">Opening docs now!</div></div>
<div class="HOEnZb">
<div class="h5"><div class="gmail_extra"><br><br><div class="gmail_quote">On 3 December 2013 13:11, Eden Gallanter <span dir="ltr">&lt;<a href="mailto:edengallanter@gmail.com" target="_blank">edengallanter@gmail.com</a>&gt;</span> wrote:<br>


<blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><u></u>





<div>
<div style="margin-top:1em!important">
<div style="display:none!important">
Yay! We should maybe make some tasks and stuff. Also I am in google docs.


On Tue, Dec 3, 2013 at 1:10 PM, Lyra Levin &lt;<a href="mailto:lyralevin@gmail.com" target="_blank">lyralevin@gmail.com</a>&gt; wrote:

&gt;   Consider it fuckin&#39; tried!
&gt; ____________

</div>
<br>
</div>
<div dir="ltr">Yay! We should maybe make some tasks and stuff. Also I am in google docs.</div>
<div class="gmail_extra">
<br><br><div class="gmail_quote"><div>On Tue, Dec 3, 2013 at 1:10 PM, Lyra Levin <span dir="ltr">&lt;<a href="mailto:lyralevin@gmail.com" target="_blank">lyralevin@gmail.com</a>&gt;</span> wrote:<br></div><blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">



<u></u>





<div><div>
<div style="margin-top:1em!important">
<div style="display:none!important">
Consider it fuckin&#39; tried!                                                                          __________________________________________________________________________
##CovMid: PDUyOWU0OGM2Mjg4MDhfNjNmYmVmMzU0NWU5YzI0NmY4QGNvdmVyZWQuaW8- ##
</div>
<div>
<table border="0" cellpadding="0" color="dark grey" width="100%" style="font-weight:300!important;max-width:450px!important"><tbody><tr>
<td>
<table align="left" border="0" cellpadding="0" cellspacing="4" style="margin:0"><tbody><tr>
<td valign="middle" style="vertical-align:middle">

<a href="mailto:secret.art.organization@threadable.com" style="width:100%!important;border-radius:3px!important;display:inline-block!important;font-family:Helvetica Neue,Helvetica,Arial,sans-serif!important;text-align:center!important;text-decoration:none!important;border:#cccccc 1px solid!important;background:#fcfcfc!important;font-size:11px!important;line-height:22px!important;color:#16a085!important" target="_blank">  New conversation  </a>

</td>

<td valign="middle" style="vertical-align:middle">

<a href="mailto:secret.art.organization@threadable.com?subject=%E2%9C%94+" style="width:100%!important;border-radius:3px!important;display:inline-block!important;font-family:Helvetica Neue,Helvetica,Arial,sans-serif!important;text-align:center!important;text-decoration:none!important;border:#cccccc 1px solid!important;background:#fcfcfc!important;font-size:11px!important;line-height:22px!important;color:#16a085!important" target="_blank">  New task  </a>

</td>

<td valign="middle" style="vertical-align:middle">

<a href="https://threadable.com/secret-art-organization/conversations/hello#message-1254" style="width:100%!important;border-radius:3px!important;display:inline-block!important;font-family:Helvetica Neue,Helvetica,Arial,sans-serif!important;text-align:center!important;text-decoration:none!important;border:#cccccc 1px solid!important;background:#fcfcfc!important;font-size:11px!important;line-height:22px!important;color:#7f8c8d!important" target="_blank">  View on Threadable  </a>

</td>

</tr></tbody></table>
<table align="left" border="0" cellpadding="0" cellspacing="4" style="margin:0"></table>
</td>
</tr></tbody></table>
</div>
<div style="display:none!important">
##CovMid: PDUyOWU0OGM2Mjg4MDhfNjNmYmVmMzU0NWU5YzI0NmY4QGNvdmVyZWQuaW8- ##
</div>
<br>
</div>
Consider it fuckin&#39; tried!
</div><div>
<div style="margin-top:1em!important">
<div style="display:none!important">

</div>
</div>
<img width="1px" height="1px" alt="">
</div>
</div>
</blockquote>
</div>
<br>
</div><div>

<div style="margin-top:1em!important">
<div style="display:none!important">

</div>
</div>
<img width="1px" height="1px" alt=""></div></div></blockquote></div><br></div>
</div></div></blockquote></div><br></div>
BODY
    end

    let :stripped_body do
<<-BODY
<div dir="ltr"><div class="gmail_default" style="font-family:arial,helvetica,sans-serif">We can do group chats in gtalk - if we all invite/accept each other&#39;s chat requests, the workflow is:</div><div class="gmail_default" style="font-family:arial,helvetica,sans-serif">

<br></div><blockquote class="gmail_quote" style="margin:0px 0px 0px 0.8ex;border-left-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;padding-left:1ex"><ol style="margin:1em 0px;padding:0px;border:0px;outline:0px;font-size:13px;font-family:&#39;Helvetica Neue&#39;,HelveticaNeue,Helvetica,sans-serif;vertical-align:baseline;line-height:18.1875px">

<li style="margin:0px 0px 0px 2em;padding:0px;border:0px;outline:0px;font-weight:inherit;font-style:inherit;font-size:13px;font-family:inherit;vertical-align:baseline">Start a chat with a single person in your Chat list.</li>

<li style="margin:0px 0px 0px 2em;padding:0px;border:0px;outline:0px;font-weight:inherit;font-style:inherit;font-size:13px;font-family:inherit;vertical-align:baseline">Once you&#39;ve started the chat, click the person icon at the top of the chat window.</li>

<li style="margin:0px 0px 0px 2em;padding:0px;border:0px;outline:0px;font-weight:inherit;font-style:inherit;font-size:13px;font-family:inherit;vertical-align:baseline">In the field labeled &#39;Add people to this chat&#39;, enter the names of the contacts you want to add to your group chat.</li>

</ol></blockquote><div><br></div><div class="gmail_default" style="font-family:arial,helvetica,sans-serif">There are also stand-alone options like GroupMe. They&#39;ll keep our transcripts and might not have as creepy emoticons.</div>

<div class="gmail_default"><font face="arial, helvetica, sans-serif"><a href="https://groupme.com/">https://groupme.com/</a></font><br></div></div><div class="gmail_extra"><br><br><div class="gmail_quote">On 3 December 2013 13:13, Lyra Levin <span dir="ltr">&lt;<a href="mailto:lyralevin@gmail.com" target="_blank">lyralevin@gmail.com</a>&gt;</span> wrote:<br>

<blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><div dir="ltr"><div class="gmail_default" style="font-family:arial,helvetica,sans-serif">Opening docs now!</div></div>
<div class="HOEnZb">
<div class="h5"><div class="gmail_extra"><br><br><div class="gmail_quote">On 3 December 2013 13:11, Eden Gallanter <span dir="ltr">&lt;<a href="mailto:edengallanter@gmail.com" target="_blank">edengallanter@gmail.com</a>&gt;</span> wrote:<br>


<blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex"><u></u>





<div>
<div style="margin-top:1em!important">
<div style="display:none!important">
Yay! We should maybe make some tasks and stuff. Also I am in google docs.


On Tue, Dec 3, 2013 at 1:10 PM, Lyra Levin &lt;<a href="mailto:lyralevin@gmail.com" target="_blank">lyralevin@gmail.com</a>&gt; wrote:

&gt;   Consider it fuckin&#39; tried!
&gt; ____________

</div>
<br>
</div>
<div dir="ltr">Yay! We should maybe make some tasks and stuff. Also I am in google docs.</div>
<div class="gmail_extra">
<br><br><div class="gmail_quote"><div>On Tue, Dec 3, 2013 at 1:10 PM, Lyra Levin <span dir="ltr">&lt;<a href="mailto:lyralevin@gmail.com" target="_blank">lyralevin@gmail.com</a>&gt;</span> wrote:<br></div><blockquote class="gmail_quote" style="margin:0 0 0 .8ex;border-left:1px #ccc solid;padding-left:1ex">



<u></u>





<div><div>
<div style="margin-top:1em!important">
<div style="display:none!important">
Consider it fuckin&#39; tried!                                                                          __________________________________________________________________________

</div>
<br>
</div>
Consider it fuckin&#39; tried!
</div><div>
<div style="margin-top:1em!important">
<div style="display:none!important">

</div>
</div>
<img width="1px" height="1px" alt="">
</div>
</div>
</blockquote>
</div>
<br>
</div><div>

<div style="margin-top:1em!important">
<div style="display:none!important">

</div>
</div>
<img width="1px" height="1px" alt=""></div></div></blockquote></div><br></div>
</div></div></blockquote></div><br></div>
BODY
    end

    it "should strip threadable controls" do
      expect(call(body)).to eq stripped_body
    end
  end

  context "with a mailgun open tracking bug" do
    let :body do
<<-BODY
<img width="1px" height="1px" alt="" src="http://email.staging.threadable.com/o/aT1DQUxPMHRTMVBrbVRkYjclMkJVUWNZT0pOLW5tczM1RzA0b3RBT1VaSiUyQnhyeURpZFJjVTFRJTQwbWFpbC5nbWFpbC5jb20maD1iNjZhMmU5MzlkNTZmMGQ4MzQ1OWNjYzNjZWIyODEyMyZyPWlhbiU0MG90aGVyLmlvJmQ9ODk1NzE">

Yo momma.
BODY
    end

    let :stripped_body do
<<-BODY


Yo momma.
BODY
    end

    it "should strip the open tracker" do
      expect(call(body)).to eq stripped_body
    end
  end

  context 'with content isolated using img tags instead of hidden divs' do
    let :body do
<<-BODY
<body>
<div class="threadable-content" style="margin-top:0.5em !important;font-family:Helvetica Neue, Helvetica, Arial, sans-serif !important">
<img alt="" height="1px" src="https://s3.amazonaws.com/multify-production/superable-specialable-threadable-dividerable-headerable.png" width="1px"><div style="display:none; display:none !important;">
    Foop de doop                                                                                        ________________________________________________________________________________________
    ##CovMid: PDUzMDE0YTVmOWU2YWVfZTJjODRkNGY1MjQ1MDNkNEAxMjcuMC4wLjE- ##
  </div>
  <table border="0" cellpadding="0" class="threadable-controls" color="dark grey" width="100%" style="font-weight:300 !important;max-width:480px !important"><tbody><tr>
<td>
        <table align="left" border="0" cellpadding="0" cellspacing="0" class="threadable-button-table" style="margin:0 !important"><tbody><tr>
<td class="threadable-button" valign="bottom" style="padding-top:3px !important;padding-right:5px !important;padding-bottom:3px !important">
              <!--[if mso]>
                <v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="http://127.0.0.1:3000/adminteam/my/conversations/holy-fuck#message-53" style="height:20px;v-text-anchor:middle;" arcsize="10%" strokecolor="#cccccc" fillcolor="#fcfcfc">
                <w:anchorlock/>
                <center>
              <![endif]-->
              <a target="_blank" class="threadable-button view-button" href="http://127.0.0.1:3000/adminteam/my/conversations/holy-fuck#message-53" style="color:#364041 !important;background:#fcfcfc !important;-o-border-radius:3px !important;border-radius:3px !important;display:inline-block !important;font-family:sans-serif !important;text-align:center !important;text-decoration:none !important;-ms-border-radius:3px !important;-webkit-text-size-adjust:none !important;-webkit-font-smoothing:antialiased !important;font-size:11px !important;font-weight:300 !important;line-height:22px !important;border:#cccccc 1px solid !important;-moz-border-radius:3px !important;-webkit-border-radius:3px !important;width:100% !important">&nbsp;Web view&nbsp;</a>
              <!--[if mso]>
                </center>
                </v:roundrect>
              <![endif]-->
            </td>
            <td class="threadable-button" valign="bottom" style="padding-top:3px !important;padding-right:5px !important;padding-bottom:3px !important">
              <!--[if mso]>
                <v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="http://127.0.0.1:3000/ea/kaM2Np22iayxpfKUJmeS5POYEsF-3aZuLl-FNWsBT6Mr4YxiJLRRkhvDKJNeYf1p7Q==" style="height:20px;v-text-anchor:middle;" arcsize="10%" strokecolor="#cccccc" fillcolor="#fcfcfc">
                <w:anchorlock/>
                <center>
              <![endif]-->
              <a target="_blank" class="mute-button threadable-button" href="http://127.0.0.1:3000/ea/kaM2Np22iayxpfKUJmeS5POYEsF-3aZuLl-FNWsBT6Mr4YxiJLRRkhvDKJNeYf1p7Q==" style="color:#2980b9 !important;background:#fcfcfc !important;-o-border-radius:3px !important;border-radius:3px !important;display:inline-block !important;font-family:sans-serif !important;text-align:center !important;text-decoration:none !important;-ms-border-radius:3px !important;-webkit-text-size-adjust:none !important;-webkit-font-smoothing:antialiased !important;font-size:11px !important;font-weight:300 !important;line-height:22px !important;border:#cccccc 1px solid !important;-moz-border-radius:3px !important;-webkit-border-radius:3px !important;width:100% !important">&nbsp;Mute&nbsp;</a>
              <!--[if mso]>
                </center>
                </v:roundrect>
              <![endif]-->
            </td>
            <td></td>
            <td></td>
          </tr></tbody></table>
<table align="left" border="0" cellpadding="0" cellspacing="0" class="threadable-button-table" style="margin:0 !important"><tbody><tr>
<td>
              <table border="0" cellpadding="0" cellspacing="3" class="threadable-group-indicator ungrouped" style="font-size:11px !important;-webkit-border-radius:3px !important;-moz-border-radius:3px !important;border-radius:3px !important;-o-border-radius:3px !important;-ms-border-radius:3px !important;font-weight:normal !important;color:#5a6a6c !important;background-color: #ecf0f1 !important;">
<tbody><tr>
<td class="threadable-button" valign="bottom" style="padding-top:3px !important;padding:0 !important;padding-bottom:0 !important;padding-right:2px !important">
                    <!--[if mso]>
                      <v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="mailto:Other%20Admins%20%3Cadminteam@127.0.0.1%3E" style="height:20px;v-text-anchor:middle;" arcsize="10%" strokecolor="#cccccc" fillcolor="#fcfcfc">
                      <w:anchorlock/>
                      <center>
                    <![endif]-->
                    <a target="_blank" class="compose-button threadable-button" href="mailto:Other%20Admins%20%3Cadminteam@127.0.0.1%3E" style="color:#364041 !important;text-decoration:none !important;-ms-border-radius:3px !important;-o-border-radius:3px !important;border-radius:3px !important;display:inline-block !important;font-family:sans-serif !important;text-align:center !important;-moz-border-radius:3px !important;-webkit-border-radius:3px !important;-webkit-text-size-adjust:none !important;-webkit-font-smoothing:antialiased !important;font-size:11px !important;font-weight:300 !important;line-height:22px !important;width:100% !important;background:#fcfcfc !important;border:#cccccc 1px solid !important">&nbsp;New conversation&nbsp;</a>
                    <!--[if mso]>
                      </center>
                      </v:roundrect>
                    <![endif]-->
                  </td>
                  <td class="threadable-button" valign="bottom" style="padding-top:3px !important;padding:0 !important;padding-bottom:0 !important;padding-right:2px !important">
                    <!--[if mso]>
                      <v:roundrect xmlns:v="urn:schemas-microsoft-com:vml" xmlns:w="urn:schemas-microsoft-com:office:word" href="mailto:Other%20Admins%20Tasks%20%3Cadminteam+task@127.0.0.1%3E" style="height:20px;v-text-anchor:middle;" arcsize="10%" strokecolor="#cccccc" fillcolor="#fcfcfc">
                      <w:anchorlock/>
                      <center>
                    <![endif]-->
                    <a target="_blank" class="compose-button threadable-button" href="mailto:Other%20Admins%20Tasks%20%3Cadminteam+task@127.0.0.1%3E" style="color:#364041 !important;text-decoration:none !important;-ms-border-radius:3px !important;-o-border-radius:3px !important;border-radius:3px !important;display:inline-block !important;font-family:sans-serif !important;text-align:center !important;-moz-border-radius:3px !important;-webkit-border-radius:3px !important;-webkit-text-size-adjust:none !important;-webkit-font-smoothing:antialiased !important;font-size:11px !important;font-weight:300 !important;line-height:22px !important;width:100% !important;background:#fcfcfc !important;border:#cccccc 1px solid !important">&nbsp;New task&nbsp;</a>
                    <!--[if mso]>
                      </center>
                      </v:roundrect>
                    <![endif]-->
                  </td>
                </tr>
<tr>
<td class="group-name" colspan="2" style="padding-left:1px !important">
                    Ungrouped
                  </td>
                </tr>
</tbody></table>
</td>
          </tr></tbody></table>
</td>
    </tr></tbody></table>
<div style="display:none; display:none !important; clear: both">
    ##CovMid: PDUzMDE0YTVmOWU2YWVfZTJjODRkNGY1MjQ1MDNkNEAxMjcuMC4wLjE- ##
  </div>
<img alt="" height="1px" src="https://s3.amazonaws.com/multify-production/superable-specialable-threadable-dividerable-headerable.png" width="1px">
</div>
<br><p>Foop de doop</p>
<br><div class="threadable-content" style="margin-top:0.5em !important;font-family:Helvetica Neue, Helvetica, Arial, sans-serif !important">
<img alt="" height="1px" src="https://s3.amazonaws.com/multify-production/superable-specialable-threadable-dividerable-footerable.png" width="1px"><div style="display:none; display:none !important;">
    ##CovMid: footer ##
  </div>
  <table align="left" border="0" cellpadding="0" cellspacing="0" class="threadable-details" width="100%"><tbody><tr>
<td class="threadable-details-inner" style="color: #95A5A6; text-align: left;">
        <div class="threadable-organization" style="font-family: Helvetica Neue, Helvetica, Arial, sans-serif;font-size: 12px">
          <a target="_blank" href="http://127.0.0.1:3000/adminteam" style="text-decoration:none !important;color:#3498db !important">Other Admins</a>
          |
          <a target="_blank" href="mailto:adminteam@127.0.0.1" style="text-decoration:none !important;color:#3498db !important">adminteam@127.0.0.1</a>
        </div>
        <div class="threadable-unsubscribe" style="font-family: Helvetica Neue, Helvetica, Arial, sans-serif;font-size: 10px">
          <a target="_blank" href="http://127.0.0.1:3000/adminteam/unsubscribe/kaM2Np22r72xpcaeOWGa5tuBB9x43JxUK0meUSJkeIwSjLELJtl2tiioGKFgYK9v0D4=" style="text-decoration:none !important;color:#3498db !important">unsubscribe</a> | <a target="_blank" href="mailto:support@127.0.0.1" style="text-decoration:none !important;color:#3498db !important">feedback</a>
        </div>
      </td>
    </tr></tbody></table>
<div style="display:none; display:none !important">
    ##CovMid: footer ##
  </div>
<img alt="" height="1px" src="https://s3.amazonaws.com/multify-production/superable-specialable-threadable-dividerable-footerable.png" width="1px">
</div>


</body>
BODY
    end

    let :stripped_body do
<<-BODY
<body>
<div class="threadable-content" style="margin-top:0.5em !important;font-family:Helvetica Neue, Helvetica, Arial, sans-serif !important">

</div>
<br><p>Foop de doop</p>
<br><div class="threadable-content" style="margin-top:0.5em !important;font-family:Helvetica Neue, Helvetica, Arial, sans-serif !important">

</div>


</body>
BODY
    end

    it "should strip the threadable content" do
      expect(call(body)).to eq stripped_body
    end
  end
end
