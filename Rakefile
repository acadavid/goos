require 'bundler/setup'
Bundler.require
require 'rake/testtask'

Rake::TestTask.new do |t|
  def self.server_ready? _url
    begin
      url = URI.parse(_url)
      req = Net::HTTP.new(url.host, url.port)
      res = req.request_head(url.path)
      res.code == "200"
    rescue Errno::ECONNREFUSED
      false
    end
  end

  Thread.new { system("bundle exec ruby my_app.rb") }
  next until server_ready? "http://localhost:4567/"
  t.pattern = "test/*_test.rb"
end

