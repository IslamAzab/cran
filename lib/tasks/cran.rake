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
      packages.first(1).each do |package|
      # packages.each do |package|
        name    = package["Package"]
        version = package["Version"]

        file_name = "#{name}_#{version}.tar.gz"

        package_url = "https://cran.r-project.org/src/contrib/#{file_name}"
        puts package_url

        download_file package_url, file_name

        extract_file "./packages/#{file_name}"

        # create models
        # Package
        # Author(s)
        # Maintainer(s)
      end
    end

  end

  def download_file url, file_name
    resp = Net::HTTP.get(URI.parse(url))

    IO.binwrite("./packages/#{file_name}", resp)
  end

  def extract_file file_path
    require 'rubygems/package'
    require 'zlib'

    tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(file_path))
    tar_extract.rewind # The extract has to be rewinded after every iteration
    tar_extract.each do |entry|
      if entry.full_name.include? "DESCRIPTION"
        puts entry.full_name
        puts "#"*50
        puts entry.read
        puts "#"*50
        break
      end
    end
    tar_extract.close
  end

  def realtime &block
    time = Benchmark.realtime do
      yield
    end

    puts "Time elapsed #{time*1000} milliseconds"
  end

end
