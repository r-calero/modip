require 'drb/drb'
require 'drb/ssl'
require 'openssl'

# Mutual TLS for the conversion broker and its workers (drbssl://).
# Both sides present a certificate signed by the installation CA
# (deploy/conversion/certs.sh) and verify the other side against it.
module ConversionTLS
  BROKER_NAME = 'conversion-broker'

  # Raised by the broker for a worker that is not in MODIP_CONVERSION_WORKERS.
  # A StandardError, so DRb sends it back to the worker.
  class NotAllowed < StandardError; end

  # expected_peer: CN the certificate of the other side must have. drb/ssl does
  # not check host names, so the worker pins the broker certificate this way.
  def self.config(cert_file, key_file, ca_file, expected_peer = nil)
    config = {
      :SSLCertificate => OpenSSL::X509::Certificate.new(File.read(cert_file)),
      :SSLPrivateKey => OpenSSL::PKey.read(File.read(key_file)),
      :SSLCACertificateFile => ca_file,
      :SSLVerifyMode => OpenSSL::SSL::VERIFY_PEER | OpenSSL::SSL::VERIFY_FAIL_IF_NO_PEER_CERT
    }
    if expected_peer
      config[:SSLVerifyCallback] = lambda do |ok, store|
        ok && (store.error_depth > 0 || common_name(store.current_cert) == expected_peer)
      end
    end
    config
  end

  def self.common_name(cert)
    entry = cert && cert.subject.to_a.detect { |name, _, _| name == 'CN' }
    entry && entry[1]
  end

  # CN of the client certificate of the DRb call being served (broker side).
  def self.peer_name
    client = (Thread.current['DRb'] || {})['client']
    return nil unless client && client.respond_to?(:stream)
    common_name(client.stream.peer_cert)
  end
end
