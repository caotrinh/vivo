UOW Scholars
============

## Building the Project

While it's certainly possible to install this project's dependencies on your own computer, it's much easier to develop inside a virtual machine. This project includes a `Vagrantfile` which will automatically provision a suitable VM for you.

1. Download and install [VirtualBox](https://www.virtualbox.org) and [Vagrant](https://www.vagrantup.com).

2. Clone down the project with Git

3. Open a terminal in the project directory and run `vagrant up`

### Build Considerations
**Initial Build**: the first build might take some time, as Vagrant will have to download an Ubuntu system image first. Once it finishes setting up and booting a VM for you, visit http://localhost:8080/ to make sure your instance of VIVO is running.

**Memory**: Ensure that your local system has sufficient memory to run the VM - the *Vagrantfile* is configured to grant 4096M to the VM by default.
~~~~
    config.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", "4096"]
    end
~~~~

**Port Forwarding**: the *Vagrantfile* maps guest port (VM) 8080 to network port (host machine) 8080. If running on Windows, it may be the case that a service is already bound to port 8080 (e.g. McAfee runs a service bound to port 8080). If this is the case, edit the *Vagrantfile* to map to a free port and access the application via this port:

~~~~
config.vm.network "forwarded_port", guest: 8080, host: 8091
~~~~

### Configuring VIVO

While Vagrant can automate most of the project's setup, you'll still need to
configure VIVO's theme and ontology yourself.

1. In order to enable the original login UI (with username and password field):
    1. Login to vagrant machine `vagrant ssh`
    2. Replace the *widget-login.ftl* template as follows (copies the original login widget directly to the tomcat webapp directory):

        ```
        sudo cp /vagrant/vitro-core/webapp/web/templates/freemarker/widgets/widget-login.ftl /usr/local/software/vivo/templates/freemarker/widgets/widget-login.ftl
        ```

2. Go to http://localhost:8080/login and click the _Log in_ link in the top right corner
3. Log in as `vivo_root@uow.edu.au` with the password `rootPassword` and then choose a new admin password
4. Click on _Site Admin_ link in the nav menu at the top right
5. Under _Site Configuration_, click on the _Site information_ link
6. Within the _Theme_ dropdown, select _uow_ to apply the UOW theme and click _Save Changes_
7. From the admin panel, follow the _Add / Remove RDF Data_ link
8. Select the 'UOW Scholars Ontology.xml' file from this repo's 'fixtures' directory and select _add mixed RDF (instances and/or ontology)_, then click _submit_
9. From the admin panel, follow the _Add / Remove RDF Data_ link
10. Select the 'UOW Scholars Data.xml' file from this repo's 'fixtures' directory and then click _submit_ (this may take a while)

## Development Tips

- To run commands on the development VM, run `vagrant ssh` to start an SSH session into it. The project directory will be mounted at `/vagrant`, and the webapp is deployed to `/var/lib/tomcat7/webapps`.

- To recompile the application, run `sudo ant all`. Sometimes you'll have to also run `sudo service tomcat7 restart` before you'll see the updated application.

- When developing a theme, you can skip compilation and simply copy the theme over the top of the one in the build directory. Simply go to the admin panel and choose _Activate developer panel_, then within the SSH session, run the following command:

        sudo rm -rf /usr/local/software/vivo/themes/uow &&
        sudo cp -R /vagrant/themes/uow /usr/local/software/vivo/themes/uow

## Remote Debugging

- Remote debugging can be enabled by setting the _JAVA_OPTS_ variable within `/etc/default/tomcat7` to include appropriate JPDA settings:

        JAVA_OPTS="-Djava.awt.headless=true -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8000"
        
- Configuring suitable port forwarding via the Vagrant file is also advised:
  
        config.vm.network "forwarded_port", guest: 8000, host: 8000
           
      

                        