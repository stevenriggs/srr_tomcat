srr_tomcat CHANGELOG
======================

This file is used to list changes made in each version of the srr_tomcat cookbook.

0.1.0
-----
- Steven Riggs - Initial release of srr_tomcat

1.2.0
-----
- Steven Riggs - Fix storing user passwords with encrypted databags.
- Steven Riggs - Fixed JMX config file location bug.
- Steven Riggs - Now depends on srr_jdk cookbook.  This is a good thing.
- Steven Riggs - Lots of attributes to override. More portable than before.

1.3.0
-----
- Steven Riggs - Moved the deploy account setup out to it's own cookbook

1.3.1
-----
- Steven Riggs - Added a line to ensure the tomcat install path exists

1.3.2
-----
- Steven Riggs - Fixed an issue with overriding the tomcat user data bag
- Steven Riggs - Fixed issue with file ownership and custom user account
- Steven Riggs - Fixed issue with user tomcat account pre-existing

1.4.0
-----
- Steven Riggs - Added custom tomcat log directory location
- Steven Riggs - Added attribute for custom access log valve pattern

1.5.0
-----
- Steven Riggs - Added set up for WAR deployment through the manager interface

1.6.0
-----
- Steven Riggs - Added JDBC and JNDI configurations.
- Steven Riggs - Added srr_iptables cookbook so firewall will have a good default configuration.

1.7.0
-----
- Steven Riggs - Removed the requirement for the deploy user.  Now tomcat can be installed without it.

1.8.0
-----
- Steven Riggs - Added new attributes to add and remove JDBC drivers. Now you can customize the set of JDBC drivers per deployment.

1.8.1
-----
- Steven Riggs - Set the tomcat service to restart if the server.xml changes.
- Steven Riggs - Corrected permissions bug with the server.xml file.

1.8.2
-----
- Steven Riggs - Fixed a bug with restarting the tomcat service on first install.

1.8.3
-----
- Steven Riggs - Now will restart tomcat if the catalina options change.
- Steven Riggs - Fixed some group permissions issues.

1.9.0
-----
- Steven Riggs - Major improvements in the tomcat init.d script

1.9.1
-----
- Steven Riggs - Removed dependency on iptables cookbook

1.9.2
-----
- Steven Riggs - Corrected issue with RemoteIpValve stopping the X-Forwarded-For header logging.

1.10.0
------
- Steven Riggs - Added RemoteIpValve option.

1.11.0
------
- Steven Riggs - Setting the default configuration to enable the RemoteIpValve.

1.11.1
------
- Steven Riggs - Fixed bug with Customize catalina.sh block

1.12.0
------
- Steven Riggs - Added catalina.out log rotation

1.12.1
------
- Steven Riggs - Allows the addition of VirtualHost definitions to the server.xml file if desired.


- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
