require 'net/http'
require 'uri'
require "dcf"
require 'benchmark'

namespace :cran do
  desc "Index CRAN packages"
  task index_r_packages: :environment do

    url = "https://cran.r-project.org/src/contrib/PACKAGES"

    packages_page_content = Net::HTTP.get(URI.parse(url))

    packages = nil
    realtime do
      packages = Dcf.parse packages_page_content
    end

    realtime do
      packages.first(10).each do |package|
      # packages.each do |package|
        package_name    = package["Package"]
        package_version = package["Version"]

        package_url = "https://cran.r-project.org/src/contrib/#{package_name}_#{package_version}.tar.gz"
        puts package_url
      end
    end

  end

  def realtime &block

    time = Benchmark.realtime do
      yield
    end

    puts "Time elapsed #{time*1000} milliseconds"
  end

end
