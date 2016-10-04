srr_tomcat Cookbook
=====================
Installs tomcat from a file on an HTTP share.
Sets up a user and group for the tomcat service.
Sets custom catalina options.
Can enable tomcat clustering but not on by default.
JDBC files included.
Deployment script for jenkins WAR file deployments.
Sets up permissions for a user account for WAR deployments.
Sets up files for jmx monitoring. It is enabled by default.

NOTE: If you want to use the deploy account with tomcat,
      make sure to run the srr_deploy cookbook before you
	  run this cookbook.


Requirements
------------
Linux only.

Tested on...
CentOS 6.5
RHEL 6.5

Depends on srr_jdk cookbook for java

NOTE: If you want to use the deploy account with tomcat,
      make sure to run the srr_deploy cookbook before you
	  run this cookbook.


Attributes
----------
srr_tomcat::default

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['downloadurlroot']</tt></td>
    <td>String</td>
    <td>URL that contains the tomcat install tar.gz</td>
    <td><tt>"http://archive.apache.org/dist/tomcat/tomcat-7/v7.0.56/bin/"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['version']</tt></td>
    <td>String</td>
    <td>Basically the name of the tomcat tar.gz file without the .tar.gz</td>
    <td><tt>"apache-tomcat-7.0.54"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['root']</tt></td>
    <td>String</td>
    <td>The root folder for the tomcat install</td>
    <td><tt>"/usr/local"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['user']</tt></td>
    <td>String</td>
    <td>The user account for running the tomcat service</td>
    <td><tt>"tomcat"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['group']</tt></td>
    <td>String</td>
    <td>The group for permissions to the tomcat service</td>
    <td><tt>"tomcat"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['logsdir']</tt></td>
    <td>String</td>
    <td>The location of the logs directory</td>
    <td><tt>"#{['srr_tomcat']['root']}/tomcat/logs"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['catalina_opts']</tt></td>
    <td>String</td>
    <td>The options for catalina</td>
    <td><tt>""-Xms512m -Xmx1536m -XX:NewSize=256m -XX:MaxNewSize=256m -XX:PermSize=256m -XX:MaxPermSize=256m -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -Dorg.apache.jasper.compiler.Parser.STRICT_QUOTE_ESCAPING=false -Dorg.apache.jasper.compiler.Parser.STRICT_WHITESPACE=false -Dorg.apache.tomcat.util.http.ServerCookie.ALLOW_EQUALS_IN_VALUE=true -Dorg.apache.tomcat.util.http.ServerCookie.ALLOW_HTTP_SEPARATORS_IN_V0=true -Dcom.sun.management.jmxremote.port=10080""</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['multicast']</tt></td>
    <td>String</td>
    <td>An optional block for enabling multicast. Commented out by default</td>
    <td><tt>"<!-- COMMENTED OUT TO DISABLE MULTICAST
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
		 -->"</tt></td>
  </tr>
 <tr>
   <td><tt>['srr_tomcat']['useremoteipvalve']</tt></td>
   <td>String</td>
   <td>An option for enabling the RemoteIpValve. Off by default. If you use this, make sure to use %a in the log pattern instead of %{X-Forwarded-For}i to get the X-Forwarded-For from the ACE.</td>
   <td><tt>"yes"</tt></td>
 </tr>
  <tr>
    <td><tt>['srr_tomcat']['accesslogvalvepattern']</tt></td>
    <td>String</td>
    <td>The format of the access log in server.xml</td>
    <td><tt>"%a %l %u %t %r %s %b %{User-Agent}i %D"</tt></td>
  </tr>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['jdbc_drivers_to_add']</tt></td>
    <td>Array</td>
    <td>The list of JDBC drivers to copy. Files must exist in the cookbooks /files/default folder.</td>
    <td><tt>['jconn2.jar', 'jtds-1.2.jar', 'sqljdbc41.jar']</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['jdbc_drivers_to_delete']</tt></td>
    <td>Array</td>
    <td>The list of JDBC drivers to delete from the file system.</td>
    <td><tt>['sqljdbc.jar']</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['jdbc_resource']</tt></td>
    <td>String</td>
    <td>Define a JDBC resource here</td>
    <td><tt>'<!-- COMMENTED OUT
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
		-->'</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['jndi']</tt></td>
    <td>String</td>
    <td>Configure a JNDI resource here</td>
    <td><tt>'<!-- COMMENTED OUT
<ResourceLink name="jdbc/RESOURCENAME"
        global="jdbc/common_db"
        auth="Container"
	type="javax.sql.DataSource" />
	-->'</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['multipart_config']</tt></td>
    <td>String</td>
    <td>Increasing this can allow larger WAR files to be deployed through the Manager interface in tomcat</td>
    <td><tt>"    <multipart-config>
      <!-- 50MB max -->
      <max-file-size>52428800</max-file-size>
      <max-request-size>52428800</max-request-size>
      <file-size-threshold>0</file-size-threshold>
    </multipart-config>"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['tomcat_users']</tt></td>
    <td>String</td>
    <td>Config for tomcat-users.xml if you want to deploy a WAR with the manager interface</td>
    <td><tt>"<!--
  <role rolename="tomcat"/>
  <role rolename="role1"/>
  <user username="tomcat" password="tomcat" roles="tomcat"/>
  <user username="both" password="tomcat" roles="tomcat,role1"/>
  <user username="role1" password="tomcat" roles="role1"/>
-->"</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['password_databag']</tt></td>
    <td>String</td>
    <td>The name of the databag with the encrypted tomcat user password</td>
    <td><tt>'tomcat'</tt></td>
  </tr>
  <tr>
    <td><tt>['srr_tomcat']['tomcat_user_password']</tt></td>
    <td>String</td>
    <td>Openssl MD5 encrypted password for the tomcat user</td>
    <td><tt>Read from an encrypted data bag</tt></td>
  </tr>
</table>




Usage
-----
#### srr_tomcat::default

## Use a wrapper cookbook ##
In your metadata.rb: add the line 'depends srr_tomcat'
In your recipes/default.rb: add the line 'include_recipe srr_tomcat'
In your attributes/default.rb: Override any attributes you like.

Or, just include `srr_tomcat` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[srr_tomcat]"
  ]
}
```


License and Authors
-------------------
Authors: Steven Riggs
