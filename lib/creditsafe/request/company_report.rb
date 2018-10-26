# frozen_string_literal: true

require "creditsafe/namespace"

module Creditsafe
  module Request
    class CompanyReport
      def initialize(company_id, custom_data, language)
        @company_id = company_id
        @custom_data = custom_data
        @language = language
      end

      # rubocop:disable Metrics/MethodLength
      def message
        message = {
          "#{Creditsafe::Namespace::OPER}:companyId" => company_id.to_s,
          "#{Creditsafe::Namespace::OPER}:reportType" => "Full",
          "#{Creditsafe::Namespace::OPER}:language" => language.to_s,
        }

        unless custom_data.nil?
          message["#{Creditsafe::Namespace::OPER}:customData"] = {
            "#{Creditsafe::Namespace::DAT}:Entries" => {
              "#{Creditsafe::Namespace::DAT}:Entry" => custom_data_entries,
            },
          }
        end

        message
      end
      # rubocop:enable Metrics/MethodLength

      private

      def custom_data_entries
        custom_data.map { |key, value| { :@key => key, :content! => value } }
      end

      attr_reader :company_id, :custom_data, :language
    end
  end
end
