require 'rake'
require 'rake/testtask'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "douban"
    s.summary = "A Ruby wrapper of Douban(豆瓣) API"
    s.email = "zhangyuanyi@gmail.com"
    s.homepage = "http://github.com/yzhang/douban"
    s.description = "A Ruby wrapper of Douban(豆瓣) API"
    s.authors = ["Yuanyi Zhang"]
    s.files =  FileList["[A-Z]*", "{lib}/**/*", '.gitignore']
    s.add_dependency 'oauth'
  end
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end