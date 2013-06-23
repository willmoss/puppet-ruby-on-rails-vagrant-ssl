Quick Secure Ruby On Rails (RoR) VPS : QSRoR
=============

This is a quick way to get a SSL-enabled Ruby on Rails VPS set up on a linux box from scratch, in less than 10 minutes.

It uses Puppet, so you'll always have the latest version of all packages. It's also very easy to customize any settings to your liking, and provides a good base for new RoR VPS deployments.

Features
-------

* Automated setup of an Apache/Passenger/Rails/PHP/MySQL/Ubuntu environment
* Supports adding multiple virtual host (rails) environments to the existing puppet-apache class
* Configures a custom 'webapp' user for your rails apps
* Host as many different rails apps at http://yourdomain/appname
* Supports HTTPS & HTTP
* Generation of local HTTP & HTTPS environments
* Generates custom self-signed SSL certificate for local testing
* Generation of a HTTP -> HTTPS redirect
* Also installs wordpress at http://yourdomain , so you can manage the front section of your site using a CMS
* Includes some bash scripts to upload the configuration files to your server
* No knowledge of puppet required to use this environment


Usage
-----

To get using this, just `git clone` to your local machine, then edit the main configuration file in `manifests/nodes.pp` to fit your needs.

We define a new puppet module, `apache2`, which uses the [Apache module][apache-puppet].

Eg.

    # set up apache with SSL
	  apache2::site { "bxmediaus.com-ssl":
        sitedomain => "bxmediaus.com",
        ssl => true,
        ssl_have_certificates => "false",
        rack_envs => $rack,
        documentroot => "/home/webapp/bxmediaus.com.wordpress/",
        priority => 25, 
        before => Class['wordpress'],
    }


`ssl_have_certificates`: set to false, to generate custom SSL certificates for your domain (if you don't have any). The certificate files are placed in `modules/apache2/files/` and automatically configured for you.

If you have certificates already, set it to true and place your certificates in `modules/apache2/files/`, in the form: `yourdomain.crt`, `yourdomain.key`, etc.


`racks_envs`: this is an array of different rack environments you would like to set up. If the folder doesn't exist, it will be created.

Set the `path` and `dir` attributes for each element.

Eg.

    $rack = [
	    	{'path' => '/myclient','dir' => '/home/webapp/bxmediaus.com.myclient/current/public/'}, 
    		{'path' => '/admin','dir' => '/home/webapp/bxmediaus.com.admin/current/public/'},
	  ]

	  
The default `nodes.pp` contains all the default settings you need, you only need to change the configuration details.

However, if you'd like to just use a part of our module (for example, the apache2 module), then feel free.


Deploying
-----

Once you have customized the environment, you'll need to save your settings to git. Because our deploy scripts use git. It's also a better way to manage your code.

We recommend making a new branch for your archive, like this:

    git checkout -b mysite.com
    git commit -a -m 'updated configuration files'
    
Then, if you make more changes to your environment, just commit the changes again to the archive.

After this, you're ready to deploy. On your local mac/linux machine:

(1) Place your private & public RSA keys (for SSH) into this directory: `user-modules/user-sshkey/files/webapp/` `id_rsa`, `id_rsa.pub`

(2) (optional) If you are using your own SSL certificates, place `.key`, `.csr` and `.crt` files (named after your domain) into this directory: `user-modules/apache2/files/`

(3) Edit the settings in `config.sh` to point to your server IP & root user (a new user will be created, but puppet needs to run as root).

(4) Execute `ruby_puppet_installer.sh` to install ruby & puppet to your server via SSH.

(5) Execute `deploy.sh` to copy & run the puppet scripts on your server via SSH.

You're done!

Depending on the speed/bandwidth of your server, you should have a rails environment up and running in 10 minutes.

After that, just set your capistrano config files to deploy to the directory you set in the `$rack` configuration (see above), run `cap deploy:cold`, and you're done.

Contributing
------------

Want to contribute? Great! 

Just fork our code, make your changes, then let us know and we will incorporate.

1. Fork it.
2. Create a branch (`git checkout -b my_qror`)
3. Commit your changes (`git commit -am "Added Snarkdown"`)
4. Push to the branch (`git push origin my_qror`)
5. Open a [Pull Request][1]
6. Enjoy a refreshing Diet Coke and wait

We encourage you to get in touch and tell us what you think of our code.

We are constantly updating and improving our code. We hope it can be for the benefit of the entire community.

If you want to chat to us, connect to our website: [bxmediaus.com][bxmediaus]


[bxmediaus]: https://bxmediaus.com
[apache-puppet]: https://github.com/puppetlabs/puppetlabs-apache

