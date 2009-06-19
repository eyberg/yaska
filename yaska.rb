require 'open3'
require 'Colorify'

class Yaska
  include Colorify

  attr_accessor :cwcount
  attr_accessor :rwcount
  attr_accessor :firsttime

  @@GRAMMARDIR = "grammars"
  @@GRAMMARFILE = "Test.g"
  @@PACKAGE = "com.yaska"
  @@TESTFILE = "TestYaska"

  def initialize
    @cwcount = 0
    @rwcount = 0
    @firsttime = true
  end

  # compile the grammar, spit out any warnings
  # return the warning count
  def compile
    stdin, stdout, stderr = Open3.popen3("java org.antlr.Tool #{@@GRAMMARDIR}/#{@@GRAMMARFILE}")
    eput = []
    stderr.each do |line| eput << line end

    ecount = 0
    eput.each do |line|
      puts line
      if !line.match(/error|warning/).nil? then ecount += 1 end
    end

    IO.popen("javac #{@@GRAMMARDIR}/#{File.basename(@@GRAMMARFILE, '.g')}*.java") do |io|
      io.each_line {}
    end

    return ecount
  end

  # main event loop
  # check for file changes every 2 seconds
  # compile, test, check for any changes
  def start
    ttop = nil    # last unit-test modification-time
    gtop = nil    # last grammar modification-time

    puts colorBlue("Testing #{@@GRAMMARFILE}")

    loop do
      tcurrent = File.mtime "#{@@TESTFILE}.java"
      gcurrent = File.mtime "#{@@GRAMMARDIR}/#{@@GRAMMARFILE}"

      if ttop.nil? || ttop < tcurrent || gtop < gcurrent
        runtests
        gtop = gcurrent
        ttop = tcurrent
      end

      sleep 2
    end
  end


  # compile and run the tests
  def runtests
    comwarn = compile

    # run
    stdin, stdout, stderr = Open3.popen3("javac #{@@TESTFILE}.java; java org.junit.runner.JUnitCore #{@@PACKAGE}.#{@@TESTFILE}")

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
      puts colorRed("Broke a Test!")
    else
      puts colorGreen("Passing all Tests!")
    end

    # compilation warnings
    puts colorBlack("Compile-Time Warnings")
    puts colorBlack("-----------------")

    msg = "#{comwarn} Warnings"
    if @cwcount < comwarn and !@firsttime then
      puts colorRed("#{msg}: Generating more!")
    elsif @cwcount.eql? comwarn and !@firsttime then
      puts colorYellow("#{msg}: Generating the same number!")
    elsif !@firsttime
      puts colorGreen("#{msg}: Generating less!")
    elsif @firstttime and comwarn.eql? 0
      puts colorGreen("#{msg}: No Errors!")
    else
      puts colorRed("#{msg}: Uh-oh!")
    end
    @cwcount = comwarn

    # runtime warnings
    puts colorBlack("Runtime Warnings")
    puts colorBlack("-----------------")

    msg = "#{runwarn} Warnings"
    if @rwcount < runwarn and !@firsttime then
      puts colorRed("#{msg}: Generating more!")
    elsif @rwcount.eql? runwarn and !@firsttime then
      puts colorYellow("#{msg}: Generating the same number!")
    elsif !@firsttime
      puts colorGreen("#{msg}: Generating less!")
    elsif @firsttime and runwarn.eql? 0
      puts colorGreen("#{msg}: No errors!")
    else
      puts colorRed("#{msg}: Uh-oh!")
    end

    @rwcount = runwarn

    # set firsttime flag
    @firsttime = false
  end

end

ya = Yaska.new
ya.start
