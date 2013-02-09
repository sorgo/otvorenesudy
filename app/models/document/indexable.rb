module Document
  module Indexable

    def self.included(base)
      base.send(:extend,  ClassMethods)
      base.send(:include, Tire::Model::Search)

      base.configure
    end

    module ClassMethods

      def config
        YAML.load_file(File.join(Rails.root, 'config', 'elasticsearch.yml')).symbolize_keys
      end

      def configure(params = {})
        settings = config[:index]

        settings.deep_merge!(params)

        tire.settings.deep_merge!(settings)
      end

      def mappings
        @mappings = {}

        yield

        tire.mapping do
          @mappings.each do |field, value|
            options  = value[:options]

            type     = options[:type]     || :string
            analyzer = options[:analyzer] || 'text_analyzer'  

            if value[:type].eql? :mapped

              indexes field, options.merge!(index: :not_analyzed)

            else
              
              indexes field, options.deep_merge!(
                  type:   'multi_field', 
                  fields: {
                    analyzed:  { type: type,  analyzer: analyzer },
                    untouched: { type: type,  index: :not_analyzed }
                  }
              )
            end

          end
        end

      end

      def map(field, options = {})
        @mappings[field] = {}

        @mappings[field][:type]    = :mapped
        @mappings[field][:options] = options 
      end

      def analyze(field, options = {})
        @mappings[field] = {}

        @mappings[field][:type]    = :analyzed
        @mappings[field][:options] = options
      end

    end
  end
end