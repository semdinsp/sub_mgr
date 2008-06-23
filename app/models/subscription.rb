class Subscription < ActiveRecord::Base
  
  validates_presence_of     :msisdn 
   validates_length_of       :msisdn,    :is => 12
  belongs_to :keyword
  def to_label
      label =  "Subscriber: #{self.msisdn}"
      k=self.keyword
      case k.name
      when 'email'
         label <<  " params:hidden" if self.keyword_params !=nil
      else
        label <<  " params: #{self.keyword_params}" if self.keyword_params !=nil
      end if k!=nil
    
      return label #if  self.keyword.name!='email'
   # fix later   return  "Subscriber: #{self.msisdn} p: hidden"
    end
  def self.delete_from_service(service,msisdn)
     keyword_name, params=Subscription.setup_parameters(service)
     k=Keyword.find_by_name(keyword_name)
     flag=false
     if k!=nil
        s=Subscription.find_by_msisdn_and_keyword_id_and_keyword_params(msisdn,k,params)
        flag=true if s!=nil
        s.destroy if s!=nil
     end
     flag
  end
  def self.delete_all_subscriptions(msisdn)
       s=Subscription.find_all_by_msisdn(msisdn) 
        count=0
        s.each {|i| i.destroy
                    count+=1 }  if s!=nil
        count
  end
  def self.setup_parameters(string)
      s=string.split(':')

      params = ''
      1.upto(s.size-1) { |b| params << "#{s[b]}" <<":" }
      
       keyword_name = s[0] 
       [keyword_name, params]
    end
  def setup_parameters(string)
     keyword_name, self.keyword_params = Subscription.setup_parameters(string)
     keyword_name
   end
  def add_to_keyword(string)
    keyword_name=self.setup_parameters(string)
    k = Keyword.find_by_name(keyword_name)
    flag=false
    #allow duplicates?
    duplicates_allowed=true
    if k!=nil
      if Subscription.find_by_msisdn_and_keyword_id(self.msisdn,k) == nil or duplicates_allowed
         k.subscriptions << self
         self.save
        flag=k.save
       end
    end
    flag
  end
  def self.add_to_keyword(keyword, num)
     # puts "keyword is #{keyword} number is #{num}"
      flag=false
      if num!=nil and num!=''  
         s=Subscription.new
        s.msisdn = num  
        flag = s.add_to_keyword(keyword.name)  
      end
        flag
      
 end
  
end
