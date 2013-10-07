module ForwardGetRequestsAsPostsConcern
  extend ActiveSupport::Concern

  def forward_get_requests_as_posts!
    return unless request.get?
    forwarded_params = params
    forwarded_params.delete(:action)
    forwarded_params.delete(:controller)
    forwarded_params[:authenticity_token] = form_authenticity_token

    view_options = ViewOption.new(request.url, :post, forwarded_params)
    html = Haml::Engine.new(HAML).render(view_options)
    render text: html
  end

  ViewOption = Struct.new(:action, :method, :params)

  HAML = <<-HAML
%form{action:action, method:method, id:'auto_post'}
  - params.each do |name, value|
    %input{type:'hidden', name:name, value:value}
:javascript
  auto_post.submit();
HAML

end
