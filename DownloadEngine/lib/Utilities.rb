require 'net/http'
require "net/ftp"

module WebUtilities

  def WebUtilities.FTPRequest(url, dir, filetype = 'text')
    uri = URI.parse(url)
    ftp = Net::FTP.new(uri.host)
    ftp.passive = true
    ftp.login
    if filetype == 'text'
      ftp.gettextfile(uri.path, dir)
    else
      ftp.getbinaryfile(uri.path, dir)
    end
    ftp.close
  end

  def self.HTTPRequest(url, dir, proxy = "")
    url = url.gsub("ftp://", "https://")
    url = "https://" + url unless url =~ /^(https:\/\/).+/
    puts "Downloading data from url: #{url}"
    uri = URI.parse(url)
    uri_proxy = URI.parse(proxy)
    Net::HTTP::Proxy(uri_proxy.host, uri_proxy.port, uri_proxy.user, uri_proxy.password).start(uri.host, :use_ssl => true, :verify_mode => OpenSSL::SSL::VERIFY_NONE) do |http|
      #response, data = http.get("/" + uri.path, nil)
      response = http.get("/" + uri.path)
      File.open(dir, 'wb') do |f|
        f.write(response.body)
      end
    end
  end
end
