require 'spec_helper'

describe RailsConfig::Capistrano do

  before do
    @configuration = Capistrano::Configuration.new
    @configuration.extend(Capistrano::Spec::ConfigurationExtension)
    RailsConfig::Capistrano.load_into(@configuration)
  end

  subject { @configuration }

  context "when running settings:setup" do
    before do
      @configuration.set :shared_path, "/tmp/rails_config/shared"
      @configuration.set :latest_release, "/tmp/rails_config/latest"
      @configuration.set :conf_template, File.expand_path('../fixtures/capistrano.yml.erb', __FILE__)
      @configuration.find_and_execute_task('settings:setup')
    end
  
    it { @configuration.fetch(:conf_filename).should == 'capistrano.yml' }
    it { should have_run('mkdir -p /tmp/rails_config/shared/config') }
  end

  context "when running settings:setup" do
    before do
      @configuration.set :shared_path, "/tmp/rails_config/shared"
      @configuration.set :latest_release, "/tmp/rails_config/latest"
      @configuration.set :conf_template, File.expand_path('../fixtures/capistrano.yml.erb', __FILE__)
      @configuration.find_and_execute_task('settings:symlink')
    end
    it { should have_run('test -e /tmp/rails_config/shared/config/capistrano.yml && ln -nfs /tmp/rails_config/shared/config/capistrano.yml /tmp/rails_config/latest/config/capistrano.yml') }
  end
end
