namespace :fixtures do
  namespace :db do
    desc "Setups small database with production data using Resque workers"
    task setup: :environment do
      Rake::Task['crawl:courts'].invoke
      Rake::Task['crawl:judges'].invoke
      
      Rake::Task['crawl:hearings:civil'].invoke    1, 50
      Rake::Task['crawl:hearings:criminal'].invoke 1, 50
      Rake::Task['crawl:hearings:special'].invoke  1, 50
      
      DecreeForm.order(:code).all.each do |form|
        Rake::Task['crawl:decrees'].invoke form.code, 1, 10
      end
    end
    
    desc "Prints basic statistics about active database"
    task stat: :environment do
      puts "Courts: #{Court.count}"
      puts "Judges: #{Judge.count}"
      puts
      puts "Hearings civil:    #{CivilHearing.count}"
      puts "Hearings criminal: #{CriminalHearing.count}"
      puts "Hearings special:  #{SpecialHearing.count}"
      puts
      
      DecreeForm.order(:code).all.each do |form|
        puts "Decrees form #{form.code}: #{Decree.where('decree_form_id = ?', form.id).count}"
      end
    end
  end
  
  namespace :decrees do
    desc "Extract missing images of decree documents"
    task :extract_images, [:override] => :environment do |_, args|
      include Core::Pluralize
      include Core::Output
      
      args.with_defaults override: false
      
      document_storage = JusticeGovSk::Storage::DecreeDocument.instance
      image_storage    = JusticeGovSk::Storage::DecreeImage.instance
      
      document_storage.batch do |entries, bucket|
        print "Running image extraction for bucket #{bucket}, "
        print "#{pluralize entries.size, 'document'}, "
        puts  "#{args[:override] ? 'overriding' : 'skipping'} already extracted."
        
        n = 0
        
        entries.each do |entry|
          next unless args[:override] || !image_storage.contains?(entry)
         
          options = { output: image_storage.path(entry) }
          
          JusticeGovSk::Extractor::Image.extract document_storage.path(entry), options
          
          n += 1
        end
        
        puts "finished (#{pluralize n, 'document'} extracted)"
      end
    end
  end
end