#require 'toneloc/version'
require 'toneloc'

def print_usage
  puts <<EOF
  toneloc #{Toneloc::VERSION}
  Usage: toneloc <command> [strings | csv]
  where <command> can be one of
    validate
      recursively searches the current directory for [strings | csv] files to validate
    utf8ify
      recursively search the current directory for [strings | csv] files that need to be converted to utf8
    help
      prints more detailed help information
EOF
end


def collect_strings_paths
  strings_paths = []
  Find.find(Dir.pwd) do |path|
    if path =~ /.*\.strings$/
      strings_paths << path
    end
  end
  strings_paths
end

def validate_strings
  strings_paths = collect_strings_paths
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


def valid_sub_command (sub_cmd)
  res = %w(csv strings).include? sub_cmd
  unless res
    puts "invalid command '#{sub_cmd}' => must be 'csv' or 'strings'"
  end
  res
end


def tmp_handle_csv (sub_cmd)
  res = sub_cmd == 'csv'
  if res
    puts 'csv is not supported yet'
  end
  res
end
