module Puppet::Parser::Functions
  newfunction(:users_hash_sshkeys, :type => :rvalue, :arity => 2) do |args|
    count = 0
    user = args[0]
    sshkeyhash = Hash.new
    keys = [ args[1] ].flatten
    keys.each do |key|
      parts = key.split
      if parts.count == 3 then
        comment = "#{parts[2]}_#{user}_#{count}"
      else
        comment = "#{user}_#{count}"
      end
      sshkeyhash[comment] = Hash.new
      sshkeyhash[comment]['type'] = parts[0]
      sshkeyhash[comment]['key'] = parts[1]
      count += 1
    end
    return sshkeyhash
  end
end
