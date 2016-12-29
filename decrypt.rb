#!/usr/bin/env ruby

require 'tmpdir'
require 'shellwords'
require 'security'

def crypt(path: nil, password: nil, encrypt: true)
  if password.to_s.strip.length == 0 && encrypt
    raise "No password supplied"
  end

  tmpfile = File.join(Dir.mktmpdir, "temporary")
  command = ["openssl aes-256-cbc"]
  command << "-k #{password.shellescape}"
  command << "-in #{path.shellescape}"
  command << "-out #{tmpfile.shellescape}"
  command << "-a"
  command << "-d" unless encrypt
  command << "&> /dev/null" unless $verbose # to show show an error message is something goes wrong
  success = system(command.join(' '))

  raise ("Error decrypting '#{path}'") unless success
  FileUtils.mv(tmpfile, path)
end

password = ARGV[0]
source_path = ARGV[1] || "./"
Dir[File.join(source_path, "**", "*.{cer,p12,mobileprovision}")].each do |path|
  next if File.directory?(path)
  crypt(path: path, password: password, encrypt: false)
end
