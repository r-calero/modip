require 'drb/drb'
require 'drb/acl'

# Only accept DRb connections from these networks (space separated). The
# default covers localhost and the private ranges used by Docker networks.
module ModipDrbAcl
  DEFAULT = "127.0.0.1 ::1 10.0.0.0/8 172.16.0.0/12 192.168.0.0/16"

  def self.install
    value = ENV["MODIP_DRB_ALLOW"].to_s.strip
    allowed = (value.empty? ? DEFAULT : value).split
    DRb.install_acl(ACL.new(%w(deny all) + allowed.map { |net| ["allow", net] }.flatten))
  end
end
