require 'spec_helper'

describe UnsubscribeTokenFilterer do

  def self.texts
    [
      [
      # ------------------------------------------------------------------------
<<-BEFORE,
BEFORE
      # ------------------------------------------------------------------------
<<-AFTER
AFTER
      # ------------------------------------------------------------------------
      ],

      # ========================================================================

      [
      # ------------------------------------------------------------------------
<<-BEFORE,
<div><br></div><div><br></div></div>


<pre>_____
View on Covered: <a href=3D"http://beta.covered.io/covered/conversations/=
show-dont-tell" target=3D"_blank">http://beta.covered.io/covered/conversa=
tions/show-dont-tell</a>
Unsubscribe:  <a href=3D"http://beta.covered.io/covered/unsubscribe" targ=
et=3D"_blank">http://beta.covered.io/covered/unsubscribe/jqxMBUz0fz_8Majl=
KaPbf9E=</a>
</pre>

</blockquote></div><br></div>
BEFORE
      # ------------------------------------------------------------------------
<<-AFTER
<div><br></div><div><br></div></div>


<pre>_____
View on Covered: <a href=3D"http://beta.covered.io/covered/conversations/=
show-dont-tell" target=3D"_blank">http://beta.covered.io/covered/conversa=
tions/show-dont-tell</a>
Unsubscribe:  <a href=3D"http://beta.covered.io/covered/unsubscribe" targ=
et=3D"_blank">http://beta.covered.io/covered/unsubscribe=
</a>
</pre>

</blockquote></div><br></div>
AFTER
      # ------------------------------------------------------------------------
      ],

      # ========================================================================

      [
      # ------------------------------------------------------------------------
<<-BEFORE,
"Sorry I sent that blank mail. Shouldn't be possible in the future. derp.


On Sun, Apr 21, 2013 at 5:58 PM, Ian Baker <ian@sonic.net> wrote:

> This is a response!
>
> So there!
>
> On Sunday, April 21, 2013, Nicole Aptekar wrote:
>
> > Another test. Mail back plz?
> > _____
> > View on Covered:
> > http://beta.covered.io/covered-testing/conversations/testing
> > Unsubscribe:
> >
> http://beta.covered.io/covered-testing/unsubscribe
> >
> >
> _____
> View on Covered:
> http://beta.covered.io/covered-testing/conversations/testing
> Unsubscribe:
> http://beta.covered.io/covered-testing/unsubscribe/jqxMBUz0fz_8MajlKaPbf9E=
>
BEFORE
      # ------------------------------------------------------------------------
<<-AFTER
"Sorry I sent that blank mail. Shouldn't be possible in the future. derp.


On Sun, Apr 21, 2013 at 5:58 PM, Ian Baker <ian@sonic.net> wrote:

> This is a response!
>
> So there!
>
> On Sunday, April 21, 2013, Nicole Aptekar wrote:
>
> > Another test. Mail back plz?
> > _____
> > View on Covered:
> > http://beta.covered.io/covered-testing/conversations/testing
> > Unsubscribe:
> >
> http://beta.covered.io/covered-testing/unsubscribe
> >
> >
> _____
> View on Covered:
> http://beta.covered.io/covered-testing/conversations/testing
> Unsubscribe:
> http://beta.covered.io/covered-testing/unsubscribe
>
AFTER
      # ------------------------------------------------------------------------
      ]

    ]
  end

  texts.each_with_index do |(before, expected_after), index|
    it "should should be able to strip the unsubscribe token from example #{index}" do
      after = UnsubscribeTokenFilterer.call(before)
      expect(after).to eq expected_after
    end
  end

end
