require 'toneloc'
require 'fileutils'

module ToneLoc
  module BinHelpers

    def print_usage
      puts <<EOF
  toneloc #{Toneloc::VERSION}
  Usage: toneloc <command> [strings | csv]
  where <command> can be one of
    validate
      recursively searches the current directory for strings files to validate
      WARN: cannot validate csv files
    convert
      recursively search the current directory for [strings | csv] files that need to be converted to the other format
      WARN: deletes the [strings | csv] directory in the current directory
    help
      you are looking at it
EOF
    end

    def valid_sub_command (sub_cmd)
      res = %w(csv strings).include? sub_cmd
      unless res
        puts "invalid command '#{sub_cmd}' => must be 'csv' or 'strings'"
      end
      res
    end

  end
end


module ToneLoc
  module Collect

    def collect_paths(file_type)
      candidates = [:strings, :csv]

      unless candidates.include?(file_type)
        raise "expected '#{file_type}' to be one of '#{candidates}'"
      end

      regex = file_type == :strings ? /.*\.strings$/ : /.*\.csv$/
      strings_paths = []
      Find.find(Dir.pwd) do |path|
        if path =~ regex
          strings_paths << path
        end
      end
      strings_paths
    end

  end
end

module ToneLoc
  module ConvertStrings
    include ToneLoc::Collect

    def validate_strings
      strings_paths = collect_paths :strings
      if strings_paths.empty?
        puts "found no .strings files '#{Dir.pwd}'"
        return 1
      end

      errors = collect_strings_with_errors(strings_paths)
      valid_count = strings_paths.count - errors.count
      puts "found '#{valid_count}' valid strings files and '#{errors.count}' with errors"

      unless errors.empty?
        cur_path = Pathname.new(Dir.pwd.to_str)
        errors.each do |key, value|
          puts "'#{Pathname.new(key).relative_path_from(cur_path)}' => '#{value}'"
        end
      end
      #noinspection RubyUnnecessaryReturnStatement
      return 0
    end

    def collect_strings_with_errors (paths)
      errors = Hash.new
      paths.each do |path|
        File.open(path, 'r') do |f|
          content = f.read
          line_counter = 0
          content.each_line do |line|
            line_counter = line_counter + 1
            begin
              line.gsub!("\n", '')
            rescue => e
              errors[path] = {line_counter => e.to_s}
              break
            end
          end
        end
      end
      errors
    end


    def convert_string_files_to_csv
      string_paths = collect_paths :strings

      if string_paths.empty?
        puts 'could not find any .strings files in this directory'
        return 1
      end

      cur_path = Dir.pwd.to_str
      csv_dir = "#{cur_path}/csv"

      if Dir.exist? csv_dir
        FileUtils.rm_r csv_dir
      end

      Dir.mkdir(csv_dir)

      string_paths.each do |path|
        # numbers is strict - csv ==> commas
        # we are using tabs so we must use .txt extension
        puts "path '#{path}'"

        csv_file = "#{csv_dir}/#{File.basename(path, '.*')}.txt"

        parsed = Apfel.parse(path)
        unless parsed
          puts "could not parse '#{path}'"
          next
        end

        puts parsed

        keys = parsed.keys
        puts "keys count = '#{keys.count}'"
        #cur_path = Pathname.new(Dir.pwd.to_str)
        #rel_path = Pathname.new(path).relative_path_from(cur_path)
        comments = parsed.comments(with_keys: false)
        CSV.open(csv_file, 'w:utf-8', :col_sep => "\t") do |csv|
          keys.each_with_index do |item, index|

            val = parsed.values[index]
            comment = "#{comments[index]}"
            ## todo Apfel should try to preserve newlines in comments
            csv << [item, val, '', comment]
          end
        end
      end
    end

  end
end

module ToneLoc
  module ConvertCSV
    include ToneLoc::Collect

    def collect_strings_paths
      strings_paths = []
      Find.find(Dir.pwd) do |path|
        if path =~ /.*\.csv$/
          strings_paths << path
        end
      end
      strings_paths
    end

    def convert_csv_files_to_strings
      csv_paths = collect_paths :csv

      if csv_paths.empty?
        puts 'could not find any .csv files in this directory'
        return 1
      end

      cur_path = Dir.pwd.to_str
      strings_dir = "#{cur_path}/strings"

      if Dir.exists? strings_dir
        FileUtils.rm_r  strings_dir
      end

      Dir.mkdir(strings_dir)

      csv_paths.each do |path|
        strings_file = "#{strings_dir}/#{File.basename(path, '.*')}.strings"

        File.open(strings_file, 'w', encoding: 'UTF-16') { |file|
          CSV.foreach(path) do |row|

            unless row.count >= 4
              raise "row has only '#{row.count}' columns - expected at least 4 => '#{row}'"
            end

            row.compact!
            if row.count == 0
              next
            end

            begin
            # first is the key
            key = row[0]
            # second is the base lang string - ignore this

            # third is the translation
            translation = row[2] #.gsub!(/\A"|"\Z/, '')
            #if translation == nil or translation.length == 0
            #  puts "row => '#{row}'"
            #  exit 1
            #end

            # fourth this the translator comments (in base lang)
            comment = row[3]

            file.write("/* #{comment} */\n")
            file.write("\"#{key}\" = \"#{translation}\";\n")

            file.write("\n")
            rescue Exception => e
              puts "could not write '#{path}' because of row '#{row}'"
              puts "#{e}"
              exit 1
            ensure


            end
          end
        }
      end
    end

  end
end