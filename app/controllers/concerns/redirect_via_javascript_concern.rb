module RedirectViaJavascriptConcern

  extend ActiveSupport::Concern

  def redirect_via_javascript_to location
    render text: <<-HTML
      <script> debugger; document.location = #{location.to_json} </script>
    HTML
  end

end
