require 'net/http'

class WrttnIn
  attr_reader :public_url, :content

  def self.create(content, markup = :markdown)
    post_data = {
      :content => content,
      :parser => markup
    }
    response = Net::HTTP.post_form(URI.parse('http://wrttn.in/create'), post_data)
    if response.kind_of?(Net::HTTPRedirection)
      response_body = Net::HTTP.get(URI.join('http://wrttn.in', response['Location']))
      if id = response_body.match(/<a href="\/(.*)" class="lab" target="_blank">public url<\/a>/)[1]
        self.new(id, content)
      else
        raise "Couldn't parse the response"
      end
    else
      raise "Couldn't create a post"
    end
  end

  def initialize(id, content)
    @public_url = "http://wrttn.in/#{id}"
    @content = content
  end
end
