#!/usr/bin/env ruby

# Attempt to load platin library
begin
  require 'platin'
rescue LoadError => e
  path_to_platin=`which platin 2>/dev/null`.strip
  if File.exist?(path_to_platin)

    # look for platin lib directory assuming installed or llvm/tools directory layout
    if libdir = File.join(File.dirname(File.dirname(path_to_platin)),"lib") and File.directory?(libdir)
      $:.unshift File.join(libdir,"platin")
    elsif libdir = File.join(File.dirname(path_to_platin),"lib") and File.directory?(libdir)
      $:.unshift libdir
    end
    Gem.clear_paths
    ENV['GEM_PATH'] = File.join(libdir,"platin", "gems") + (ENV['GEM_PATH'] ? ":#{ENV['GEM_PATH']}" : "")

    require 'platin'
  else
    $stderr.puts("When trying to locate platin library - failed to locate platin executable (cmd: 'which platin')")
    raise e
  end
end

require 'tools/visualize'

include PML

class VisualizeTester
  attr_reader :errs
  def initialize(options)
    @options = options
    @errs = []
    @seen = Set.new
  end
  # combine some properties of a PML bitcode function in a pseudo hash key
  def pseudo_hash(func)
    h = [func.name]
    h << func.blocks.size
    h << func.blocks.map { |b| b.instructions.size }.reduce(:+)
    h.freeze
  end
  def test(file)
    pml = PMLDoc.from_files([file])
    VisualizeTool.default_targets(pml).each { |func_name|
      func = pml.bitcode_functions.by_name(func_name)
      h = pseudo_hash(func)
      if @seen.include? h
        puts "#{func} seen before"
        next
      end
      @seen << h
      begin
        options = @options.dup
        options.functions = [func.name]
        VisualizeTool.run(pml, options)
      rescue Interrupt => e
        raise
      rescue Exception => e
        errs << ["#{file}##{func}()",e]
      end
    }
  end
end

if __FILE__ == $0
  unless ARGV.size >= 1
    STDERR.puts "Usage: #{File.basename($0)} <target files>"
    STDERR.puts "Perform platin visualization on all .pml files given as arguments"
    exit 1
  end

  options = OpenStruct.new
  options.outdir = tmpdir = Dir.mktmpdir()
  options.show_calls=true
  options.raise_on_error=true # visualize tool shall reraise

  tester = VisualizeTester.new(options)
  #pmls = File.join([ARGV[0], '**', '*.pml'])
  #Dir.glob(pmls).each { |pml|
  #  puts "PML file: #{pml}"
  #  tester.test(pml)
  #}
  ARGV.each {|pml|
    puts "Testing PML file: #{pml}"
    tester.test(pml)
  }

  FileUtils.remove_entry tmpdir if tmpdir

  unless tester.errs.empty?
    tester.errs.each { |pml,e|
      STDERR.puts "#{pml}: #{e}"
    }
    STDERR.puts "#{tester.errs.size} error(s)"
    exit 1
  end
  STDERR.puts "#{tester.errs.size} error(s)"
  exit 0
end
