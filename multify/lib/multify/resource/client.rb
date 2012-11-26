class Multify::Resource::Client

  def initialize url
    @url = url.to_s
    @plural_name = @url.split('/').last
    @singular_name = plural_name[0..-2]
    @collection = RestClient::Resource.new(@url, :headers => {:accept => :json})
  end

  attr_reader :plural_name, :singular_name, :collection, :member

  def member id
    collection[id]
  end

  def find params={}
    make_request do
      collection.get(
        params: default_params.merge(params)
      )
    end
  end

  def create data={}
    make_request do
      collection.post(
        default_params.merge(singular_name => data)
      )
    end
  end

  def read id, params={}
    make_request do
      member(id).get(
        params: default_params.merge(params)
      )
    end
  end

  def update id, data={}
    make_request do
      member(id).put(
        default_params.merge(singular_name => data)
      )
    end
  end

  def delete id
    make_request do
      member(id).delete(
        params: default_params
      )
    end
  end

  def make_request
    response = yield
    response = deserialize(response) unless response.empty?
    [true, response]
  rescue RestClient::RequestFailed => e
    response = e.response
    errors = deserialize(response)["errors"] || []
    [false, errors]
  rescue RestClient::ResourceNotFound
    [false, nil]
  ensure
    # p "API RESPONSE: #{response}"
  end

  def deserialize json
    JSON.parse(json)
  end

  def default_params
    {:authentication_token => Multify.authentication_token}
  end

end
