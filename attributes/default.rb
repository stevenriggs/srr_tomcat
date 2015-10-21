#
# Cookbook Name:: srr_tomcat
# Attributes:: default
#

default["srr_tomcat"]["downloadurlroot"] = "http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.56/bin/"
default['srr_tomcat']['version'] = "apache-tomcat-7.0.56"
default['srr_tomcat']['root'] = "/usr/local"
default['srr_tomcat']['user'] = "tomcat"
default['srr_tomcat']['group'] = "tomcat"

#The initial value ${catalina.base}/logs will not work with this script
default['srr_tomcat']['logsdir'] = "#{node['srr_tomcat']['root']}/tomcat/logs"


#setup tomcat memory options here
#enable/disable jmx monitoring here
#add -Dcom.sun.management.jmxremote.port=10080  to the end of the string
default['srr_tomcat']['catalina_opts'] = "-Xms512m -Xmx1536m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:PermSize=256m -XX:MaxPermSize=256m -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false -Dorg.apache.jasper.compiler.Parser.STRICT_WHITESPACE=false -Dorg.apache.tomcat.util.http.ServerCookie.ALLOW_EQUALS_IN_VALUE=true -Dorg.apache.tomcat.util.http.ServerCookie.ALLOW_HTTP_SEPARATORS_IN_V0=true -Dcom.sun.management.jmxremote.port=10080"


#enable/disable tomcat multicast cluster here
#set the address="123.123.123.123"
#comment the entire block with <!-- if you don't want multicast
default['srr_tomcat']['multicast'] = '<!-- COMMENTED OUT TO DISABLE MULTICAST
<Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"
                 channelSendOptions="8">
          <Channel className="org.apache.catalina.tribes.group.GroupChannel">
            <Membership className="org.apache.catalina.tribes.membership.McastService"
                        address="228.0.0.200"
                        port="45564"
                        frequency="500"
                        dropTime="15000"/>
          </Channel>
         </Cluster>
		 -->'

#If you use the remoteipvalve, make sure to use %a in the log pattern
#instead of %{X-Forwarded-For}i to get the X-Forwarded-For from the ACE.
default['srr_tomcat']['useremoteipvalve'] = "yes"

default['srr_tomcat']['accesslogvalvepattern'] = "%a %l %u %t %r %s %b %{User-Agent}i %D"


#JDBC drivers (these attributes are arrays)
default['srr_tomcat']['jdbc_drivers_to_add'] = ['jconn2.jar', 'jtds-1.2.jar', 'sqljdbc41.jar']
default['srr_tomcat']['jdbc_drivers_to_delete'] = ['sqljdbc.jar']


default['srr_tomcat']['jdbc_resource'] = '<!-- COMMENTED OUT
<Resource name="jdbc/common_db"
        global="jdbc/common_db"
        auth="Container"
        type="javax.sql.DataSource"
        driverClassName="com.sybase.jdbc4.jdbc.SybDriver"
        url="jdbc:sybase:Tds:SERVERNAME:5000/common_db"
        username="USERNAME"
        password="PASSWORD"
        maxActive="100"
        maxIdle="20"
        minIdle="5"
        maxWait="10000"/>
		-->'

default['srr_tomcat']['jndi'] = '<!-- COMMENTED OUT
<ResourceLink name="jdbc/RESOURCENAME"
        global="jdbc/common_db"
        auth="Container"
	type="javax.sql.DataSource" />
	-->'

#Add Additional VirtualHost Definitions here
#Remove the comment and add virtualHost blocks here if you want to add vhosts
default['srr_tomcat']['virtualHostBlock'] = '<!-- Leave COMMENTED OUT to not use virtual Hosts -->'

#Increasing this can allow larger WAR files to be deployed through the Manager interface in tomcat
default['srr_tomcat']['manager_multipart_config'] = "    <multipart-config>
      <!-- 50MB max -->
      <max-file-size>52428800</max-file-size>
      <max-request-size>52428800</max-request-size>
      <file-size-threshold>0</file-size-threshold>
    </multipart-config>"


default['srr_tomcat']['tomcat_users'] = "<!--
  <role rolename=\"tomcat\"/>
  <role rolename=\"role1\"/>
  <user username=\"tomcat\" password=\"tomcat\" roles=\"tomcat\"/>
  <user username=\"both\" password=\"tomcat\" roles=\"tomcat,role1\"/>
  <user username=\"role1\" password=\"tomcat\" roles=\"role1\"/>
-->"


#Override this to use a custom data bag for the tomcat user password
default['srr_tomcat']['password_databag'] = 'tomcat'

tomcat_creds = Chef::EncryptedDataBagItem.load("passwords", "#{node['srr_tomcat']['password_databag']}")
default['srr_tomcat']['tomcat_user_password'] = tomcat_creds["password"]
