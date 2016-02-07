require "name_parser_to_yaml/version"
require 'open-uri'
require 'nokogiri'
require 'active_support/all'

module NameParserToYaml

  class Parser

    attr_reader :country

    PARSE_URL = 'http://www.behindthename.com'

    def initialize(country)
      @country = country # array like 'english', 'czech', etc.
    end

    def generate!
      file = File.join(country + '.yml')
      File.delete(file) if File.exist?(file)

      names_in_country = get_all_names_in_country

      yamled = names_in_country.to_yaml
      File.open(file, 'w') { |file| file.write(yamled) }
    end

    def get_all_names_in_country
      country_url = get_country_url
      all_names = []

      4.times do |i|
        i += 1
        parsed_nokogiri_body = parse_with_nokogiri(country_url + '/' + i.to_s)
        all_names << parse_names_from_country(parsed_nokogiri_body)
      end

      all_names.flatten
    end

    def get_country_url
      PARSE_URL + '/names/usage/' + country
    end

    def parse_with_nokogiri(url)
      body = Nokogiri::HTML(open(url))
    end

    def parse_names_from_country(parsed_nokogiri_body)
      names_hash = []
      parsed_nokogiri_body.css('.body .browsename').each do |row_with_name|
        name = row_with_name.css('b a').first.content
        name = name.split(' ').first
        gender = row_with_name.css('span.fem, span.masc').first.content
        names_hash << { "#{name.to_s.mb_chars.downcase.to_s.humanize}" => {'gender' => gender.to_s, 'name_day' => get_name_day(name.parameterize)} }
      end
      names_hash
    end

    def get_name_day(name)
      parsed_body = parse_with_nokogiri(PARSE_URL + '/name/' + name + '/namedays')
      hrefs = parsed_body.css('.body a')
      country_href = hrefs.select{ |a| a.content.parameterize.include?(country.parameterize) }.first
      if country_href
        text_after = country_href.next.content.gsub(': ', '')
        formatted = DateTime.civil_from_format(:local, text_after.split(' ').second.to_i, Date::MONTHNAMES.index("#{text_after.split(' ').first}"))
        return formatted.to_date.to_formatted_s(:short).to_s[1..-1]
      else
        return nil
      end
    end

  end
end
