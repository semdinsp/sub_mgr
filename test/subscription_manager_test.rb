require File.dirname(__FILE__) + '/test_helper.rb'

class SubscriptionManagerTest < Test::Unit::TestCase

  def setup
  end
  
  def test_message_exception
     begin
     m1=SubscriptionManager::Message.new()
     m1.action='hello there'
    rescue Exception => e
      assert true, 'raised exception'
     end
  end
  def test_message_mssidns
      begin
      m1=SubscriptionManager::Message.new("stomp_SUBSCRIBE")
      m1.action='action_subscribe'
      m1.msisdns << "639993130030"
      m1.msisdns << "639993130031"
     rescue Exception => e
       assert false, "raised exception #{e.message} but should not "
      end
     # puts "CHECK THIS xml: #{m1.to_xml}"
      m2=SubscriptionManager::Message.load_xml(m1.to_xml)
#      assert m1.to_xml == m2.to_xml,  'xml not same'
      assert m2.msisdns.index("639993130031")!=nil , "msisdn not there"
   end
   def test_message_single_msidn
       begin
       m1=SubscriptionManager::Message.new("stomp_SUBSCRIBE")
       m1.action='action_subscribe'
       m1.msisdns << "639993130030"
   #    m1.msisdns << "639993130031"
      rescue Exception => e
        assert false, "raised exception #{e.message} but should not "
       end
   #    puts "CHECK THIS xml: #{m1.to_xml}"
       m2=SubscriptionManager::Message.load_xml(m1.to_xml)
 #      assert m1.to_xml == m2.to_xml,  'xml not same'
       assert m2.msisdns.index("639993130031")==nil , "msisdn should not there"
       assert m2.msisdns.index("639993130030")!=nil , "msisdn not there"
    end
  def test_message_exception2
     begin
     m1=SubscriptionManager::Message.new("stomp_SUBSCRIBE")
     m1.action='action_subscribe'
    rescue Exception => e
      assert false, "raised exception #{e.message} but should not #{e.backtrace}"
     end
     assert m1.action=="action_subscribe", "it should be action subscribe but came wrong"
  end
  def test_message_creation3
     begin
     m1=SubscriptionManager::Message.new("stomp_SUBSCRIBE")
     m1.action='action_status'
    rescue Exception => e
      assert false, "raised exception #{e.message} but should not #{e.backtrace}"
     end
     assert m1.action=="action_status", "it should be action status but came wrong"
  end
  def test_a1_env_variables
    args={:topic => '/topic/subscriptions', :env => 'development', :root_path => "../models/"}
    rp = args[:root_path] + "*"
    res=Dir[rp].sort
    assert res.include?(args[:root_path]+"keyword.rb")== true, "assert directory structure incorrect #{res} "
   end
  def test_message_subscribe
    args={:topic => '/topic/subscriptions', :env => 'development', :root_path => "../models/"}
     ss=SubscriptionManager::SubscriptionServer.new(args)
     ss_thread = Thread.new {
            ss.run }
     sleep(3)
     s=SubscriptionManager::SubscriptionSendTopic.new
     arg_hash = {}
         arg_hash[:keyword]='hello'
          arg_hash[:msisdn]='639993130030'
          arg_hash[:action]='action_subscribe'
     s.send_subscription(arg_hash)
     sleep(5)
     
  end
  def test_base_server
    #note activemq or stomp message bus needs to be running
     args={:topic => '/topic/subscriptions', :env => 'development', :root_path => "../models/"}
     ss=SubscriptionManager::SubscriptionServer.new(args)
     ss_thread = Thread.new {
            ss.run }
     sleep(3)
     assert ss.topic=='/topic/subscriptions', "topic not set properly"
     msg=StompMessage::Message.new('stomp_PING', "body")
     assert msg.command=='stomp_PING', "message command not correct"
     puts "creating ping messager topic"
     send_topic=StompMessage::StompSendTopic.new(args) 
      puts "send ping WITH ack"
      msg_reply=''
       send_topic.send_topic_acknowledge(msg,{ })   { |m|  assert true
                    puts "#{m.to_s}"
                    msg_reply=StompMessage::Message.load_xml(m)
                
                  }
        sleep(3)
          assert msg_reply.command== 'stomp_REPLY',  "command wrong" 
          assert msg_reply.body.split[0]== 'ALIVE',  "ping not ok #{msg_reply.body}" 
          send_topic.close_topic   
      ss_thread.kill          
  end
  def test_broadcast_server
    #note activemq or stomp message bus needs to be running
     args={:topic => '/topic/subscriptions', :env => 'development', :root_path => "../models/"}
     ss=SubscriptionManager::SubscriptionServer.new(args)
     ss_thread = Thread.new {
            ss.run }
     sleep(3)
     assert ss.topic=='/topic/subscriptions', "topic not set properly"
     msg=StompMessage::Message.new('stomp_PING', "body")
     assert msg.command=='stomp_PING', "message command not correct"
     puts "creating ping messager topic"
     send_topic=StompMessage::StompSendTopic.new(args) 
      puts "send ping WITH ack"
      msg_reply=''
       send_topic.send_topic_acknowledge(msg,{ })   { |m|  assert true
                    puts "#{m.to_s}"
                    msg_reply=StompMessage::Message.load_xml(m)
                
                  }
        sleep(3)
          assert msg_reply.command== 'stomp_REPLY',  "command wrong" 
          assert msg_reply.body.split[0]== 'ALIVE',  "ping not ok #{msg_reply.body}" 
          send_topic.close_topic  
          arg_hash = {} 
             arg_hash[:keyword]='test'
             arg_hash[:broadcast]=''
              arg_hash[:broadcast] << "hello there"
          # puts "size #{data.size} #{len} broadcast size: #{arg_hash[:broadcast].size}"
          # puts "broadcast: #{arg_hash[:broadcast]}"
           arg_hash[:action]= 'action_broadcast_sms'
           puts "about to send sms message of length: #{arg_hash[:broadcast].size} to all subscribers of keyword #{arg_hash[:keyword]}"
           submgr=SubscriptionManager::SubscriptionSendTopic.new(arg_hash)
           result=submgr.send_subscription_response(arg_hash)
           sleep(10)
           assert result.include?('sent'), "result is #{result}"
      ss_thread.kill          
  end
  def test_url
    subMgr = SubscriptionManager::Control.new
    oldurl=subMgr.urlbase
    assert  subMgr.urlbase!='test', 'urlbase not correct'
    subMgr.urlbase='test'
    assert  subMgr.urlbase=='test', 'urlbase not correct'
    subMgr.dump
    subMgr = SubscriptionManager::Control.load_url
  #  assert  subMgr.urlbase!='test', 'urlbase not correct'
  #  subMgr.load_url
     assert  subMgr.urlbase=='test', 'urlbase not correct'
    assert true
  end
end
