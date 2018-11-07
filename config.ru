require 'puma'
require 'rack'
require 'json'
require 'digest/md5'

app = lambda do |env|
  req = Rack::Request.new(env)
  body = {}

  if req.post?
    begin
      params = JSON.parse(req.body.read)
      body = {
        id: params['id'],
        first_name: params['first_name'] + Digest::MD5.hexdigest(params['first_name']),
        last_name: params['last_name'] + Digest::MD5.hexdigest(params['last_name']),
        current_time: Time.now.utc.strftime('%F %T %z'),
        say: 'Ruby is the best'
      }
    rescue JSON::ParserError => e
      body = {
        error: 'JSON Parser Error'
      }
    end
  else
    body = {
      error: 'Only POST request required'
    }
  end

  response_headers = {}
  response_headers["Content-Type"] = "application/json"
  [200, response_headers, [JSON.generate(body)]]
end

run app
