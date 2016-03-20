require "coverage.so"
require "colored"
require "rugged"

class Unrun
  def self.start
    Coverage.start

    if block_given?
      yield
      report
    end
  end

  def self.report
    files_to_coverage_info = Coverage.result
    repository = Rugged::Repository.discover(".")

    # get the diff - equivalent to git diff HEAD
    diff = repository.head.target.tree.diff(repository.index)
    text_diff = diff.patch

    files_and_ranges = {}

    current_file = nil
    current_range = []

    text_diff.split("\n").each do |line|
      if line =~ /diff --git a\/(.*) b\/(.*)/
        file = $2
        current_file = File.expand_path(file)
      elsif line =~ /^@@ \-.* \+(\d+)\,(\d+) @@/
        current_range = [$1.to_i, $2.to_i]

        files_and_ranges[current_file] ||= []
        files_and_ranges[current_file] << current_range
      end
    end

    files_and_ranges.each do |file, ranges|
      # puts "files_to_coverage_info: #{files_to_coverage_info}"
      res = files_to_coverage_info[file]

      if !res
        puts "file: #{file} not covered!".red
        next
      end

      contents = File.read(file)
      lines = contents.split("\n")

      ranges.each do |range|
        start = range.first
        last = range.last

        start = start - 1
        last = last - 1

        start.upto(last) do |lineno|
          line = lines[lineno]
          coverage_info = files_to_coverage_info[file][lineno]
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