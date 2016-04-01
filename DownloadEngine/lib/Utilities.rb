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
	url = "ftp://" + url unless url =~ /^(ftp:\/\/).+/
	uri = URI.parse(url)
	uri_proxy = URI.parse(proxy)
	Net::HTTP::Proxy(uri_proxy.host, uri_proxy.port, uri_proxy.user, uri_proxy.password).start(uri.host) do |http|
		response, data = http.get("/" + uri.path, nil)
		File.open(dir, 'wb') do |f|
			f.write(data)
		end
	end
  end
end
