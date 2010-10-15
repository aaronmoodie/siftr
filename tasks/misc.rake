# Validate url - returns new url if redirected
def validate(url)
  url = URI.parse(url)
  response = Net::HTTP.start(url.host, url.port) {|http|
    http.head(url.path)
  }
  
  case response
  when Net::HTTPSuccess
    return url
  when Net::HTTPRedirection
    return response['location']
  else
    return nil
  end
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


# collect MP3 files from stored blogs
task :default do
    blogs = Blog.all
    blogs.each do |blog|
        scrape = Hpricot(open(blog.url))
        links = scrape.search('//a[@href$=.mp3]')
        links.each do |link|

            url = link['href'].gsub(' ', '%20')
            
            # @match = Mp3File.all(:url => url)
            # puts @match
            # if !@match
            
            unless !url
              mp3_file = download_file(url, 3000)

              open("temp.mp3", "wb") do |file|
                  file.write(mp3_file)
              end

              mp3_file = ID3Lib::Tag.new('temp.mp3')
              puts url, mp3_file.artist, mp3_file.title, "\n"
              mp3 = Mp3File.new(:url => url, :artist => mp3_file.artist, :title => mp3_file.title, :date => Time.now)
              mp3.save
            end
            #end
        end
    end
end