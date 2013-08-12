RESTful-API-Raspberry-Pi
========================

Building Restful Api With RaspBerry Pi using Apache2 mod_perl
  Api Projects
    1) Build a RESTful spell-checking service    
    2) RESTful service with an endpoint to resize an image specified by a URL


Setting up environment
  Running RaspBerry Pi on Raspbian “wheezy”
  http://www.raspberrypi.org/downloads

  To make it easier run these commands under sudo -i or sudo su

  Make sure your package repositories and installed programs are up to date by issuing the following commands
    # apt-get update
    # apt-get upgrade

  Install Apache2
    # apt-get install apache2 apache2-doc apache2-utils
    
  Install mod_perl
    # apt-get install libapache2-mod-perl2
   
  Testing Apache Server
    Restart the Apache server with the following command
    # /etc/init.d/apache2 restart
    
    Discover your ip with the following command
    # ip addr show
    The ip should be inet xxx.xxx.xxx.xxx
    Type in your ip address in the browser if you see "It works!" you are good to go
    
    When you create or edit any virtual host file, you'll need to reload the config, which you can do without restarting the server with the following command
    # /etc/init.d/apache2 reload
    
  Install libraries that will be used for the api Project
    Text::Aspell
    # apt-get install libtext-aspell-perl
    JSON
    # apt-get install libjson-pp-perl 
    File::MMagic
    # apt-get install libfile-mmagic-perl
    Image::Magick
    # apt-get install perlmagick
  
  Apache setting
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

  Create a symlink to /tmp for images, so our images are temporary saved.
  ls -s /tmp /var/www/images
  
1) Build a RESTful spell-checking service
  This api would be using Text::Aspell Libiary, accepts GET request with parameters: word, max
  word could be single word or a sentence, max is the number of suggestions returned for each word ( Default 10, Can not go over than 50 ).
  Returns JSON format
  correct:1 if word is all correct
  else it woudl return suggest:word:[ suggestions ] word is each word that passed in.
  
  Steps:
    1. Check authorization
    2. Check if text is correct
    3. Check if text has multiple words.
      - Split the sentence to single words
      - Check each word
      - Get and return suggestions
    4. Get and return suggestions
    
2) RESTful service with an endpoint to resize an image specified by a URL
  Pass in an image url, the server will resize it and return a url with the new size.
  This api accepts POST request with json parameters. requires image_url, hight or width
  return as JSON format with the original image and new image url
  
  Steps:
    1. Check authorization    
    2. Check if file type is image, jpg, png, gif
    3. Download to /tmp 
    4. Resize the image
    5. return in JSON format with original and the new image url
    

