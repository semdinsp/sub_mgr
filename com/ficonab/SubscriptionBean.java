package com.ficonab;
import javax.jms.MessageListener;
import com.ficonab.FiconabBase;

//@MessageDriven(mappedName = "subscription")
public class SubscriptionBean extends FiconabBase  implements MessageListener {
		public  String get_topic() { return "subscription"; }
	
	public String get_bootstrap_string() {
	String bootstrap_string = "gem 'subscription_manager'; require 'subscription_manager'; SubscriptionManager::SubscriptionServer.new({:topic => 'subscription', :jms_source => 'subserver'})"; 
	    return bootstrap_string;
	}
	

}