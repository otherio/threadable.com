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
    make_request{ collection.get(params: params) }
  end

  def create data={}
    make_request{ collection.post(singular_name => data) }
  end

  def read id, params={}
    make_request{ member(id).get(params: params) }
  end

  def update id, data={}
    make_request{ member(id).put(singular_name => data) }
  end

  def delete id
    make_request{ member(id).delete }
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
    p response
  end

  def deserialize json
    JSON.parse(json)
  end

end
