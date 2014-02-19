require 'spec_helper'

describe CorrectHtml do

  delegate :call, to: :described_class

  let :body do
<<-BODY
<div>
  I am a thing.
</div></div>
BODY
  end

  let :stripped_body do
<<-BODY
<div>
  I am a thing.
</div>
BODY
  end

  it "should remove the extra tag" do
    expect(call(body).strip).to eq stripped_body.strip
  end
end
