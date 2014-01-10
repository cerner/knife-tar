require 'tmpdir'

class TmpDirectory
  
  attr_reader :path
  
  def initialize name="tmp"
    @path = ::File.join(Dir.tmpdir, "#{name}-#{Time.now.strftime("%Y%m%d%H%M%S")}-#{Random.rand}")
    
    FileUtils.mkdir_p @path
    
    #Add shutdown hook to remove tar tmp directory
    Kernel.at_exit do 
      cleanup
    end
  end
  
  private
  
  #Remove the created temp directory
  def cleanup
    FileUtils.rm_rf @path
  end
  
end