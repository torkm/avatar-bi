# require "faraday"
# require "json"

module Odpt
  class TrainAPI
    BASE_URL = "https://api-tokyochallenge.odpt.org/api/v4/odpt:"
    CONSUMER_KEY = "25a4a87678a6bd930c91bf66fff22bea5204a90c6ed59605e9ccc65cfb7c0fb3"

    def self.make_get_request(path, params)
      url = BASE_URL + path
      conn = Faraday.new(url)
      res = conn.get do |req|
        req.params["acl:consumerKey"] = CONSUMER_KEY
        params.each do |key, value|
          req.params[key] = value
        end
      end
      return JSON.parse(res.body)
    end
  end
end

#https://api-tokyochallenge.odpt.org/api/v4/odpt: がベース　BASE_URL
# + "Station?"   最初の種類 pathで定義
# + "acl:consumerKey=XXXX"  apiキー CONSUMER_KEYで定義
# +  "&odpt:operator=odpt.Operator:JR-East"  operator
#    →paramsでハッシュとしてparams[key]=valueとして定義 何個でも
