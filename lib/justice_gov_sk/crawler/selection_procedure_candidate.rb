module JusticeGovSk
  class Crawler
    class SelectionProcedureCandidate < JusticeGovSk::Crawler
      def initialize(options)
        super(options)

        @procedure = options[:procedure]
      end

      protected

      def process(request)
        super do
          uri = JusticeGovSk::Request.uri(request)

          @candidate = selection_procedure_candidate_by_uri_factory.find_or_create(uri)

          @candidate.uri = uri
          @candidate.procedure = @procedure

          @candidate.application_url = @parser.application_url(@document)
          @candidate.curriculum_url = @parser.curriculum_url(@document)
          @candidate.declaration_url = @parser.declaration_url(@document)
          @candidate.motivation_letter_url = @parser.motivation_letter_url(@document)

          @candidate.name = @parser.name(@document)
          @candidate.name_unprocessed = @parser.name_unprocessed(@document)
          @candidate.accomplished_expectations = @parser.accomplished_expectations(@document)
          @candidate.oral_score = @parser.oral_score(@document)
          @candidate.oral_result = @parser.oral_result(@document)
          @candidate.written_score = @parser.written_score(@document)
          @candidate.written_result = @parser.written_result(@document)
          @candidate.score = @parser.score(@document)
          @candidate.rank = @parser.rank(@document)
          @candidate.judge = judge_by_name_factory.find(@candidate.name)

          download_url :application_url
          download_url :curriculum_url
          download_url :declaration_url
          download_url :motivation_letter_url

          @candidate
        end
      end

      def download_url(name)
        return if @candidate.read_attribute(name).blank?

        downloader = inject JusticeGovSk::Downloader, implementation: SelectionProcedureCandidate, suffix: :Document

        downloader.uri_to_path = lambda { |_| "#{@candidate.uri.match(/Ic=(\d+)/)[1]}_#{name.to_s.sub(/_url\Z/, '')}.pdf" }

        downloader.download @candidate.read_attribute(name)
      end
    end
  end
end
