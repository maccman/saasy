#!/usr/bin/env ruby
$:.unshift '../lib'
#
# puts this script in an nfs located directory and run from a couple of nodes at
# once.  the list should appear ordered from either host - note that times may
# not be ordered depending on the system clocks
#

#
# builtin
#
  require 'socket'
  require 'pstore'
#
# do what we can to invalidate any nfs caching
#
  def timestamp time = Time.now
#{{{
    usec = "#{ time.usec }"
    usec << ('0' * (6 - usec.size)) if usec.size < 6 
    time.strftime('%Y-%m-%d %H:%M:%S.') << usec
#}}}
  end
  def hostname
#{{{
    @__hostname__ ||= Socket::gethostname
#}}}
  end
  def tmpnam dir = Dir.tmpdir, seed = File.basename($0)
#{{{
    pid = Process.pid
    path = "%s_%s_%s_%s_%d" % 
      [hostname, seed, pid, timestamp.gsub(/\s+/o,'_'), rand(101010)]
    File.join(dir, path)
#}}}
  end
  def uncache file 
#{{{
    refresh = nil
    begin
      is_a_file = File === file
      path = (is_a_file ? file.path : file.to_s) 
      stat = (is_a_file ? file.stat : File.stat(file.to_s)) 
      refresh = tmpnam(File.dirname(path))
      File.link path, refresh rescue File.symlink path, refresh
      File.chmod stat.mode, path
      File.utime stat.atime, stat.mtime, path
    ensure 
      begin
        File.unlink refresh if refresh
      rescue Errno::ENOENT
      end
    end
#}}}
  end
#
# raa - http://raa.ruby-lang.org/project/lockfile/
#
  require 'lockfile'
  pstore = PStore.new 'test.db'
  timeout = 60
  max_age = 8
  refresh = 2
  debug = false
  lockfile = Lockfile.new 'test.lock', 
                          :timeout => timeout,
                          :max_age => max_age,
                          :refresh => refresh,
                          :debug   => debug
#
# flock throws ENOLCK on nfs file systems in newer linux kernels
# plus we want to show that lockfile alone can do the locking
#
  class File
    def flock(*args,&block);true;end
  end
#
# if locking does not work this loop will blow up (Marshal load error) or appear
# un-ordered.  actually it will eventually blow up due to nfs caching - but that
# is not the fault of the lockfile class!  for the most part it is a simply demo
# of locking.  the file will never become corrupt, it just will be unreadable at
# times due to kernel caching.
#
  loop do
    lockfile.lock do
      uncache pstore.path 
      pstore.transaction do
      #
      # get/update list
      #
        pstore[:list] = [] unless pstore.root? :list
        list = pstore[:list]
        tuple = [list.size, hostname, Time.now.to_f]
        list << tuple
      #
      # show last 16 elements
      #
        puts '---'
        list[-([list.size, 16].min)..-1].each{|tuple| p tuple}
        puts '---'
      #
      # keep it a reasonable size
      #
        list.shift while list.size > 1024
      #
      # write back updates
      #
        pstore[:list] = list
      end
    end
    sleep 1 
  end
