# Test client of the conversion broker (used by conversion.sh). Runs in the
# converter image with the certs volume mounted at /certs.
#
#   ruby conversion_client.rb MODE [CERT_NAME]
#
# MODE: ping | claim | garbage | flat | nocert | foreign | plain
require '/app/Server/conversion_tls'
require 'timeout'

mode, name = ARGV
uri = 'drbssl://conversion-broker:7443'

case mode
when 'nocert'
  DRb.start_service('druby://127.0.0.1:0', nil, :SSLVerifyMode => OpenSSL::SSL::VERIFY_PEER, :SSLCACertificateFile => '/certs/ca.crt')
when 'foreign'
  key = OpenSSL::PKey::RSA.new(2048)
  cert = OpenSSL::X509::Certificate.new
  cert.version = 2
  cert.serial = 1
  cert.subject = cert.issuer = OpenSSL::X509::Name.parse('/O=MODIP/CN=local')
  cert.public_key = key.public_key
  cert.not_before = Time.now - 60
  cert.not_after = Time.now + 3600
  cert.sign(key, OpenSSL::Digest::SHA256.new)
  DRb.start_service('drbssl://127.0.0.1:0', nil, :SSLCertificate => cert, :SSLPrivateKey => key,
                    :SSLVerifyMode => OpenSSL::SSL::VERIFY_PEER, :SSLCACertificateFile => '/certs/ca.crt')
when 'plain'
  DRb.start_service
  uri = 'druby://conversion-broker:7443'
else
  DRb.start_service('drbssl://127.0.0.1:0', nil,
                    ConversionTLS.config("/certs/workers/#{name}.crt", "/certs/workers/#{name}.key", '/certs/ca.crt', ConversionTLS::BROKER_NAME))
end

broker = DRbObject.new_with_uri(uri)
begin
  Timeout.timeout(20) do
    case mode
    when 'ping', 'nocert', 'foreign', 'plain'
      puts "ALLOWED #{broker.heartbeat(0, 'none')}"
    when 'claim'
      job = broker.claim('test')
      puts job ? "CLAIMED #{job['job_id']} #{job['cid']}" : 'EMPTY'
    when 'garbage', 'flat'
      job = broker.claim('test')
      if job.nil?
        puts 'EMPTY'
      else
        sdf = mode == 'garbage' ? "not an sdf\n" * 10 : job['sdf']
        puts "ACCEPTED #{broker.complete(job['job_id'], job['token'], sdf)}"
      end
    end
  end
rescue ConversionTLS::NotAllowed => e
  puts "DENIED #{e.message}"
rescue ArgumentError => e
  puts "INVALID #{e.message}"
rescue Exception => e
  puts "REFUSED #{e.class}"
end
