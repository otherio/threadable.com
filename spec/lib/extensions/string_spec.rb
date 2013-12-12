# encoding: UTF-8
require 'spec_helper'

describe String, fixtures: false, transaction: false do

  describe "strip_non_ascii" do
    from = %[Hey, Look at these: ➜⟹☞⇏⊈♥☃★✔♩♪♫♬☆♗☗✜✐☹ aren't they cool?]
    to   = %[Hey, Look at these:  aren't they cool?]
    it "#{from.inspect}.strip_non_ascii should eq #{to.inspect}" do
      expect(from.strip_non_ascii).to eq to
    end
  end

end
