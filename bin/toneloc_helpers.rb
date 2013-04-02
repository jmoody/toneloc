#require 'toneloc/version'
require 'toneloc'

def print_usage
  puts <<EOF
  toneloc #{Toneloc::VERSION}
  Usage: toneloc <command> [strings | csv]
  where <command> can be one of
    validate
      searches the current directory for [strings | csv] files to validate
    help
      prints more detailed help information
EOF
end
