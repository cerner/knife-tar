require 'chef/knife'
require 'chef/knife/core/object_loader'
require 'chef/json_compat'
require 'chef/data_bag'
require 'chef/data_bag_item'

class Chef
  class Knife
    class DataBagTarDownload < Chef::Knife

      banner "knife data bag tar download tarPath [options]"
      category "data bag tar"

      def run
        #Get Arguments
        if @name_args.size != 1
          ui.info("Please specify a tar path")
          show_usage
          exit 1
        end
        
        tar_file = Chef::TarFile.new(@name_args.first, true)
        DataBagTarDownload.download_data_bags tar_file
        tar_file.save

      end
      
      def self.download_data_bags(tar_file)
        dir = tar_file.data_bags_path
        Chef::DataBag.list.each do |bag_name, url|
          system("mkdir -p #{File.join(dir, bag_name)}")
          Chef::DataBag.load(bag_name).each do |item_name, itemUrl|
            Chef::Log.info("Backing up data bag #{bag_name} item #{item_name}")
            item = Chef::DataBagItem.load(bag_name, item_name)
            File.open(File.join(dir, bag_name, "#{item_name}.json"), "w") do |dbag_file|
              dbag_file.print(item.raw_data.to_json)
            end
          end
        end
      end

    end
  end
end