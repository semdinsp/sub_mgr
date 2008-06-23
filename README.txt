README for subscription_manager
===============================
The model directory is copied from the subscription app directory... these need to be in sync
config from same application


adds subscriptions using web service


version 4
give check status command


JMS:
cp ../stomp_message/build/com/ficonab/F*.class build/com/ficonab/
javac -cp $JRUBY_HOME/lib/jruby.jar:$GLASSFISH_ROOT/lib/j2ee.jar:./build -d build com/ficonab/SubscriptionBean.java
cd build
jar cf ../subscriptionbean.ear .
cd ..
asadmin deploy --host svbalance.cure.com.ph --port 2626 subscriptionbean.ear
asadmin deploy subscriptionbean.ear

OLD
jar cf ../subscriptionbean.jar .
cp subscriptionbean.jar ../../glassfish/domains/domain1/autodeploy/

CLASSPATH:
export CLASSPATH=$CLASSPATH:$GLASSFISH_ROOT/lib/j2ee.jar
export CLASSPATH=$CLASSPATH:$GLASSFISH_ROOT/lib/appserv-rt.jar
export CLASSPATH=$CLASSPATH:$GLASSFISH_ROOT/lib/javaee.jar
export CLASSPATH=$CLASSPATH:$GLASSFISH_ROOT/lib/j2ee-svc.jar
export CLASSPATH=$CLASSPATH:$GLASSFISH_ROOT/lib/appserv-ee.jar
export CLASSPATH=$CLASSPATH:$GLASSFISH_ROOT/lib/activation.jar
export CLASSPATH=$CLASSPATH:/Users/scott/Documents/ror/glassfish/lib/dbschema.jar 
export CLASSPATH=$CLASSPATH:/Users/scott/Documents/ror/glassfish/lib/appserv-admin.jar 
export CLASSPATH=$CLASSPATH:/Users/scott/Documents/ror/glassfish/lib/install/applications/jmsra/imqjmx.jar   
export CLASSPATH=$CLASSPATH:/Users/scott/Documents/ror/glassfish/lib/install/applications/jmsra/imqjmsra.jar

Mysql class path
export CLASSPATH=$CLASSPATH:$GLASSFISH_ROOT/lib/mysql-connector-java-5.0.8-bin.jar


