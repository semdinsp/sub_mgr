require 'net/http'
require 'yaml'
module SubscriptionManager #:nodoc:
  class Control #:nodoc:
      def self.path_to_config
        File.join(File.dirname(__FILE__), '../../config/submgr.yml')
      end
      attr_accessor :urlbase
      def dump
        #change this in database or here
        test_path=SubscriptionManager::Control.path_to_config
     #   puts "Path to config file is: #{test_path}"
        config = File.open(test_path,'w') { |f| YAML.dump(self,f) }
      end
     def self.load_url
       #change this in database or here
       test_path=self.path_to_config
      # puts "Path to config file is: #{test_path}"
       config = File.open(test_path) { |f| YAML.load(f) }
      #puts "config is: #{config} config.class is: #{config.class}"
      if config.class==SubscriptionManager::Control
        subMgr=config
      else
      # puts "hostname is: #{config['hostname']}"
       subMgr=SubscriptionManager::Control.new
       subMgr.urlbase=config["urlbase"]
     end
       subMgr
     end
   # @urlbase = 'http://localhost:3000/subscription'
   def self.web_service_execute(url,msisdn,keyword)
        puts "url is #{url} msisdn: #{msisdn} keyword: #{keyword}"
        res = Net::HTTP.post_form(URI.parse(url), { :msisdn => msisdn, :keyword => keyword }) 
        puts "res.code is #{res.code} comparison #{res.code=='200'}"
        res.code == '200'   #true if success
   end
    def  self.create(msisdn,keyword)
       url = SubscriptionManager::Control.load_url.urlbase + '/new_subscription'
       SubscriptionManager::Control.web_service_execute(url,msisdn,keyword)
       
     end
     def  self.check_status(msisdn,keyword)
       url = SubscriptionManager::Control.load_url.urlbase + '/check_status'
       SubscriptionManager::Control.web_service_execute(url,msisdn,keyword)
      end
   def  self.delete(msisdn,keyword)
       url = SubscriptionManager::Control.load_url.urlbase + '/delete_subscription'
     SubscriptionManager::Control.web_service_execute(url,msisdn,keyword)
   end
  end
end
