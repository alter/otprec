class CleanWorker
  include Sidekiq::Worker
  def perform()
    Record.where('end_date < ?', Time.now).destroy_all
  end
end

job = Sidekiq::Cron::Job.new( name: 'Clean worker - every 10min', cron: '*/10 * * * *', klass: 'CleanWorker')

unless job.save
  puts job.errors #will return array of errors
end

job.enable!
job.enque!
job.status
