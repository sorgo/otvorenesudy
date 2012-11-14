require 'net/http'

class Downloader
  include Output
  
  attr_accessor :cache_expire_time,
                :cache_file_extension,
                :cache_load,
                :cache_store,
                :cache_uri_to_path,
                :headers,
                :data,
                :repeat,
                :timeout,
                :wait_time

  def initialize
    @cache_expire_time    = nil
    @cache_file_extension = nil
    @cache_load           = true
    @cache_store          = true
    @cache_uri_to_path    = lambda { |downloader, uri| uri_to_path(uri) }

    @headers              = { 'User-Agent' => 'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:11.0) Gecko/20100101 Firefox/11.0' }
    @data                 = {}

    @repeat               = 8
    @timeout              = 40.seconds

    @wait_time            = 0.5.seconds
  end

  def download(uri)
    path, content = predownload(uri)
    
    return content unless content.nil?
    
    e = nil
  
    uri = URI.encode(uri)

    1.upto @repeat do |i|
      wait

      begin
        handler = Curl::Easy.new
        
        handler.url             = uri
        handler.connect_timeout = @timeout
        handler.timeout         = @timeout
      
        print "Downloading #{uri} ... "
      
        @headers.each { |p, v| handler.headers[p] = v }
        @data.empty? ? handler.http_get : handler.http_post(@data)

        handler.perform
        
        content = handler.body_str

        if handler.response_code == 200
          puts "done (#{content.length} bytes)"
          
          store(path, content)
          
          return content
        end
        
        e = "Invalid response code #{handler.response_code}"
        
        puts "failed (response code #{handler.response_code}, attempt #{i} of #{@repeat})"
      
      rescue Curl::Err::HostResolutionError => e
        puts "failed (host resolution error, attempt #{i} of #{@repeat})"
      rescue Curl::Err::TimeoutError, Timeout::Error => e
        puts "failed (connection timed out, attempt #{i} of #{@repeat})"
      rescue Exception => e
        puts "failed (unable to handle #{e.class.name})"
        break
      ensure
        handler.close unless handler.nil?
      end
    end

    raise e || 'Unable to download'
  end
  
  protected
  
  def predownload(uri)
    path = @cache_uri_to_path.call(self, uri)

    FileUtils.mkpath(File.dirname(path)) if @cache_store
     
    content = load(path)

    return path, content
  end

  def wait
    unless @wait_time.nil? || @wait_time <= 0
      print "Waiting #{@wait_time} sec. ... "

      sleep @wait_time

      puts "done"
    end
  end 

  include Cache

  public

  alias :cache_root= :root=
  alias :cache_root  :root

  alias :cache_binary= :binary=
  alias :cache_binary  :binary

  def cache_load_and_store=(value)
    @cache_load = @cache_store = value
  end
  
  protected
  
  def load(path)
    if @cache_load
      print "Loading #{path} ... "
  
      if File.exists? path
        if File.readable? path
          unless @cache_expire_time.nil?
            delta = Time.now - File.ctime(path)
    
            if delta >= @cache_expire_time
              puts "failed (expired)"
              return nil
            end 
          end
    
          content = super path
    
          puts "done (#{content.length} bytes)"
    
          content
        else
          puts "failed (not readable)"
        end
      else
        puts "failed (not exists)"
      end
    end
  end

  def store(path, content)
    if @cache_store
      print "Storing #{path} ... "
  
      super path, content
  
      puts "done (#{content.length} bytes)"
    end
  end

  def self.uri_to_path(downloader, uri)
    uri_to_path downloader.cache_file_extension.nil? ? uri : "#{uri}.#{downloader.cache_file_extension}"
  end
end
