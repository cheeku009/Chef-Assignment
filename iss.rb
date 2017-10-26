#
# 
# Cookbook:: Install iis
# Recipe:: iis6
# Author:: SK 
#
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
#

include_recipe 'iis'

features = if Opscode::IIS::Helper.older_than_windows2012r2?
             %w(Web-Mgmt-Compat Web-Metabase)
           else
             %w(IIS-IIS6ManagementCompatibility IIS-Metabase)
           end

features.each do |f|
  windows_feature f do
    action :install
  end
end
