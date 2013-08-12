RESTful-API-Raspberry-Pi
========================


##Overview
Building Restful Api With RaspBerry Pi using Apache2 mod_perl

  
1) [Build a RESTful spell-checking service](#restful-spell-checking-service)    
2) [RESTful service with an endpoint to resize an image specified by a URL](#restful-resize-service)

##Example Usage
Please look in folder t for Example usages

Setting up environment
--------
Running RaspBerry Pi on Raspbian “wheezy”
http://www.raspberrypi.org/downloads

To make it easier, run these commands under sudo -i or sudo su

* **Make sure your package repositories and installed programs are up to date by issuing the following commands**

        apt-get update 
        apt-get upgrade

* **Install Apache2**
 
        apt-get install apache2 apache2-doc apache2-utils
    
* **Install mod_perl**

        apt-get install libapache2-mod-perl2
   
* **Testing Apache Server**
 
 - Restart the Apache server with the following command
 
            /etc/init.d/apache2 restart
     
 - Discover your ip with the following command

            ip addr show
    
        The ip should be inet xxx.xxx.xxx.xxx<br>
           Type in your ip address in the browser if you see "It works!" you are good to go
    
 - When you create or edit any virtual host file, you'll need to reload the config, which you can do without restarting the server with the following command

            /etc/init.d/apache2 reload
    
* **Install libraries that will be used for the api Project**

 - **Text::Aspell**
 
            apt-get install libtext-aspell-perl

 - **JSON**
 
            apt-get install libjson-pp-perl

 - **File::MMagic**
 
            apt-get install libfile-mmagic-perl

 - **Image::Magick**
 
            apt-get install perlmagick
  
* **Apache setting**
 
    /etc/apache2/sites-available/default
   
        PerlModule ModPerl::Registry
        <Directory "/usr/local/lib/site_perl/">
            SetHandler perl-script
            PerlResponseHandler ModPerl::Registry
            Options +ExecCGI
            AllowOverride All
        </Directory>
  
    /etc/apache2/conf.d/handler-api

        <Location /api/spell_check>
            SetHandler perl-script
            PerlResponseHandler spell_check_api
            PerlAuthenHandler spell_check_api->authen_handler
            AuthName realm
            AuthType Basic
            Require valid-user
        </Location>
  
        <Location /api/resize_image>
            SetHandler perl-script
            PerlResponseHandler resize_image_api
            PerlAuthenHandler resize_image_api->authen_handler
            AuthName realm
            AuthType Basic
            Require valid-user
        </Location>

* **Create a symlink to /tmp for images, so our images are temporary saved**

        ls -s /tmp /var/www/images
  
##RESTful spell-checking service

  This api uses Text::Aspell Libiary for spell check, accepts GET request with parameters: word, max
  Single word or mutilple words/sentence could all be passed in.  
  Returns 10 suggestions as default could go up to 50.
    
  JSON respond  
  When every thing is correct  
  {"correct":"1"}
  When there's missed spelled word  
  { suggest: ***word***: [ ***suggestions*** ] }  
  Example:  
  {"suggest":{"test2":["test","testy","test's","tester","tests","taste","tasty","teat's","Tet's","teat"]}}
  

    
##RESTful resize service

  Pass in an image url, the api will resize it and return a resized image url.  
  This api accepts POST request with json parameters. requires image_url, hight or width passed in.

  JSON respond  
  Original image and new image url

  Example:  
  {"orignal":"192.168.1.154/images/org_1921681154_1376264950.jpeg","new":"192.168.1.154/images/1921681154_1376264950.jpeg"}
