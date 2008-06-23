require 'yaml'
require 'rubygems'
gem 'stomp'
require 'stomp'
gem 'stomp_message'
require 'stomp_message'
gem 'ficonab_tools'
require 'ficonab_tools'
require 'active_record'
require 'erb'
require 'base64'
module SubscriptionManager
class SubscriptionServer < StompMessage::StompZActiveRecordServer
  attr_accessor :my_conn_mgr
 
  def initialize(options={})
      self.model_list = []
     
      self.model_list << "keyword.rb"
      self.model_list << "subscription.rb"
      ver_num= self.version_number.to_s + '/'
       options[:root_path]=ENV['JRUBY_HOME']+'/lib/ruby/gems/1.8/gems/subscription_manager-'+ ver_num if RUBY_PLATFORM =~ /java/
    super(options)
     puts 'before connection manager'
      self.my_conn_mgr=FiconabTools::ConnectionManager.instance()
      self.my_conn_mgr.setup(['sms', 'mms'])
         puts 'after connection manager'
    #self.smsc=SmscManager::SmscConnection.factory
    #puts "#{self.class}: finished initializing"
  end
  # content is passed as base 64 data array of yaml
  def build_content(data)
      temp=Base64.decode64(data)
      temp_array=YAML.load(temp)
      puts "temp array size is #{temp_array.size}"
      content=[]
      0.upto(temp_array.size)   { |i| content << temp_array[i] if temp_array[i]!=nil}
      
      content
  end
  # build and send mms from content
  def action_broadcast_mms(msg)
      puts "in action_broadcast_sms keyword: #{msg.service_id} message #{msg.broadcast}"
      count=Keyword.subscription_count(msg.service_id)
      content=build_content(msg.broadcast)
      msisdn='63999'  #replace in broadcast
       mms=MmscManager::MmsMessage.new('999',
                          msisdn," #{msg.service_id}: broadcast #{Time.now}" ,content)
      b=Keyword.broadcast_mms_to_subscriptions(self.my_conn_mgr.my_connections['mms'], msg.service_id,'999',mms)
      msgtwo = "keyword: #{msg.service_id} subscription count: #{count} Attempted #{b.attempts} and sent #{b.sent} MMS messages "
   end
  def action_broadcast_text_mms(msg)
      puts "in action_broadcast_sms keyword: #{msg.service_id} message #{msg.broadcast}"
      count=Keyword.subscription_count(msg.service_id)
    b=Keyword.broadcast_text_mms_to_subscriptions(self.my_conn_mgr.my_connections['mms'], msg.service_id,'999',msg.broadcast,
          "#{msg.service_id}: broadcast #{Time.now}")
      msgtwo = "keyword: #{msg.service_id} subscription count: #{count} Attempted #{b.attempts} and sent #{b.sent} MMS messages "
   end
  def action_broadcast_sms(msg)
     puts "in action_broadcast_sms keyword: #{msg.service_id} message #{msg.broadcast}"
     count=Keyword.subscription_count(msg.service_id)
     b=Keyword.broadcast_to_subscriptions(self.my_conn_mgr.my_connections['sms'], msg.service_id,'999',msg.broadcast)
     msgtwo = "keyword: #{msg.service_id} subscription count: #{count} Attempted #{b.attempts} and sent #{b.sent} messages "
  end
  def action_subscribe(msg)
    puts "in action_subscribe keyword: #{msg.service_id} msisdn #{msg.msisdns[0]}"
      s=Subscription.new
      s.msisdn=msg.msisdns[0]
      flag = s.add_to_keyword(msg.service_id)
       k=Keyword.find_by_name(msg.service_id)
       if k!=nil
          send_sms(msg.msisdns[0],k.message_welcome)
        end
      flag = Keyword.check_status(msg.service_id,msg.msisdns[0])
  end
  def action_status(msg)
    puts "in action_status keyword: #{msg.service_id} msisdn #{msg.msisdns[0]}"
    flag = Keyword.check_status(msg.service_id,msg.msisdns[0])
    puts "flag is #{flag}"
    flag
  end
  def action_get_subscriptions(msg)
       puts "in action_get_subscriptions keyword: #{msg.service_id}"
       k=Keyword.find_by_name(msg.service_id)
       result=[]
       if k!=nil
           s=k.subscriptions 
          
           s.each {|sub| 
                    h= { :msisdn => sub.msisdn, :keyword_params => sub.keyword_params}
                    result << h
                     }
         end
      result.to_yaml
  end
  def send_sms(sub,msg)
     begin 
         sms=SmscManager::Sms.new(msg,sub,'999')

         self.my_conn_mgr.my_connections['sms'].send_topic_sms(sms)
       #  smsc.disconnect_stomp
     rescue Exception => e
        puts "exception found trying to send sms #{e} #{e.message}" 
     end
  end
  def action_unsubscribe(msg)
     puts "in action_unsubscribe keyword: #{msg.service_id} msisdn #{msg.msisdns[0]}"
       flag=Subscription.delete_from_service(msg.service_id,msg.msisdns[0])
       flag = Keyword.check_status(msg.service_id,msg.msisdns[0])
       k=Keyword.find_by_name(msg.service_id)
       if k!=nil
          send_sms(msg.msisdns[0],k.message_goodbye)
        end
      !flag
  end
  def action_process_subscriptions(msg)
     
  end
  
 
  def stomp_SUBSCRIPTION(msg, stomp_msg)
    # sms=SmscManager::Sms.load_xml(msg.body)
      puts "processing subscription #{stomp_msg.body}"  #if @debug
      subscription_msg=SubscriptionManager::Message.load_xml(stomp_msg.body)
      resp=false
      case subscription_msg.action
      when 'action_subscribe'
         resp=action_subscribe(subscription_msg)
        
      when 'action_unsubscribe'
        resp=action_unsubscribe(subscription_msg)
        when 'action_get_subscriptions'
           resp=action_get_subscriptions(subscription_msg)
        when 'action_broadcast_sms'
          resp=action_broadcast_sms(subscription_msg)
         
         when 'action_broadcast_text_mms'
            resp=action_broadcast_text_mms(subscription_msg)
           
         when 'action_broadcast_mms'
             resp=action_broadcast_mms(subscription_msg)
            
         when 'action_status'
           puts "in action STATUs"
           resp=action_status(subscription_msg)
         
        else
           resp='unknown_action'
          
        end
            reply_msg = StompMessage::Message.new('stomp_REPLY', resp)
      
      
       [true, reply_msg]
   #  sleep(SLEEP_TIME)  #only 5 messages per second max
  end
  
end # subscription manager

end #module