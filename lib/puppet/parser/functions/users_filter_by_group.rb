module Puppet::Parser::Functions
  newfunction(:users_filter_by_group, :type => :rvalue, :arity => 2) do |args|
    users = args[0]
    selected = Hash.new
    return selected unless users.is_a?(Hash)
    groups = [ args[1] ].flatten
    groups.each do |group|
      users.each do |name,attrs|
        next if selected.key?(name)
        next unless attrs.key?('groups')
        selected[name] = attrs if [ attrs['groups'] ].flatten.include?(group)
      end
    end
    return selected
  end
end
