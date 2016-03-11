require "coverage.so"
require "colored"

class Unrun
  class << self
    def start
      Coverage.start

      if block_given?
        yield
        report
      end
    end

    def report
      files_to_coverage_info = Coverage.result
      text_diff = `git diff HEAD`.chomp

      files_and_ranges = {}

      current_file = nil
      current_range = []

      text_diff.split("\n").each do |line|
        if line =~ /diff --git a\/(.*) b\/(.*)/
          file = $2.strip
          puts "file is: #{file}"

          if file =~ /\.(rb|rake)$/
            current_file = File.expand_path(file)
          else
            current_file = nil
          end
        elsif line =~ /^@@ \-.* \+(\d+)\,(\d+) @@/
          puts "line: #{line}, current_file: #{current_file}"
          next if !current_file
          current_range = [$1.to_i, $1.to_i + $2.to_i]

          files_and_ranges[current_file] ||= []
          files_and_ranges[current_file] << current_range
        end
      end

      files_and_ranges.each do |file, ranges|
        contents = File.read(file)
        lines = contents.split("\n")

        ranges.each do |range|
          start = range.first
          last = range.last

          start = start - 2
          last = last - 2

          start.upto(last) do |lineno|
            line = lines[lineno]

            if !line
              puts "NO LINE".red
              next
            end

            if files_to_coverage_info[file]
              coverage_info = files_to_coverage_info[file][lineno]
            else
              coverage_info = 0
            end

            line = if coverage_info == 1
              line.green
            elsif coverage_info == 0
              line.black_on_red
            else
              line.yellow
            end

            puts "%3d %s" % [lineno, line]
          end
        end
      end
    end
  end
end