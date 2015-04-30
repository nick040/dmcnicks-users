module Puppet::Parser::Functions
  newfunction(:accounts_merge_sshkeys, :type => :rvalue, :arity => 2) do |args|
    sshkeys = Hash.new
    return sshkeys unless args[0].is_a?(Hash)
    args[0].each do |username, attrs|
      next unless attrs.is_a?(Hash)
      next unless attrs["sshkeys"].is_a?(Hash)
      sshkeys.merge!(attrs["sshkeys"])
    end
    return Hash[sshkeys.map{|a,b| [args[1] + a, b]}]
  end
end
