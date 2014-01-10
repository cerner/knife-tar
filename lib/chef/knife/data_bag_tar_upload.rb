require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'

class Chef
  class Knife
    class DataBagTarUpload < Chef::Knife

      banner "knife data bag tar upload tarPath [options]"
      category "data bag tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first)
        DataBagTarUpload.upload_data_bags tar_file
        
      end
      
      def self.upload_data_bags(tar_file)
        data_bag_from_file = Chef::Knife::DataBagFromFile.new
        
        tar_file.data_bags.each do |databag_path|
          
          #TODO: May want to consider moving this logic into TarFile.
          
          databag = File.basename(File.expand_path("..", databag_path))
          
          #In order to upload a data bag value the data bag itself must exist
          #so attempt to create it now
          
          #We make the assumption here that the parent directory of each data bag
          #file is the data bag name. 
          
          databag_create = Chef::Knife::DataBagCreate.new
          databag_create.name_args = [databag]
          databag_create.run
          
          #To upload a data bag we must know the data bag name and the path to the file
          
          data_bag_from_file.name_args = [databag, databag_path]
          data_bag_from_file.run
        end
      end

    end
  end
end