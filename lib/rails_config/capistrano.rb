require 'capistrano'

module RailsConfig
  module Capistrano
    def self.load_into(configuration)
      configuration.load do
        set(:conf_template) { File.join("config", "settings.local.yml.erb") }
        set(:conf_filename) { File.basename(conf_template).gsub(/\.erb$/, '') }

        namespace :settings do
          desc <<-DESC
            Creates configuration file in shared path.
          DESC
          task :setup, :roles => [:app], :except => { :no_release => true } do
            if File.exist?(conf_template)
              config = YAML::load(ERB.new(File.read(conf_template)).result(binding))
              run "mkdir -p #{shared_path}/config" 
              data = YAML::dump(config)
              top.put data, "#{shared_path}/config/#{conf_filename}"
            end
          end
  
          desc <<-DESC
            Updates the symlink for the configuration file to the just deployed release.
          DESC
          task :symlink, :roles => [:app], :except => { :no_release => true } do
            run "test -e #{shared_path}/config/#{conf_filename} && ln -nfs #{shared_path}/config/#{conf_filename} #{latest_release}/config/#{conf_filename}" 
          end
        end
      end
    end
  end
end

if instance = Capistrano::Configuration.instance
  RailsConfig::Capistrano.load_into(instance)
end
