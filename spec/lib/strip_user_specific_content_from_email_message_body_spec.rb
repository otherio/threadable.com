require 'spec_helper'

describe StripUserSpecificContentFromEmailMessageBody do

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

<a href="mailto:warehome@covered.io" style="color:#3498db;text-decoration:none!important;background-color:#16a085;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">New conversation</a>

</div>
</td>
<td>
<div>

<a href="mailto:warehome@covered.io?subject=%E2%9C%94+" style="color:#3498db;text-decoration:none!important;background-color:#16a085;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">New task</a>

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

<a href="http://beta.covered.io/warehome/conversations/clean-up-the-entryway#message-334" style="color:#3498db;text-decoration:none!important;background-color:#7f8c8d;border-radius:3px;color:#ffffff;display:inline-block;font-family:sans-serif;font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:11px;line-height:25px;text-align:center;text-decoration:none;width:115px" target="_blank">View on Covered</a>

</div>
</td>
</tr></tbody></table>
<table align="right" border="0" cellpadding="2" cellspacing="0" width="357"><tbody><tr>
<td style="color:#95a5a6;text-align:right">
<div style="font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:12px">
<a href="http://beta.covered.io/warehome" style="color:#3498db;text-decoration:none!important" target="_blank">Warehome</a>
|
<a href="mailto:warehome@covered.io" style="color:#3498db;text-decoration:none!important" target="_blank">warehome@covered.io</a>
</div>
<div style="font-family:Helvetica Neue,Helvetica,Arial,sans-serif;font-size:10px">
sent to <a href="mailto:nicoletbn@gmail.com" target="_blank">nicoletbn@gmail.com</a> | mute conversation | <a href="http://beta.covered.io/warehome/unsubscribe/59Vza2e6Xk_6NvDpad-DFtjZzXTvqJ9jDO4-7ujje3rVJ5Zrt6srB91D-2VnXrwXQki1VywguAcuO69QnSzNMWT_" style="color:#3498db;text-decoration:none!important" target="_blank">unsubscribe</a>
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

  it "should strip unsubscribe tokens and covered controls" do
    expect(call(body)).to eq stripped_body
  end

end
