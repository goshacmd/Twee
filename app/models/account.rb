class Account
  attr_accessor :ac_account

  def self.find(id)
    new(Twitter.find(id)) if id
  end

  def initialize(ac_account)
    @ac_account = ac_account
  end

  def id
    ac_account.identifier
  end

  def username
    ac_account.username
  end

  def home_timeline(options = {}, &block)
    request("http://api.twitter.com/1/statuses/home_timeline.json", options, :get, block)
  end

  def post(text, &block)
    request("http://api.twitter.com/1/statuses/update.json", { status: text }, :post, block)
  end

  def request(url, params, method, block)
    url = NSURL.URLWithString(url)
    method = method == :post ? TWRequestMethodPOST : TWRequestMethodGET
    req = TWRequest.alloc.initWithURL(url, parameters:params, requestMethod:method)
    req.account = ac_account
    req.performRequestWithHandler ->(data, url_response, error){
      data = BW::JSON.parse(data) if data

      if data && data.respond_to?(:has_key?) && data.has_key?('errors')
        error = NSError.errorWithDomain('twee.error', code:1, userInfo:data)
      end

      if error
        block.call(nil, error)
      else
        block.call(data, nil)
      end
    }
  end
end
