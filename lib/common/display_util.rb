# -*- coding: utf-8 -*-

module Gren
  module DisplayUtil
    def time_s(time)
      t = time.truncate
      h = t / 3600
      t = t % 3600
      m = t / 60
      t = t % 60
      t += round(time - time.prec_i, 2)
      
      if (h > 0 && m > 0)
        "#{h}h #{m}m #{t}s"
      elsif (m > 0)
        "#{m}m #{t}s"
      else
        "#{t}sec"
      end
    end
    module_function :time_s

    def round(n, d)
      (n * 10 ** d).round / 10.0 ** d
    end
    module_function :round

    def size_s(size)
      tb = 1024 ** 4
      gb = 1024 ** 3
      mb = 1024 ** 2
      kb = 1024

      if (size >= tb)
        round(size / tb.prec_f, 2).to_s + "TB"
      elsif (size >= gb)
        round(size / gb.prec_f, 2).to_s + "GB"
      elsif (size >= mb)
        round(size / mb.prec_f, 2).to_s + "MB"
      elsif (size >= kb)
        round(size / kb.prec_f, 2).to_s + "KB"
      else
        size.to_s + "Byte"
      end
    end
    module_function :size_s

    def dump_methods(c)
      unless c.is_a?(Class)
        c = c.class
      end
      
      while (true)
        p c
        break if (c == Object)
        puts "↓  " + c.public_instance_methods(false).inspect
        c = c.superclass
      end
    end
    module_function :dump_methods
  end
end
