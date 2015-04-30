module Puppet::Parser::Functions
  newfunction(:prepare_sshkey_hash, :type => :rvalue, :arity => 2) do |args|
    count = 0
    user = args[0]
    sshkeyhash = Hash.new
    return sshkeyhash unless args[1].is_a?(Array)
    args[1].each do |key|
      parts = key.split
      comment = "#{user}_#{count}"
      sshkeyhash[comment] = Hash.new
      sshkeyhash[comment]['type'] = /^ssh-(\w+)$/.match(parts[0])[1]
      sshkeyhash[comment]['key'] = parts[1]
      count += 1
    end
    return sshkeyhash
  end
end
