require 'spec_helper'

describe 'EmailProcessor::UnsubscribeTokenFilterer' do

  context "when given plain text" do

   let :input do
<<-TEXT
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
> > View on Multify:
> > http://beta.multifyapp.com/multify-testing/conversations/testing
> > Unsubscribe:
> >
> http://beta.multifyapp.com/multify-testing/unsubscribe/jrFFF0z_f2O7M6K6eqPdf94=
> >
> >
> _____
> View on Multify:
> http://beta.multifyapp.com/multify-testing/conversations/testing
> Unsubscribe:
> http://beta.multifyapp.com/multify-testing/unsubscribe/jrFFF0qqfzWrYOzqJ6Pdf90=
>
TEXT
   end

   let :expected_output do
<<-TEXT
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
> > View on Multify:
> > http://beta.multifyapp.com/multify-testing/conversations/testing
> > Unsubscribe:
> >
> http://beta.multifyapp.com/multify-testing/unsubscribe
> >
> >
> _____
> View on Multify:
> http://beta.multifyapp.com/multify-testing/conversations/testing
> Unsubscribe:
> http://beta.multifyapp.com/multify-testing/unsubscribe
>
TEXT
   end

    it "should filter the unsubscribe tokens out of any unsibscribe links found in the given text" do
      expect(EmailProcessor::UnsubscribeTokenFilterer.call(input)).to eq(expected_output)
    end
  end

  context "when given html" do

    let :input do
<<-HTML
HTML
    end

    let :expected_output do
<<-HTML
HTML
    end

    pending "should filter the unsubscribe tokens out of any unsibscribe links found in the given text" do
      expect(EmailProcessor::UnsubscribeTokenFilterer.call(input)).to eq(expected_output)
    end
  end

end
