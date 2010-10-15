helpers do
  
  def hash_password(salt, password)
    return Digest::SHA2.hexdigest(salt+password)
  end
  
  
  def download_file(url, size)
    request = "GET #{url} HTTP/1.0\r\n\r\n"
    host = /^https?:\/\/([^\/]+)/.match(url.to_s)
    socket = TCPSocket.open(host[1].to_s,80)
    socket.print(request)    

    # find beginning of response body
    buffer = ""                    
    while !buffer.match("\r\n\r\n") do
      buffer += socket.read(1)  
    end           

    return socket.read(size)
  end
  
end