module Puppet::Parser::Functions
  newfunction(:users_merge_sshkeys, :type => :rvalue, :arity => 2) do |args|
    count = 0
    prefix = args[0]
    sshkeyhash = Hash.new
    return sshkeyhash unless args[1].is_a?(Hash)
    args[1].each do |username, attrs|
      next unless attrs.is_a?(Hash)
      next unless attrs['sshkeys'].is_a?(Array)
      attrs['sshkeys'].each do |key|
        parts = key.split
        comment = "#{prefix}_#{username}_#{count}"
        sshkeyhash[comment] = Hash.new
        sshkeyhash[comment]['type'] = parts[0]
        sshkeyhash[comment]['key'] = parts[1]
        count += 1
      end
    end
    return sshkeyhash
  end
end
