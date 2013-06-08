module Sinatra
  module UrlForHelper
    # Construct a link to +url_fragment+, which should be given relative to
    # the base of this Sinatra app.  The mode should be either
    # <code>:path_only</code>, which will generate an absolute path within
    # the current domain (the default), or <code>:full</code>, which will
    # include the site name and port number.  (The latter is typically
    # necessary for links in RSS feeds.)  Example usage:
    #
    #   url_for "/"            # Returns "/myapp/"
    #   url_for "/foo"         # Returns "/myapp/foo"
    #   url_for "/foo", :full  # Returns "http://example.com/myapp/foo"
    #
    # You can also pass in a hash of options, which will be appended to the
    # URL as escaped parameters, like so:
    #
    #   url_for "/", :x => "y" # Returns "/myapp/?x=y"
    #   url_for "/foo", :x => "M&Ms" # Returns "/myapp/foo?x=M%26Ms"
    #
    # You can also specify the mode:
    #
    #   url_for "/foo", :full, :x => "y" # Returns "http://example.com/myapp/foo?x=y"
    #
    #--
    # See README.rdoc for a list of some of the people who helped me clean
    # up earlier versions of this code.
    def url_for url_fragment, mode=nil, options = nil
      if mode.is_a? Hash
        options = mode
        mode = nil
      end
      
      if mode.nil?
        mode = :path_only
      end
      
      mode = mode.to_sym unless mode.is_a? Symbol
      optstring = nil
      
      if options.is_a? Hash
        optstring = '?' + options.map { |k,v| "#{k}=#{URI.escape(v.to_s, /[^#{URI::PATTERN::UNRESERVED}]/)}" }.join('&')
      end

      case mode
      when :path_only
        base = request.script_name
      when :full
        scheme = request.scheme
        if (scheme == 'http' && request.port == 80 ||
            scheme == 'https' && request.port == 443)
          port = ""
        else
          port = ":#{request.port}"
        end
        base = "#{scheme}://#{request.host}#{port}#{request.script_name}"
      else
        raise TypeError, "Unknown url_for mode #{mode.inspect}"
      end
      "#{base}#{url_fragment}#{optstring}"
    end
  end

  helpers UrlForHelper
end
