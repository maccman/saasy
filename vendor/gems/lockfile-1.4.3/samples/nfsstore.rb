#
# How to use:
#
# db = NFSStore.new("/tmp/foo")
# db.transaction do
#   p db.roots
#   ary = db["root"] = [1,2,3,4]
#   ary[0] = [1,1.5]
# end

# db.transaction do
#   p db["root"]
# end

require "ftools"
require "digest/md5"
require "socket"

require 'lockfile'

class NFSStore
  HOSTNAME = Socket::gethostname
  class Error < StandardError
  end

  def initialize(file)
    dir = File::dirname(file)
    unless File::directory? dir
      raise NFSStore::Error, format("directory %s does not exist", dir)
    end
    if File::exist? file and not File::readable? file
      raise NFSStore::Error, format("file %s not readable", file)
    end
    @transaction = false
    @filename = file
    @lockfile = Lockfile.new "#{ @filename }.lock",:max_age=>64,:refresh=>8
    @abort = false
  end

  def in_transaction
    raise NFSStore::Error, "not in transaction" unless @transaction
  end
  private :in_transaction

  def [](name)
    in_transaction
    @table[name]
  end
  def fetch(name, default=NFSStore::Error)
    unless @table.key? name
      if default==NFSStore::Error
	raise NFSStore::Error, format("undefined root name `%s'", name)
      else
	default
      end
    end
    self[name]
  end
  def []=(name, value)
    in_transaction
    @table[name] = value
  end
  def delete(name)
    in_transaction
    @table.delete name
  end
  def roots
    in_transaction
    @table.keys
  end
  def root?(name)
    in_transaction
    @table.key? name
  end
  def path
    @filename
  end
  def commit
    in_transaction
    @abort = false
    throw :pstore_abort_transaction
  end
  def abort
    in_transaction
    @abort = true
    throw :pstore_abort_transaction
  end

  # do what we can to invalidate any nfs caching
  def uncache file 
    begin
      stat = file.stat
      path = file.path
      refresh = "%s.%s.%s.%s" % [path, HOSTNAME, $$, Time.now.to_i % 1024] 
      File.link path, refresh
      file.chmod stat.mode
      File.utime stat.atime, stat.mtime, path
    rescue Exception => e 
      warn e
    ensure
      begin
        File.unlink refresh if File.exist? refresh
      rescue Exception => e
        warn e
      end
    end
  end


  def transaction(read_only=false)
    raise NFSStore::Error, "nested transaction" if @transaction
    file = nil
    value = nil

@lockfile.lock do
      begin
        @transaction = true
        backup = @filename+"~"
        begin
          file = File::open(@filename, read_only ? "rb" : "rb+")
          orig = true
        rescue Errno::ENOENT
          raise if read_only
          file = File::open(@filename, "wb+")
        end
        #file.flock(read_only ? File::LOCK_SH : File::LOCK_EX)
        uncache file
        file.rewind
        if read_only
          @table = Marshal::load(file)
        elsif orig and (content = file.read) != ""
          @table = Marshal::load(content)
          size = content.size
          md5 = Digest::MD5.digest(content)
          content = nil		# unreference huge data
        else
          @table = {}
        end
        begin
          catch(:pstore_abort_transaction) do
            value = yield(self)
          end
        rescue Exception
          @abort = true
          raise
        ensure
          if !read_only and !@abort
            file.rewind
            content = Marshal::dump(@table)
            if !md5 || size != content.size || md5 != Digest::MD5.digest(content)
              File::copy @filename, backup
              begin
                file.write(content)
                file.truncate(file.pos)
                content = nil		# unreference huge data
              rescue
                File::rename backup, @filename if File::exist?(backup)
                raise
              end
            end
          end
          if @abort and !orig
            File.unlink(@filename)
          end
          @abort = false
        end
      ensure
        @table = nil
        @transaction = false
        file.close if file
      end
end
      value
  end
end









if __FILE__ == $0
  db = NFSStore.new("/tmp/foo")
  db.transaction do
    p db.roots
    ary = db["root"] = [1,2,3,4]
    ary[1] = [1,1.5]
  end

  1000.times do
    db.transaction do
      db["root"][0] += 1
      p db["root"][0]
    end
  end

  db.transaction(true) do
    p db["root"]
  end
end
