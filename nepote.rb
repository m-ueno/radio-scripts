#!ruby
# -*- coding: utf-8 -*-
require 'pp'
require 'open-uri'
require 'pathname'

OUTPUT_PATH = Pathname('/srv/http/podcast/nepote/')
Dir.chdir(OUTPUT_PATH)

def download_latest_mp3
  mp3_path = ""

  open('http://www.hobirecords.com/potato/') {|f|
    while l = f.gets
      if l =~ %r|"(http://.*.mp3)"|
        mp3_path = $1
        break
      end
    end
  }

  puts "found mp3: #{mp3_path}"

  `wget -c #{mp3_path}`
end

download_latest_mp3
