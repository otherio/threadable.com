FactoryGirl.define do
  factory :email, class: OpenStruct do
    to { /(.*)@/.match(Faker::Internet.email)[1] }
    from { Faker::Internet.email }
    subject { Faker::Company.catch_phrase }
    body { Faker::HipsterIpsum.paragraph }
    params { {headers: nil} }
    attachments {[]}

    trait :with_attachment do
      attachments {[
        ActionDispatch::Http::UploadedFile.new({
          filename: 'img.png',
          type: 'image/png',
          tempfile: File.new("#{File.expand_path File.dirname(__FILE__)}/fixtures/img.png")
        })
      ]}
    end
  end
end
