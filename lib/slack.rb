class Slack

  @@endpoint = nil
  @@defaults = {}

  def self.configure endpoint, defaults={}
    @@endpoint = endpoint
    @@defaults = defaults
  end

  def self.send opts={}
    if !opts.is_a?(Hash)
      opts = {text: opts}
    end
    opts = @@defaults.merge(opts)
    self.post opts
  end


  def self.post msg
    uri = URI::parse('https://hooks.slack.com')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new @@endpoint, {'Content-type' => 'application/json'}
    req.body = msg.to_json
    res = http.request(req)
    return res.body
  end

end