require 'rubygems'
gem 'stomp'
require 'stomp'
gem 'stomp_message'
require 'stomp_message'
# This sends the subscription request to a activemq topic
module SubscriptionManager
class SubscriptionSendTopic < StompMessage::StompSendTopic
  
  #need to define topic, host properly
  @@TOPIC='subscription'
  # must be defined as method in sms_listener
  @@STOMP_SUB_MESSAGE='stomp_SUBSCRIPTION'
 def initialize(options={})
   # set up variables using hash
    options[:topic] =   options[:topic]==nil ? @@TOPIC : options[:topic]
   
    super(options)
    
    #puts "#{self.class}: finished initializing"
  end

  def create_subscription_message(arg_hash)
	   m=SubscriptionManager::Message.new(@@STOMP_SUB_MESSAGE)
	    m.service_id=arg_hash[:keyword]
      msisdn=arg_hash[:msisdn]
       m.action=arg_hash[:action]
       m.broadcast=arg_hash[:broadcast]
      
       m.msisdns << msisdn
       m
  end
  def send_subscription_response(args)
      msg_received_flag=result=false
      m=create_subscription_message(args)
      header={}
      timeout=75
      result=self.send_topic_ack(m,args,timeout-1) 
      result
  end
  def send_subscription(args)
         m=create_subscription_message(args)
         puts "message is #{m.to_xml}"
         headers = {}
         send_topic(m, headers)     
  end #send subscriptiion
  def send_subscription_receipt(args, &r_block)
          m=create_subscription_message(args)
          headers = {}
         send_topic(m, headers, &r_block)     
  end #send_sms
 
end # smsc listener

end #module
