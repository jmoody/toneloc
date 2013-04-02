require 'bundler/gem_tasks'
require './lib/toneloc/version.rb'

task :gem do
  sh 'rm -f *.gem'
  sh 'gem build toneloc.gemspec --verbose'
  sh "gem install toneloc-#{Toneloc::VERSION}.gem"
end
