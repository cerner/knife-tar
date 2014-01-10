
require 'open-uri'
require 'chef/mixin/command'
require 'tmp_directory'

#A class for handling a tar file that contains chef components.

class Chef
  class TarFile
    
    #The named conventions for chef components
    COOKBOOKS_PATH = "cookbooks"
    ROLES_PATH = "roles"
    ENVIRONMENTS_PATH = "environments"
    DATA_BAGS_PATH = "data_bags"
    API_CLIENTS_PATH = "api_clients"
    WEB_USERS_PATH = "web_users"
    NODES_PATH = "nodes"
    
    #A list of valid chef file extensions
    CHEF_FILE_EXTENSIONS = [".js", ".json", ".rb"]
    
    def initialize tarPath, create=false
      
      if tarPath==nil
        raise ArgumentError, "A tar file path must be given"
      end
      
      @create_tar = create
      
      unless create
        @temp_directory = TmpDirectory.new.path
        
        #Assume for now that the components live directly inside the tar file
        @tar_contents_path = @temp_directory
        
        localTarFile = File.join(@temp_directory, 'cookbooks.tgz')
      
        #Move/Download tar file to tmp directory
        File.open(localTarFile, 'wb') do |f|
          open(tarPath) do |r|
            f.write(r.read)
          end
        end
      
        #Untar file
        Chef::Mixin::Command.run_command(:command => "tar zxfC #{localTarFile} #{@temp_directory}")
        
        #Verify tar file structure and update tar_contents_path if necessary
        
        dirList = get_directories_names @tar_contents_path
        
        if !is_tar_valid? dirList
          #The tar does not contain any immediate chef component directories, check to see if there is a top-level project folder
          #that contains any chef component directories
          
          if dirList.size!=1 or !is_tar_valid? get_directories_names(File.join(@tar_contents_path, dirList.first))
            raise InvalidStructureError, "The tar file has an invalid structure"
          end
          
          #The tar file is valid but contains a top-level project folder so update the @tar_contents_path
          @tar_contents_path = File.join(@tar_contents_path, dirList.first)
        end
        
        #Remove tar file
        FileUtils.rm_f localTarFile
        
      else
        
        # Verify that the tarPath doesn't already exist
        if File.exists? tarPath
          raise ArgumentError, "We cannot create a tar file at path : #{tarPath} because it already exists"
        end
        
        @temp_directory = TmpDirectory.new("chef-server").path
        
        #We will create the tar file such that their is no single root directory inside the tar file
        @tar_contents_path = @temp_directory
        
        FileUtils.mkdir_p @temp_directory
        
        @create_tar_path = File.absolute_path tarPath
        
        # We are setting up a directory to become a Chef TarFile so create the resource directories
        FileUtils.mkdir_p File.join @tar_contents_path, COOKBOOKS_PATH
        FileUtils.mkdir_p File.join @tar_contents_path, ROLES_PATH
        FileUtils.mkdir_p File.join @tar_contents_path, ENVIRONMENTS_PATH
        FileUtils.mkdir_p File.join @tar_contents_path, DATA_BAGS_PATH
        FileUtils.mkdir_p File.join @tar_contents_path, API_CLIENTS_PATH
        FileUtils.mkdir_p File.join @tar_contents_path, WEB_USERS_PATH
        FileUtils.mkdir_p File.join @tar_contents_path, NODES_PATH
        
      end
      
    end
    
    #Returns the absolute path to the cookbooks directory
    def cookbooks_path
      verify_path COOKBOOKS_PATH
      File.join @tar_contents_path, COOKBOOKS_PATH
    end
    
    #Returns list of absolute paths of the cookbooks
    def cookbooks
      get_directories_absolute_paths cookbooks_path
    end
    
    #Returns the absolute path to the roles directory
    def roles_path
      verify_path ROLES_PATH
      File.join @tar_contents_path, ROLES_PATH
    end
    
    #Returns a list of absolute paths to the roles json files
    def roles
      get_chef_files_absolute_paths roles_path
    end
    
    #Returns the absolute path to the environments directory
    def environments_path
      verify_path ENVIRONMENTS_PATH
      File.join @tar_contents_path, ENVIRONMENTS_PATH
    end
    
    #Returns a list of absolute paths to the environemnts json files
    def environments
      get_chef_files_absolute_paths environments_path
    end
    
    #Returns the absolute path to the data_bags directory
    def data_bags_path
      verify_path DATA_BAGS_PATH
      File.join @tar_contents_path, DATA_BAGS_PATH
    end
    
    #Returns a list of absolute paths to the data_bags json files
    def data_bags
      
      #Data bags follow a different structure then the other components, their structure is
      #|- data_bags
      #\ \- data_bag_1
      #| | |- values_1.json
      #| ...
      
      dir_list = get_directories_absolute_paths(data_bags_path)
      
      data_bags_absolute_paths = Array.new
      
      dir_list.each do |dir_path|
        data_bags_absolute_paths = data_bags_absolute_paths | get_chef_files_absolute_paths(dir_path)
      end
      
      data_bags_absolute_paths
    end
    
    #Returns the absolute path to the api_clients directory
    def api_clients_path
      verify_path API_CLIENTS_PATH
      File.join @tar_contents_path, API_CLIENTS_PATH
    end
    
    #Returns a list of absolute paths to the api_clients json files
    def api_clients
      get_chef_files_absolute_paths api_clients_path
    end
    
    #Returns the absolute path of the nodes directory
    def nodes_path
      verify_path NODES_PATH
      File.join @tar_contents_path, NODES_PATH
    end
    
    #Returns a list of absolute paths to the nodes json files
    def nodes
      get_chef_files_absolute_paths nodes_path
    end
    
    #Returns the absolute path of the web_users directory
    def web_users_path
      verify_path WEB_USERS_PATH
      File.join @tar_contents_path, WEB_USERS_PATH
    end
    
    #Returns a list of absolute paths to the web_users json files
    def web_users
      get_chef_files_absolute_paths web_users_path
    end
    
    def save
      if @create_tar
        
        #Tar up the directory from the parent directory of the tar's contents (this will really be /tmp)
        Chef::Mixin::Command.run_command(:cwd => File.expand_path("..",@tar_contents_path), :command => "tar zfc #{@create_tar_path} #{File.basename @tar_contents_path}")
        
        @create_tar = false
      else
        raise StandardError, "The tar file is not in the correct state to be saved"
      end
    end
    
    private
    
    #Returns true if the list of directories contains at least one chef component 
    def is_tar_valid? dir_list
      
      #Remove unnessary directories
      dir_list.delete(".")
      dir_list.delete("..")
      
      dir_list.each do |dir|
        [API_CLIENTS_PATH, COOKBOOKS_PATH, DATA_BAGS_PATH, ENVIRONMENTS_PATH, NODES_PATH, ROLES_PATH, WEB_USERS_PATH].each do |component|
          if dir == component
            return true
          end
        end
      end
      return false
    end
    
    #Throws an exception if the given component does not exist within the tar's contents
    def verify_path component
      if !File.exists? File.join @tar_contents_path, component
        raise MissingChefComponentError, "The '#{component}' directory does not exist within the tar file"
      end
    end
    
    #Returns a list of the base file names for all the directories at the given path
    def get_directories_names path
      get_directories_absolute_paths(path).map {|dir| File.basename(dir) }
    end
    
    #Returns a list of the absolute paths of all the directories at the given path
    def get_directories_absolute_paths path
      dir_list = Dir["#{path}/*/"]
      
      #Remove unnecessary directories
      dir_list.delete(File.join(path, "."))
      dir_list.delete(File.join(path, ".."))
      
      dir_list
    end
    
    #Returns a list of the base file names for all files at the given path
    def get_file_names path
      Dir.entries(path).select { |file| !File.directory? File.join(path, file) }
    end
    
    #Returns a list of the absolute paths of all the files at the given path
    def get_file_absolute_paths path
      get_file_names(path).map { |file| File.join(path, file) }
    end
    
    #Returns a list of the absolute paths of all the valid chef component files at the given path
    def get_chef_files_absolute_paths path
      get_file_absolute_paths(path).select { |file| is_valid_chef_component_file?(file) }
    end
    
    #Returns true if the filename is a valid chef component file
    def is_valid_chef_component_file? filename
      extension = File.extname(filename)
      CHEF_FILE_EXTENSIONS.each do |validExtension|
        if extension.casecmp(validExtension) == 0
          return true
        end
      end
      return false
    end
    
    #Error when a Chef::TarFile does not have the correct structure
    class InvalidStructureError < StandardError; end
    
    #Error thrown when a chef component that is accessed cannot be found
    class MissingChefComponentError < StandardError; end
    
  end
end
