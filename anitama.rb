#!env ruby
require 'pp'
require 'open-uri'
require 'thread'
require 'date'
require 'fileutils'
require 'net/http'

def get_radio2(radio, date, flag=false)
  pp [ filename = @downpath + '/' + "anitama_#{radio}_#{date}.flv",
    url = "http://streaming.digirise.jp/anitama/player/#{radio}_#{date}_net.flv"
  ]

  req = Net::HTTP.new("streaming.digirise.jp", 80)
  h = req.request_head("/anitama/player/#{radio}_#{date}_net.flv")
  case h
  when Net::HTTPNotFound
    warn "HTTPNotFound -- #{radio}_#{date}"
    return nil if flag
    # gori-oshi

    get_radio2(
      radio,
      (Date.parse(date) + 7).strftime("%y%m%d"),
      true) or
    get_radio2(
      radio,
      (Date.parse(date) - 7).strftime("%y%m%d"),
      true)
  when Net::HTTPOK
    `wget -nc #{url} -O #{filename}`
    warn "returning #{filename}"
    return filename
  end
end

def split_audio(path)
  puts "splitflv: #{path}"
  begin
    `ffmpeg -v warning -n -i #{path} -acodec copy #{path}.mp3`
  rescue
    puts "error: #{$!} -- split audio"
  end
end

def main
  if `hostname`.chomp == "arch-laptop"
    p @downpath = "/srv/http/podcast/anitama"
  elsif RUBY_PLATFORM =~ /linux/
    p @downpath = File::expand_path("~/Archives/radio/anitama")
  else
    p @downpath = "D:/Desktop"
  end

  # anitama.com/radio : update in every Wednesday?
  # thus, you can download BEFORE the last Wednesday
  d = Date.today

  if d.cwday < 3
    last_Wednesday = d - d.cwday - 4
  else
    last_Wednesday = d - d.cwday + 3
  end

  day_masakano = (last_Wednesday - 3).strftime("%y%m%d") # Sun
  day_momonoki = (last_Wednesday - 6).strftime("%y%m%d") # Thu
  day_moja     = (last_Wednesday - 6).strftime("%y%m%d") # Thu
  day_maejo    = (last_Wednesday - 5).strftime("%y%m%d") # Fri

  ret = [
    get_radio2("masakano" , day_masakano),
    get_radio2("momonoki" , day_momonoki),
    get_radio2("moja"     , day_moja),
    get_radio2("maejo"    , day_maejo)
  ]

  pp ret

  ret.each do |path|
    next unless path
    split_audio(path)
  end
end

main
