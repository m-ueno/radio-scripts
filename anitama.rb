#!env ruby
# -*- coding:utf-8 -*-
require 'pp'
require 'open-uri'
require 'thread'
require 'date'
require 'fileutils'
require 'net/http'

p @downpath = '/home/share/podcast/anitama'

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
    `yes "n"| ffmpeg -v warning -i #{path} -acodec copy #{path}.mp3`
  rescue
    puts "error: #{$!} -- split audio"
  end
end

def embed_metadata(path)
  program, date = path.scan(/anitama_([a-z]+)_(\d+)/).flatten!

  # artwork
  p [:embed, program]
  artworks = Dir.glob("images/#{program}*")
  art = artworks[rand artworks.size]
  `eyeD3 --remove-image #{path}`
  `eyeD3 --to-v2.4 --add-image #{art}:FRONT_COVER #{path}`

  # tags
  metadata = {
    "maejo" => {title: "神戸前向女学院"},
    "masakano" => {title: "集まれ！昌鹿野編集部"},
    "momonoki" => {title: "モモノキファイブ"}
  }
  p data=metadata[program]
  `eyeD3 --v2 --to-v2.4 --set-encoding=utf8 --title="#{data[:title]}-#{date}" #{path}`
end

@d = Date.today
@dow = @d.cwday
def get_onair_day(dow_onair, dow_up)
  # return right onair day from day_of_weeks
  onair_day = @d - @d.cwday + dow_onair

  onair_day -= 7 if dow_onair > dow_up
  onair_day -= 7 if @dow<dow_up or (@dow==dow_up and Time.now.hour < 17)

  return onair_day.strftime("%y%m%d")
end

def main
  day_maejo    = get_onair_day(5, 1)
  day_masakano = get_onair_day(0, 2)
  day_momonoki = get_onair_day(4, 1)

  ret = [
    get_radio2("masakano" , day_masakano),
    get_radio2("momonoki" , day_momonoki),
#    get_radio2("moja"     , day_moja),
    get_radio2("maejo"    , day_maejo)
  ]

  pp ret

  ret.each do |path|
    next unless path
    split_audio(path)
    embed_metadata("#{path}.mp3")
  end
end

main
