require 'rubygems/package'
require 'net/http'
require 'uri'
require "dcf"
require 'zlib'
require 'benchmark'
require 'debian_control_parser'

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
      packages.first(100).each do |package|
      # packages.each do |package|
        name    = package["Package"]
        version = package["Version"]

        file_name = "#{name}_#{version}.tar.gz"

        package_url = "https://cran.r-project.org/src/contrib/#{file_name}"
        # puts package_url

        download_file package_url, "./packages/#{file_name}"

        data = extract_data "./packages/#{file_name}"

        # create models
        pack = Package.find_or_initialize_by({
            name: name,
            version: version,
            date_publication: data[:date_publication],
            title: data[:title],
            description: data[:description]
          })
        # puts pack.inspect
        # puts pack.save!
        # Package
        # Author(s)
        # Maintainer(s)
      end
    end

  end

  def download_file url, file_name
    resp = Net::HTTP.get(URI.parse(url))
    IO.binwrite(file_name, resp)
  end

  def extract_data file_path
    output = {}
    tar_extract = Gem::Package::TarReader.new(Zlib::GzipReader.open(file_path))
    tar_extract.rewind # The extract has to be rewinded after every iteration
    tar_extract.each do |entry|
      if entry.full_name.include? "DESCRIPTION"
        puts entry.full_name
        puts "#"*50
        parser = DebianControlParser.new(entry.read)
        parser.paragraphs do |paragraph|
          paragraph.fields do |name, value|
            # puts "Name=#{name} / Value=#{value}"
            output[:title]            = value if name == "Title"
            output[:description]      = value if name == "Description"
            output[:date_publication] = value if name == "Date/Publication"
            # Author: Scott Fortmann-Roe
            # Maintainer: Scott Fortmann-Roe <scottfr@berkeley.edu>
            if name == "Author"
              output[:authors] = parse_authors(value)
              puts "authors => #{output[:authors]}"
              puts "-"*50
            end
            if name == "Maintainer"
              output[:maintainer] = parse_maintainer(value)
              puts "maintainer => #{output[:maintainer]}"
            end
          end
        end
        puts "#"*50
        break
      end
    end
    tar_extract.close
    output
  end

  def parse_authors value
    output = []
    value.gsub(/(\[.*\]|\sand\s|\n)/,'').split(",").map(&:strip).each do |author|
      name  = author.strip.gsub(/<.*>/,'').strip
      email = author.match(/<(.*)>/)&.captures&.first
      output << { name: name, email: email }
    end
    output
  end

  def parse_maintainer value
    {
      name:  value.strip.gsub(/<.*>/,'').strip,
      email: value.match(/<(.*)>/)&.captures&.first
    }
  end

  def realtime &block
    time = Benchmark.realtime do
      yield
    end

    puts "Time elapsed #{time*1000} milliseconds"
  end

end
