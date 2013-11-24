require 'spec_helper'

describe "processing incoming emails" do

  before do
    as 'yan@ucsd.covered.io' do
      @yan = current_user
      @project = current_user.projects.find_by_slug! 'raceteam'
      @conversation = @project.conversations.find_by_slug! 'how-are-we-going-to-build-the-body'
      @parent_message = @conversation.messages.latest

      @params = {
        "recipient"                   => "#{@project.email_address}",
        "sender"                      => "#{current_user.email_address}",
        "subject"                     => "RE: How are we going to build the body?",
        "from"                        => "#{current_user.formatted_email_address}",
        "Received"                    => "by 10.112.85.171 with HTTP; Fri, 15 Nov 2013 15:44:13 -0800 (PST)",
        "X-Envelope-From"             => "<#{current_user.email_address}>",
        "Dkim-Signature"              => "v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20120113; h=mime-version:sender:in-reply-to:references:from:date:message-id :subject:to:content-type; bh=VK1q8ovqkoJ6eUQw7/1hRs7UUylVr6pzXsrQyR2Zp58=; b=HvclVaydPFQOlKE5LsuKafPHLGmpIIquOP+5db2uRLXjcA5kG2omJ/QA9EIIagwje5 Mgnu5HasLlW77/dI4a16P47zArMD/Dyd47RLYkgc/34ZmZKrc2P7PFRgi1M+DOxsCB7f ptKLq1GmCZGMg5AtPsNX/Bt2hPUlv7PO/tkxu/i1Vfw3VVeSO4ONiJ4XOkGC8nQ55gAu 5fqXXAwcQYSd9+tBAj+aV0gzH8IfgQdv26Hiu5wAQp30SgznjsuW9qlfxTivXw19Lsf0 brv0oI69KnNXxr/51AZF1pWnMNmkmwwiHip1N1J2M+bdSQm64Muc6m8JwAOXeF9r3EyX WlWA==",
        "X-Received"                  => "by 10.152.8.228 with SMTP id u4mr83886laa.79.1384559073936; Fri, 15 Nov 2013 15:44:33 -0800 (PST)",
        "Mime-Version"                => "1.0",
        "Sender"                      => "#{current_user.email_address}",
        "In-Reply-To"                 => "#{@parent_message.message_id_header}",
        "References"                  => "#{@parent_message.message_id_header}",
        "From"                        => "#{current_user.formatted_email_address}",
        "Date"                        => "Fri, 15 Nov 2013 15:44:13 -0800",
        "X-Google-Sender-Auth"        => "YFR0vqRjQkiZTwE-B9OeVI4DBqg",
        "Message-Id"                  => "<CALO0tS3hzRSPSgyeBV=L9vixzVbvsRpAU+5_prieRGMVDCjQsQ@mail.gmail.com>",
        "Subject"                     => "RE: How are we going to build the body?",
        "To"                          => "Covered Internal <covered@covered.io>",
        "Content-Type"                => "multipart/alternative; boundary=\"089e0158ba9ec5cbb704eb3fc74e\"",
        "X-Mailgun-Incoming"          => "Yes",
        "X-Mailgun-Sflag"             => "No",
        "X-Mailgun-Sscore"            => "-0.7",
        "X-Mailgun-Spf"               => "Pass",
        "X-Mailgun-Dkim-Check-Result" => "Pass",
        "message-headers"             => [
          ["Received",                    "by luna.mailgun.net with SMTP mgrt 4814637; Fri, 15 Nov 2013 23:44:39 +0000"],
          ["X-Envelope-From",             "<#{current_user.email_address}>"],
          ["Received",                    "from mail-la0-f47.google.com (mail-la0-f47.google.com [209.85.215.47]) by mxa.mailgun.org with ESMTP id 5286b1e4.41760f0-in3; Fri, 15 Nov 2013 23:44:36 -0000 (UTC)"],
          ["Received",                    "by mail-la0-f47.google.com with SMTP id ep20so3212151lab.6 for <covered@covered.io>; Fri, 15 Nov 2013 15:44:34 -0800 (PST)"],
          ["Dkim-Signature",              "v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20120113; h=mime-version:sender:in-reply-to:references:from:date:message-id :subject:to:content-type; bh=VK1q8ovqkoJ6eUQw7/1hRs7UUylVr6pzXsrQyR2Zp58=; b=HvclVaydPFQOlKE5LsuKafPHLGmpIIquOP+5db2uRLXjcA5kG2omJ/QA9EIIagwje5 Mgnu5HasLlW77/dI4a16P47zArMD/Dyd47RLYkgc/34ZmZKrc2P7PFRgi1M+DOxsCB7f ptKLq1GmCZGMg5AtPsNX/Bt2hPUlv7PO/tkxu/i1Vfw3VVeSO4ONiJ4XOkGC8nQ55gAu 5fqXXAwcQYSd9+tBAj+aV0gzH8IfgQdv26Hiu5wAQp30SgznjsuW9qlfxTivXw19Lsf0 brv0oI69KnNXxr/51AZF1pWnMNmkmwwiHip1N1J2M+bdSQm64Muc6m8JwAOXeF9r3EyX WlWA=="],
          ["X-Received",                  "by 10.152.8.228 with SMTP id u4mr83886laa.79.1384559073936; Fri, 15 Nov 2013 15:44:33 -0800 (PST)"],
          ["Mime-Version",                "1.0"],
          ["Sender",                      "#{current_user.email_address}"],
          ["Received",                    "by 10.112.85.171 with HTTP; Fri, 15 Nov 2013 15:44:13 -0800 (PST)"],
          ["In-Reply-To",                 "#{@parent_message.message_id_header}"],
          ["References",                  "#{@parent_message.message_id_header}"],
          ["From",                        "#{current_user.formatted_email_address}"],
          ["Date",                        "Fri, 15 Nov 2013 15:44:13 -0800"],
          ["X-Google-Sender-Auth",        "YFR0vqRjQkiZTwE-B9OeVI4DBqg"],
          ["Message-Id",                  "<CALO0tS3hzRSPSgyeBV=L9vixzVbvsRpAU+5_prieRGMVDCjQsQ@mail.gmail.com>"],
          ["Subject",                     "RE: How are we going to build the body?"],
          ["To",                          "#{@project.formatted_email_address}"],
          ["Content-Type",                "multipart/alternative; boundary=\"089e0158ba9ec5cbb704eb3fc74e\""],
          ["X-Mailgun-Incoming",          "Yes"],
          ["X-Mailgun-Sflag",             "No"],
          ["X-Mailgun-Sscore",            "-0.7"],
          ["X-Mailgun-Spf",               "Pass"],
          ["X-Mailgun-Dkim-Check-Result", "Pass"],
        ].to_json,
        "timestamp"          => "1384559079",
        "token"              => "216x-dux-bo6gnavvgfpl9rsjghmskj1pani296qok2qi067g0",
        "signature"          => "d14fc4a8da06e04e4dcdd619163238f32ed7154c326a9db010674d0622843b4f",
        "body-plain"         => (
          %(I think we should build it out of fiberglass and duck tape.\n\n)+
          %(> I'm not 100% clear on the right way to go for this, but we should figure out if we're going to )+
          %(> make the body out of carbon or buy a giant boat and cut it up or whatever.)
        ),
        "body-html"          => (
          %(<p>I think we should build it out of fiberglass and duck tape.\n</p>\n)+
          %(<blockquote>)+
          %(I'm not 100% clear on the right way to go for this, but we should figure out if we're going to )+
          %(make the body out of carbon or buy a giant boat and cut it up or whatever.)+
          %(</blockquote>)
        ),
        "stripped-html"      => (
          %(<p>I think we should build it out of fiberglass and duck tape.\n</p>)
        ),
        "stripped-text"      => (
          %(I think we should build it out of fiberglass and duck tape.)
        ),
        "stripped-signature" => "--\nYan",
      }

    end
  end

  it "simulating a mailgun post" do
    expect_any_instance_of(EmailsController).to receive(:authenticate).and_return(true)
    post emails_url, @params
    expect(response).to be_ok

    run_background_jobs!

    expect( @project.conversations.latest ).to eq @conversation
    @message = @conversation.messages.latest

    expect( @message.subject        ).to eq "RE: How are we going to build the body?"
    expect( @message.body           ).to eq "<p>I think we should build it out of fiberglass and duck tape.\n</p>\n<blockquote>I'm not 100% clear on the right way to go for this, but we should figure out if we're going to make the body out of carbon or buy a giant boat and cut it up or whatever.</blockquote>"
    expect( @message.stripped_body  ).to eq "<p>I think we should build it out of fiberglass and duck tape.\n</p>"
    expect( @message.root?          ).to be_false
    expect( @message.shareworthy?   ).to be_false
    expect( @message.knowledge?     ).to be_false
    expect( @message.parent_message ).to eq @parent_message
    expect( @message.conversation   ).to eq @conversation

  end

end
