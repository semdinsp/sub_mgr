require 'rexml/document'
# Sms stuff for handling sms
require 'rubygems'
gem 'stomp_message'
require 'stomp_message'
module SubscriptionManager 
  class Message < StompMessage::Message
   # include StompMessage::XmlHelper
    attr_accessor :msisdns, :service_id, :broadcast
    attr_reader :action
    def initialize(cmd)
      
      self.msisdns=[]
     # self.command=cmd
      super(cmd)
    end
    # actions must be recognized in subscribe server so check to see if valid
    def action=(val)
      valid_actions=%w(action_subscribe action_get_subscriptions action_unsubscribe           action_status action_process_subscriptions action_broadcast_sms action_broadcast_text_mms  action_broadcast_mms action_status)
     # puts "val is #{val} index is #{valid_actions.index(val)}"
      raise 'invalid action'  if valid_actions.index(val)==nil
      @action=val    
    end

     def self.load_xml(xml_string)
       doc=REXML::Document.new(xml_string)
     #  puts "in load xml #{xml_string}"
       action=REXML::XPath.first(doc, "//action").text if REXML::XPath.first(doc, "//action") != nil
       svc_id=REXML::XPath.first(doc, "//service_id").text if REXML::XPath.first(doc, "//service_id") !=nil
        broadcast=REXML::XPath.first(doc, "//broadcast").text if REXML::XPath.first(doc, "//broadcast") !=nil
       command = REXML::XPath.first(doc, "//__stomp_msg_command").text
       new_msg = SubscriptionManager::Message.new(command)
       new_msg.action=action
       new_msg.service_id=svc_id
       new_msg.broadcast=broadcast
       REXML::XPath.each( doc, "//msisdn") { |element| new_msg.msisdns << element.text
                                          #   puts "msisdn text #{element.text}" 
                                             }
        new_msg
     # deal with msisdns  text=REXML::XPath.first(doc, "//text").text
      # sms=SmscManager::Sms.new(text,dest,src)
     end
      
  end
end
