require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'

class Chef
  class Knife
    class TarUpload < Chef::Knife

      banner "knife tar upload tarPath [options]"
      category "tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new @name_args.first
        
        # Attempt to upload all the components in the tar file
        # If our tar file does not contain a component ignore the error and skip it
        begin
          CookbookTarUpload.upload_cookbooks tar_file
        rescue TarFile::MissingChefComponentError => e
          ui.info("No Cookbooks to upload")
        end
        
        begin
          DataBagTarUpload.upload_data_bags tar_file
        rescue TarFile::MissingChefComponentError => e
          ui.info("No data bag files to upload")
        end
        
        begin
          EnvironmentTarUpload.upload_environments tar_file
        rescue TarFile::MissingChefComponentError => e
          ui.info("No Environment files to upload")
        end
        
        begin
          NodeTarUpload.upload_nodes tar_file
        rescue TarFile::MissingChefComponentError => e
          ui.info("No Node files to upload")
        end
        
        begin
          RoleTarUpload.upload_roles tar_file
        rescue TarFile::MissingChefComponentError => e
          ui.info("No Role files to upload")
        end
        
        begin
          UserTarUpload.upload_users tar_file
        rescue TarFile::MissingChefComponentError => e
          ui.info("No User files to upload")
        end
        
      end

    end
  end
end