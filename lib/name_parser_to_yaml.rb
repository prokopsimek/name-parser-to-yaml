require "name_parser_to_yaml/version"
require 'open-uri'
require 'nokogiri'
require 'active_support/all'
require 'yaml'

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
      names_hash = {}

      i = 1
      parsed_nokogiri_body = parse_with_nokogiri(country_url + '/' + i.to_s)

      while parsed_nokogiri_body.css('.body .browsename').any?
        puts "Parsing page: #{i}"
        names_hash = parse_names_from_country(parsed_nokogiri_body, names_hash)

        i = (i.to_i + 1)
        parsed_nokogiri_body = parse_with_nokogiri(country_url + '/' + i.to_s)
      end

      names_hash
    end

    def get_country_url
      PARSE_URL + '/names/usage/' + country
    end

    def parse_with_nokogiri(url)
      body = Nokogiri::HTML(open(url))
    end

    def parse_names_from_country(parsed_nokogiri_body, names_hash)
      puts ""
      print "Parsing name: "
      parsed_nokogiri_body.css('.body .browsename').each do |row_with_name|
        name = row_with_name.css('b a').first.content
        name = name.split(' ').first
        print "#{name}"
        gender = row_with_name.css('span.fem, span.masc').first.content
        name_day = get_name_day(name.parameterize)
        print " on #{name_day}, "
        names_hash["#{name.to_s.mb_chars.downcase.to_s.humanize}"] = {'gender' => gender.to_s, 'name_day' => name_day}
      end
      names_hash
    end

    def get_name_day(name)
      parsed_body = parse_with_nokogiri(PARSE_URL + '/name/' + name + '/namedays')
      hrefs = parsed_body.css('.body a')
      country_href = hrefs.select{ |a| a.content.parameterize.include?(country.parameterize) }.first
      if country_href
        text_after = country_href.next.content.gsub(': ', '')
        if !text_after.blank?
          formatted = DateTime.civil_from_format(:local, text_after.split(' ').second.to_i, Date::MONTHNAMES.index("#{text_after.split(' ').first}"))
          return formatted.to_date.to_formatted_s(:short).to_s[1..-1]
        else
          return nil
        end
      else
        return get_name_day_from_nameday_com(name)
        # return nil
      end
    end

    def get_name_day_from_nameday_com(name)
      first_letter = name.first.parameterize.downcase
      url = "http://www.mynameday.com/#{first_letter}.html"
      parsed_nokogiri_body = parse_with_nokogiri(url)
      found_name = parsed_nokogiri_body.css('table.excel9 td').select{ |td| td.content.parameterize.downcase.include?(name.parameterize.downcase)}
      if found_name.first
        found_name_name_day = found_name.first.previous_element.previous_element
        return found_name_name_day.content.gsub('-', ' ')
      else
        return nil
      end
    end

#     def determine_names_days
#       yaml = YAML.load_file(country + '.yml')
#       yaml = yaml.to_a
#
#       file = File.join(country + '1.yml')
#       File.delete(file) if File.exist?(file)
#
#       p yaml.first(3)
#       yaml.first(3).each do |hash|
#         p hash
#         p hash[0].key
#         p hash['name_day']
#         p hash.first
#         hash['name_day'] = get_name_day_from_nameday_com(hash.key)
# p hash
#       end
#
#
#
#       File.open(file, 'w') { |file| file.write(yaml.to_yaml) }
#     end

  end
end
