require 'chef/knife'
require 'chef/cookbook/metadata'
require 'chef/cookbook_uploader'
require 'chef/tar_file'
require 'chef/cookbook_version'
require 'chef/rest'

class Chef
  class Knife
    class CookbookTarDownload < Chef::Knife
      
      banner "knife cookbook tar download tarPath (options)"
      category "cookbook tar"
      
      # This method will be executed when you run this knife command.
      def run
        
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tarPath")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first, true)
        CookbookTarDownload.download_cookbooks tar_file
        tar_file.save
        
      end
      
      def self.download_cookbooks(tar_file)
        #Gets the list of cookbooks and their versions
        rest = Chef::REST.new(Chef::Config[:chef_server_url])
        cookbook_versions = rest.get_rest('cookbooks?num_versions=all')
        
        cookbook_versions.each do | cookbook_name, cookbook_hash |
          cookbook_hash['versions'].each do | version_hash |
            cookbook_download = Chef::Knife::CookbookDownload.new
            cookbook_download.config[:download_directory] = tar_file.cookbooks_path
            cookbook_download.name_args.push cookbook_name
            cookbook_download.name_args.push version_hash["version"]
            cookbook_download.run
          end
        end
      end
      
    end
  end
end
