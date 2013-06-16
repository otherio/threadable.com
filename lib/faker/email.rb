module Faker::Email

  def self.html_body
<<-HTML
<p>Hey #{Faker::Name.name},</p>

#{Faker::HTMLIpsum.body}

<p>Thanks!</p>
<p>--</p>
<p>#{Faker::Name.name}</p>
<p>#{Faker::Job.title}</p>
HTML
  end

  def self.plain_body
<<-TEXT
Hey #{Faker::Name.name},

#{Faker::Lorem.paragraphs(3).join("\n\n")}

Thanks!
--
#{Faker::Name.name}
#{Faker::Job.title}
TEXT
  end

end
