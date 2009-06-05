require 'open3'
require 'Colorify'

class Yaska
  include Colorify

  attr_accessor :cwcount
  attr_accessor :rwcount

  @@GRAMMARDIR = "grammars"
  @@GRAMMARFILE = "Test.g"
  @@PACKAGE = "com.yaska"
  @@TESTFILE = "TestYaska"

  def initialize
    @cwcount = 0
    @rwcount = 0
  end

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
    ttop = nil    # last unit-test modification-time
    gtop = nil    # last grammar modification-time

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
    stdin, stdout, stderr = Open3.popen3("java org.junit.runner.JUnitCore #{@@PACKAGE}.#{@@TESTFILE}")

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

    if @cwcount < comwarn then
      puts colorRed("#{comwarn} Warnings: Generating more!")
    elsif @cwcount.eql? comwarn then
      puts colorYellow("#{comwarn} Warnings: Generating the same number!")
    else
      puts colorGreen("#{comwarn} Warnings: Generating less!")
    end
    @cwcount = comwarn

    # runtime warnings
    puts colorBlack("Runtime Warnings")
    puts colorBlack("-----------------")

    if @rwcount < runwarn then
      puts colorRed("#{runwarn} Warnings: Generating more!")
    elsif @rwcount.eql? runwarn then
      puts colorYellow("#{runwarn} Warnings: Generating the same number!")
    else
      puts colorGreen("#{runwarn} Warnings: Generating less!")
    end

    @rwcount = runwarn

  end

end

ya = Yaska.new
ya.start
