knife-tar
=========

Description
-----------

A knife plugin facilitating uploading chef components from a tar.gz file/url to your 
chef server as well as downloading components from chef-server to tar.gz format.

Why?
----

This originally started when we were looking into the best way to 'release' our
cookbooks. Numerous sources online will tell you that the suggested way to 'release'
a cookbook is to create a tag in your source control manager and upload your cookbook
from that tag. There are even chef plugins for uploading cookbooks from git as well as
other tools like [berkshelf](http://berkshelf.com/) that allow you to download cookbooks 
from github. This idea didn't really mesh well with the way we would release our artifacts 
which was to push everything into an artifact repository. From there we came up with the idea of 
dropping all of our cookbook's files into a tar file and push that out to our 
repositories.

Being beginners at chef we often ran into the issue where we wanted to upload our cookbook 
to the chef-server but we forgot to include the dependencies. From that we decided our tar 
file should support multiple cookbooks so we could include cookbook dependencies. At that 
point others were asking about adding support for roles or environments, that is when we 
realized we could support all of the chef components and modeled the format after Opscode's 
[chef-repo](https://github.com/opscode/chef-repo). From there we included the download 
functionality and supported multiple versions of the same cookbook.

Installation
------------

Install the chef gem prior to installing knife-tar.

    gem install knife-tar

Requirements
------------

* Chef >= 0.10.10 (Does not work with Chef 11)
* `tar` is installed and on your `$PATH`

Conventions
-----------

### Tar File Structure

The knife-tar plugin focuses to allow a tar file to be used to upload a variety of chef components. Therefore 
the tar file must be created in a specific way. We tried to follow the chef-repo structure seen here
(https://github.com/opscode/chef-repo).

We assume that the tar file will look like,

\[tarName\].tar.gz  
|- cookbooks  
| |- \[cookbookName\] | \[cookbookName\]-\[cookbookVersion\]  
|- data_bags  
| |- \[dataBagName\]  
| | |- \[valueName\].\[json|js|rb\]  
|- environments  
| |- \[environmentName\].\[json|js|rb\]  
|- roles  
| |- \[roleName\].\[json|js|rb\]  
|- web_users  
| |- \[webUserName\].\[json|js|rb\]  
|- api_clients  
| | - \[clientName\].\[json|js|rb\]  
|- nodes  
| |- \[nodeName\].\[json|js|rb\]  

OR

\[tarName\].tar.gz  
|- \[projectName\]   
| |- cookbooks  
| | |- \[cookbookName\] | \[cookbookName\]-\[cookbookVersion\]    
| |- data_bags  
| | |- \[dataBagName\]  
| | | |- \[valueName\].\[json|js|rb\]  
| |- environments  
| | |- \[environmentName\].\[json|js|rb\]  
| |- roles  
| | |- \[roleName\].\[json|js|rb\]  
| |- web_users  
| | |- \[webUserName\].\[json|js|rb\]  
| |- api_clients  
| | | - \[clientName\].\[json|js|rb\]  
| |- nodes  
| | |- \[nodeName\].\[json|js|rb\]  

### Chef Cookbook Names

In order to support uploading multiple versions of the same cookbook the following directory names are valid for cookbooks,

* \[cookbookName\] (i.e. java)
* \[cookbookName\]-\[cookbookVersion\] (i.e. java-1.0.2)

### Chef Component File Extensions

All chef components files (i.e. all components except cookbooks) must end in the proper extension
either '.js', '.json' or '.rb' defined by Chef.

### Additional Notes

The root directory (or \[projectName\]) in the second structure can be anything except the names of the chef components 
(cookbooks, data_bags, environments, roles...)

You do not have to have all of the directories in your tar file in order to use the knife-tar plugin. 
You only need the directories that have the components you want to use with knife-tar. So if you only want to use 
it to upload cookbooks a valid tar file could look like,

\[tarName\].tar.gz  
|- cookbooks  
| |- \[cookbookName\]  

OR

\[tarName\].tar.gz  
|- \[projectName\]  
| |- cookbooks  
| | |- \[cookbookName\]  

Usage
-----

In all of the below instances, 'tarPath' can be either the path
to your tar file on your local filesystem or a url.

### Uploading 

#### Everything

**NOTE**: If you have api clients in your tar file this command requires that you 
either be running on the chef-server or have configured 'couchdb_url' in your 
knife.rb to work properly.

If you want to upload all your chef resources from your tar file you can use the
following command,

Command: 'knife tar upload tarPath (options)'

#### Cookbooks

If you want to upload only your cookbooks from your tar file you can use the
following command,

Command: 'knife cookbook tar upload tarPath (options)'

#### Roles

If you want to upload only your roles from your tar file you can use the
following command,

Command: 'knife role tar upload tarPath (options)'

#### Data Bags

If you want to upload only your data bags from your tar file you can use the
following command,

Command: 'knife data bag tar upload tarPath (options)'

#### Environments

If you want to upload only your environment from your tar file you can use the
following command,

Command: 'knife environment tar upload tarPath (options)'

#### Nodes

If you want to upload only your nodes from your tar file you can use the
following command,

Command: 'knife node tar upload tarPath (options)'

#### Web UI Users

If you want to upload only your users from your tar file you can use the
following command,

Command: 'knife user tar upload tarPath (options)'


#### API Clients

**NOTE**: This command requires that you either be running on the chef-server or
have configured 'couchdb_url' in your knife.rb to work properly.

If you want to upload only your clients from your tar file you can use the
following command,

Command: 'knife client tar upload tarPath (options)'

### Downloading

#### Everything

If you want to download all of your chef resources from chef-server to a tar
file you can use the following command,

Command: 'knife tar download tarPath (options)'

#### Cookbooks

If you want to download all your cookbooks from chef-server to a tar file you
can use the following command,

Command: 'knife cookbook tar download tarPath (options)'

#### Data Bags

If you want to download all your data bags from chef-server to a tar file you
can use the following command,

Command: 'knife data bag tar download tarPath (options)'

#### Environments

If you want to download all your environments from chef-server to a tar file you
can use the following command,

Command: 'knife environment tar download tarPath (options)'

#### Nodes

If you want to download all your nodes from chef-server to a tar file you
can use the following command,

Command: 'knife node tar download tarPath (options)'

#### Roles

If you want to download all your roles from chef-server to a tar file you
can use the following command,

Command: 'knife role tar download tarPath (options)'

#### Api Clients

If you want to download all your api clients from chef-server to a tar file you
can use the following command,

Command: 'knife client tar download tarPath (options)'

#### Web UI Users

If you want to download all your web ui users from chef-server to a tar file you
can use the following command,

Command: 'knife user tar download tarPath (options)'

Author
------

Bryan Baugher  
Bryan.Baugher@Cerner.com

Contributing
------------

This project is licensed under the Apache License, Version 2.0.

When contributing to the project please add your name to the CONTRIBUTORS.txt file. Adding your name to the CONTRIBUTORS.txt file
signifies agreement to all rights and reservations provided by the License.

To contribute to the project execute a pull request through github. The pull request will be reviewed by the community and merged 
by the project committers. Please attempt to conform to the test, code conventions, and code formatting standards if any
are specified by the project before submitting a pull request.

LICENSE
-------

Copyright 2014 Cerner Innovation, Inc.

Licensed under the Apache License, Version 2.0 (the 'License'); you may not use this file except in compliance with the License. You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0) Unless required by applicable law or agreed to in writing, software distributed 
under the License is distributed on an 'AS IS' BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language 
governing permissions and limitations under the License.
