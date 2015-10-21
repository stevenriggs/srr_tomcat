#
# Cookbook Name:: srr_tomcat
# Recipe:: default
#
# Copyright 2014, Steven Riggs
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

#TODO: make script update an existing tomcat by migrating
#      files to the new instance.
#
#TODO: only for redhat or centos
#      if node.platform_family?('rhel')
#      what about windows?
#
#TODO: Remove the dependency on the deploy cookbook
#
#TODO: Multi host support
#
#TODO: Fix issue with tomcat group getting modified on every chef client run.



include_recipe 'srr_jdk'


#download the tomcat install file
remote_file "/tmp/#{node[:srr_tomcat][:version]}.tar.gz" do
	source "#{node[:srr_tomcat][:downloadurlroot]}/#{node[:srr_tomcat][:version]}.tar.gz"
	not_if { File.exist?("#{node[:srr_tomcat][:root]}/#{node[:srr_tomcat][:version]}") }
end

# make sure the path is there
directory "#{node[:srr_tomcat][:root]}" do
	recursive true
end

bash "stop tomcat if this version is not already installed" do
	code <<-EOS
		service tomcat stop
		sleep 10
		sudo -u tomcat pkill -9 -f -U tomcat java.\*#{node[:srr_tomcat][:root]}/tomcat
		if [[ $? -eq 0 ]]; then
			echo "NOTICE: tomcat did not shutdown cleanly and was killed"
			echo "NOTICE: you may want to double-check the process table"
		fi
	EOS
	not_if { File.exist?("#{node[:srr_tomcat][:root]}/#{node[:srr_tomcat][:version]}") }
end

bash "untar.gz tomcat install" do
	code <<-EOS
	tar -C #{node[:srr_tomcat][:root]}/ -xvf /tmp/#{node[:srr_tomcat][:version]}.tar.gz
	chmod 0751 #{node[:tomcat][:root]}/#{node[:tomcat][:version]}
	EOS
	not_if { File.exist?("#{node[:srr_tomcat][:root]}/#{node[:srr_tomcat][:version]}") }
end

#make the tomcat symlink
link "#{node[:srr_tomcat][:root]}/tomcat" do
	to "#{node[:srr_tomcat][:root]}/#{node[:srr_tomcat][:version]}"
end



#create tomcat group
group "#{node[:srr_tomcat][:group]}"
#create tomcat user
user "#{node[:srr_tomcat][:user]}" do
  home "#{node[:srr_tomcat][:root]}/tomcat"
  gid "#{node[:srr_tomcat][:group]}"
  password "#{node[:srr_tomcat][:tomcat_user_password]}"
  not_if "getent passwd #{node[:srr_tomcat][:user]}"
end
#put it in the  group
group "#{node[:srr_tomcat][:group]}" do
  action :modify
  members "#{node[:srr_tomcat][:user]}"
  append true
end
#tomcat user permissions
execute "fixup #{node[:srr_tomcat][:root]}/#{node[:srr_tomcat][:version]} owner" do
  command "chown -Rf #{node[:srr_tomcat][:user]}:#{node[:srr_tomcat][:group]} #{node[:srr_tomcat][:root]}/#{node[:srr_tomcat][:version]}"
  #only_if { Etc.getpwuid(File.stat('/usr/local/#{node[:srr_tomcat][:version]}').uid).name != "tomcat" }
end
execute "fixup #{node[:srr_tomcat][:root]}/#{node[:srr_tomcat][:version]} owner" do
  command "chown -Rf #{node[:srr_tomcat][:user]}:#{node[:srr_tomcat][:group]} #{node[:srr_tomcat][:root]}/tomcat"
  #only_if { Etc.getpwuid(File.stat('#{node[:srr_tomcat][:root]}/#{node[:srr_tomcat][:version]}').uid).name != "#{node[:srr_tomcat][:user]}" }
end
#sudo access for tomcat user
template "/etc/sudoers.d/tomcat" do
	source "tomcatsudo.erb"
	mode "0440"
	owner 'root'
	group 'root'
	variables ({
		:tomcat_user => node[:srr_tomcat][:user],
		:tomcat_group => node[:srr_tomcat][:group]
	})
end



#Setup the service
template "/etc/init.d/tomcat" do
	source "tomcat.erb"
	mode "0755"
	variables ({
		:tomcat_root => node[:srr_tomcat][:root],
		:tomcat_user => node[:srr_tomcat][:user]
	})
end



#setup the setenv.sh file for tomcat run options
#tomcat run options override with catalina_opts attribute
template "#{node[:srr_tomcat][:root]}/tomcat/bin/setenv.sh" do
  source "setenv.erb"
  mode '0600'
  owner "#{node[:srr_tomcat][:user]}"
  group "#{node[:srr_tomcat][:group]}"
  variables({
     :catalina_opts => node[:srr_tomcat][:catalina_opts]
  })
  notifies :restart, 'service[tomcat]'
end

#http://www.rubydoc.info/gems/chef/Chef/Util/FileEdit
ruby_block "Customize catalina.sh" do
	block do
		fe = Chef::Util::FileEdit.new("#{node[:srr_tomcat][:root]}/tomcat/bin/catalina.sh")

		fe.search_file_delete_line("JAVA_OPTS=.*")
		fe.search_file_delete_line("# This file is managed by Chef.")
		fe.search_file_delete_line("# Do NOT modify this file.")
		fe.insert_line_after_match("#!/bin/sh","# This file is managed by Chef.")
		fe.insert_line_after_match("# This file is managed by Chef.","# Do NOT modify this file.")

		fe.write_file
	end
end



#setup the files for jmx monitoring
#TODO:  Try to get #{ENV['JRE_HOME']} working instead.
#       it's not available till user logout/login. grrr
template "#{node[:srr_jdk][:installroot]}/latest/jre/lib/management/management.properties" do
  source "management.properties.erb"
  mode '0644'
  variables({
     :fqhostname => node['fqdn']
  })
end
cookbook_file "#{node[:srr_jdk][:installroot]}/latest/jre/lib/management/jmxremote.access" do
  source "jmxremote.access"
  mode '0644'
end
cookbook_file "#{node[:srr_jdk][:installroot]}/latest/jre/lib/management/jmxremote.password" do
  source "jmxremote.password"
  mode '0600'
  owner "#{node[:srr_tomcat][:user]}"
end




#Copy JDBC files
node['srr_tomcat']['jdbc_drivers_to_add'].each do |add_driver|
	cookbook_file "#{node[:srr_tomcat][:root]}/tomcat/lib/#{add_driver}" do
		source "#{add_driver}"
		mode "0644"
		owner "#{node[:srr_tomcat][:user]}"
		group "#{node[:srr_tomcat][:group]}"
	end
end
#Delete unwanted JDBC files
node['srr_tomcat']['jdbc_drivers_to_delete'].each do |delete_driver|
	file "#{node[:srr_tomcat][:root]}/tomcat/lib/#{delete_driver}" do
		action :delete
	end
end

#Custom log file directory location
# make sure the path is there
directory "#{node[:srr_tomcat][:logsdir]}" do
	owner "#{node[:srr_tomcat][:user]}"
	group "#{node[:srr_tomcat][:group]}"
	recursive true
	#if it's not the default
	#not_if node[:srr_tomcat][:logsdir] != "#{['srr_tomcat']['root']}/tomcat/logs"
end

#http://www.rubydoc.info/gems/chef/Chef/Util/FileEdit
ruby_block "Set logs folder path in logging.properties" do
	block do
		fe = Chef::Util::FileEdit.new("#{node[:srr_tomcat][:root]}/tomcat/conf/logging.properties")

		fe.search_file_replace_line("1catalina.org.apache.juli.FileHandler.directory", "1catalina.org.apache.juli.FileHandler.directory = #{node[:srr_tomcat][:logsdir]}")

		fe.search_file_replace_line("2localhost.org.apache.juli.FileHandler.directory", "2localhost.org.apache.juli.FileHandler.directory = #{node[:srr_tomcat][:logsdir]}")

		fe.search_file_replace_line("3manager.org.apache.juli.FileHandler.directory", "3manager.org.apache.juli.FileHandler.directory = #{node[:srr_tomcat][:logsdir]}")

		fe.search_file_replace_line("4host-manager.org.apache.juli.FileHandler.directory", "4host-manager.org.apache.juli.FileHandler.directory = #{node[:srr_tomcat][:logsdir]}")

		fe.write_file
	end
	only_if do ::File.exists?("#{node[:srr_tomcat][:root]}/tomcat/conf/logging.properties") end
end

ruby_block "Set catalina.out log location in catalina.sh" do
	block do
		fe = Chef::Util::FileEdit.new("#{node[:srr_tomcat][:root]}/tomcat/bin/catalina.sh")

		fe.search_file_replace_line("CATALINA_OUT=", "CATALINA_OUT=#{node[:srr_tomcat][:logsdir]}/catalina.out")

		fe.write_file
	end
end

template "#{node[:srr_tomcat][:root]}/tomcat/conf/server.xml" do
	source "server.xml.erb"
	mode "0600"
	owner "#{node[:srr_tomcat][:user]}"
	group "#{node[:srr_tomcat][:group]}"
	variables({
		:jdbcResourceBlock => node[:srr_tomcat][:jdbc_resource],
		:multicastblock => node[:srr_tomcat][:multicast],
		:logsdir => node[:srr_tomcat][:logsdir],
		:accesslogvalvepattern => node[:srr_tomcat][:accesslogvalvepattern],
		:useremoteipvalve => node[:srr_tomcat][:useremoteipvalve],
		:virtualHostBlock => node[:srr_tomcat][:virtualHostBlock]
	})
	notifies :restart, 'service[tomcat]'
end

template "#{node[:srr_tomcat][:root]}/tomcat/conf/context.xml" do
	source "context.xml.erb"
	mode "0600"
	owner "#{node[:srr_tomcat][:user]}"
	group "#{node[:srr_tomcat][:group]}"
	variables({
		:jndiBlock => node[:srr_tomcat][:jndi]
	})
end


# Control the size of WAR that can be uploaded with the manager interface
template "#{node[:srr_tomcat][:root]}/tomcat/webapps/manager/WEB-INF/web.xml" do
	source "manager_web.xml.erb"
	mode "0644"
	owner "#{node[:srr_tomcat][:user]}"
	group "#{node[:srr_tomcat][:group]}"
	variables({
		:manager_multipart_config => node[:srr_tomcat][:manager_multipart_config]
	})
end

# tomcat users
template "#{node[:srr_tomcat][:root]}/tomcat/conf/tomcat-users.xml" do
	source "tomcat_users.xml.erb"
	mode "0600"
	owner "#{node[:srr_tomcat][:user]}"
	group "#{node[:srr_tomcat][:group]}"
	variables({
		:tomcat_users => node[:srr_tomcat][:tomcat_users]
	})
end



#enable and start tomcat
service "tomcat" do
	action [ :enable, :start ]
end



#catalina.out log rotation
package "logrotate"

template "/etc/logrotate.d/tomcat" do
	source "logrotate_tomcat.erb"
	mode "0644"
	owner "root"
	group "root"
	variables({
		:catalina_out_location => "#{node[:srr_tomcat][:logsdir]}/catalina.out"
	})
end



### The blocks below are only ###
### used if the deploy user   ###
### is present on the system  ###

#setup jenkins deployment script
template "/usr/local/bin/tomcat-deploy.sh" do
	source "tomcat-deploy.sh.erb"
	mode "0755"
	variables ({
		:tomcat_root => node[:srr_tomcat][:root],
		:tomcat_user => node[:srr_tomcat][:user]
	})
	only_if "getent passwd #{node[:srr_deploy][:user]}"
end
#put deploy user account in the tomcat group
group "#{node[:srr_tomcat][:group]}" do
  action :modify
  members "#{node[:srr_deploy][:user]}"
  append true
  only_if "getent passwd #{node[:srr_deploy][:user]}"
end
#give deploy user account some sudo privs
template "/etc/sudoers.d/deploy-tomcat" do
  source "deploy-tomcat_sudo.erb"
  mode '0440'
  variables ({
	:tomcat_user => node[:srr_tomcat][:user],
	:deploy_user => node[:srr_deploy][:user]
  })
  only_if "getent passwd #{node[:srr_deploy][:user]}"
end
