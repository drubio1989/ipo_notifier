namespace :vector_storage do
   desc "Vectorize company s1 filings"
  task vectorize_s1_filings: :environment do
    VectorizeS1FilingsJob.perform_now
  end
end
