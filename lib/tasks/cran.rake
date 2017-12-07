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

        package_file_name = "#{package_name}_#{package_version}.tar.gz"

        package_url = "https://cran.r-project.org/src/contrib/#{package_file_name}"
        puts package_url

        download_file package_file_name

      end
    end

  end

  def download_file file_name
    # url_base = "https://cran.r-project.org/src/contrib"
    # url = "#{url_base}/#{file_name}"
    # f = open("./packages/#{file_name}", "w")
    Net::HTTP.start("cran.r-project.org") do |http|
      resp = http.get("/src/contrib/#{file_name}")
      open("./packages/#{file_name}", "wb") do |file|
        file.write(resp.body)
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
