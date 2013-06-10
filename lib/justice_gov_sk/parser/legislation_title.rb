# encoding: utf-8

module JusticeGovSk
  class Parser
    class LegislationTitle < JusticeGovSk::Parser
      def parse(data)
        @data = data
      end

      def paragraph
        legislation[1]
      end

      def value
        @data[1].strip.squeeze(' ')
      end

      def legislation
        return *@data[0].strip.match(/\A§\s*(?<paragraph>\d+[a-z]*)\z/)
      end
    end
  end
end