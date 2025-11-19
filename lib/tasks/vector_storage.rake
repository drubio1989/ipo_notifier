namespace :vector_storage do
  task vectorize_s1_filings: :environment do
    VectorizeS1FilingsJob.perform_later
  end
end
