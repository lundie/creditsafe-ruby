# frozen_string_literal: true

require "creditsafe/match_type"
require "creditsafe/namespace"

module Creditsafe
  module Request
    class FindCompany
      def initialize(search_criteria)
        check_search_criteria(search_criteria)
        @country_code = search_criteria[:country_code]
        @registration_number = search_criteria[:registration_number]
        @company_name = search_criteria[:company_name]
        @city = search_criteria[:city]
        @postal_code = search_criteria[:postal_code]
        @province = search_criteria[:province]
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def message
        search_criteria = {}

        unless company_name.nil?
          search_criteria["#{Creditsafe::Namespace::DAT}:Name"] = {
            "@MatchType" => match_type,
            :content! => company_name,
          }
        end

        unless registration_number.nil?
          search_criteria["#{Creditsafe::Namespace::DAT}:RegistrationNumber"] =
            registration_number
        end

        search_criteria["#{Creditsafe::Namespace::DAT}:Address"] = {} if province || city || postal_code || street

        unless street.nil?
          search_criteria["#{Creditsafe::Namespace::DAT}:Address"].merge!({
            "#{Creditsafe::Namespace::DAT}:Street" => street,
          })
        end

        unless city.nil?
          search_criteria["#{Creditsafe::Namespace::DAT}:Address"].merge!({
            "#{Creditsafe::Namespace::DAT}:City" => city,
          })
        end

        unless postal_code.nil?
          search_criteria["#{Creditsafe::Namespace::DAT}:Address"].merge!({
            "#{Creditsafe::Namespace::DAT}:PostalCode" => postal_code,
          })
        end

        unless province.nil?
          search_criteria["#{Creditsafe::Namespace::DAT}:Address"].merge!({
            "#{Creditsafe::Namespace::DAT}:Province" => province,
          })
        end



        build_message(search_criteria)
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/MethodLength

      private

      attr_reader :country_code, :registration_number, :city, :company_name, :postal_code, :province, :street

      def match_type
        Creditsafe::MatchType::ALLOWED[country_code.upcase.to_sym]&.first ||
          Creditsafe::MatchType::MATCH_BLOCK
      end

      def build_message(search_criteria)
        {
          "#{Creditsafe::Namespace::OPER}:countries" => {
            "#{Creditsafe::Namespace::CRED}:CountryCode" => country_code,
          },
          "#{Creditsafe::Namespace::OPER}:searchCriteria" => search_criteria,
        }
      end

      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/MethodLength
      def check_search_criteria(search_criteria)
        if search_criteria[:country_code].nil?
          raise ArgumentError, "country_code is a required search criteria"
        end

        unless only_registration_number_or_company_name_provided?(search_criteria)
          raise ArgumentError, "registration_number or company_name (not both) are " \
                               "required search criteria"
        end

        # if search_criteria[:city] && search_criteria[:country_code] != "DE"
        #   raise ArgumentError, "city is only supported for German searches"
        # end

        # if search_criteria[:postal_code] && search_criteria[:country_code] != "DE"
        #   raise ArgumentError, "Postal code is only supported for German searches"
        # end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/CyclomaticComplexity

      def only_registration_number_or_company_name_provided?(search_criteria)
        search_criteria[:registration_number].nil? ^ search_criteria[:company_name].nil?
      end
    end
  end
end
