
# 
# Cookbook:: http
# Recipe:: port
# Author:: SK 
#
#
# open standard http port/80 to tcp traffic only; inserting as first rule
firewall_rule 'http' do
  port     80
  protocol :tcp
  position 1
  command   :allow
end
