namespace :snippets do
  desc "Recreates spec fixture data from google docs"
  task :refresh do
    require_relative 'lib/tsung_wrapper'
    require File.expand_path(File.join(TsungWrapper.root, 'lib', 'create_fixtures_from_csv'))
    TsungWrapper.project = 'cc'
    csvfile = DownloadScenarioData.download
    d = DataScenarioGenerator.new(csvfile)
    d.writeToFile
  end

end
