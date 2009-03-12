require 'open3'

class Yaska

  @@GRAMMARDIR = "test"
  @@GRAMMARFILE = "Test.g"
  @@TESTFILE = "com.yaska.TestYaska"  # make sure to include the package name if applicable

  # compile the grammar, spit out any warnings
  # return the warning count
  def compile
    stdin, stdout, stderr = Open3.popen3("java org.antlr.Tool #{@@GRAMMARDIR}/#{@@GRAMMARFILE}")
    eput = []
    stderr.each do |line| eput << line end

    eput.each do |line|
      puts line
    end

    IO.popen("javac #{@@GRAMMARDIR}/#{File.basename(@@GRAMMARFILE, '.g')}*.java") do |io|
      io.each_line {}
    end

    return eput.count
  end

  # main event loop
  # check for file changes every 2 seconds
  # compile, test, check for any changes
  def start
  cwcount = 0
  rwcount = 0

  last = nil

  loop do
    current = File.mtime "#{@@GRAMMARDIR}/#{@@GRAMMARFILE}"

    if last.nil? || last < current
    
      comwarn = compile

      # run
      stdin, stdout, stderr = Open3.popen3("java org.junit.runner.JUnitCore #{@@TESTFILE}")

      # output stdout (errors)
      oput = []
      stdout.each do |line| oput << line end
      sout = oput.join

      oput.each do |line|
        puts line
      end

      # out put stderr (warnings)
      eput = []
      stderr.each do |line| eput << line end

      runwarn = eput.count
      eput.each do |line|
        puts line
      end

      # testing errors
      if sout.match("FAILURES!!!") then
        puts "\033[1m\033[31m\033[40m Broke a Test! \033[0m"
      else
        puts "\033[1m\033[32m\033[40m Passing all Tests! \033[0m"
      end

      # compilation warnings
      puts "\033[1m\033[30m\033[40m Compile-Time Warnings \033[0m"
      puts "\033[1m\033[30m\033[40m -----------------\033[0m"

      if cwcount < comwarn then
        puts "\033[1m\033[31m\033[40m #{comwarn} Warnings: Generating more! \033[0m"
      elsif cwcount.eql? comwarn then
        puts "\033[1m\033[33m\033[40m #{comwarn} Warnings: Generating the same number! \033[0m"
      else
        puts "\033[1m\033[32m\033[40m #{comwarn} Warnings: Generating less! \033[0m"
      end
      cwcount = comwarn

      # runtime warnings
      puts "\033[1m\033[30m\033[40m Runtime Warnings \033[0m"
      puts "\033[1m\033[30m\033[40m -----------------\033[0m"

      if rwcount < runwarn then
        puts "\033[1m\033[31m\033[40m #{runwarn} Warnings: Generating more! \033[0m"
      elsif rwcount.eql? runwarn then
        puts "\033[1m\033[33m\033[40m #{runwarn} Warnings: Generating the same number! \033[0m"
      else
        puts "\033[1m\033[32m\033[40m #{runwarn} Warnings: Generating less! \033[0m"
      end

      rwcount = runwarn

      last = current
    end

    sleep 2
  end

  end

end

ya = Yaska.new
ya.start
