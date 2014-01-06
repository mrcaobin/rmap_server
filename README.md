Project Description
================================
This project is aimed to provide a easy to publish RESTful base map service,
support many kinds of datasource, such as MBTile/ArcGISCache/OnlineMaps etc.
The application is written in pure ruby, will work fine in Linux.

The main idea to start this project is I need a light-weight Map Server, Then
I found "Portable Base Server(https://geopbs.codeplex.com/)", It's a powerful
tool and I strongly recommended, but it written in .Net WPF.


version 0.1:
* Support ArcGISCache data

How To Use
================================
1.Install Sinatra
   gem install sinatra
2.Prepare Tiled Data, for example, "/home/data/Natural_Earth" 
  the directory structure is like this
   -Natural_Earth
        |-Layers
            |-_alllayers
            |-Status.gdb
            |-conf.cdi
            |-Conf.xml
3.Edit the config file "services.yml", for example:
      port: 4567 
      host: 127.0.0.1
      services:
          natural_earth: /home/data/Natural_Earth
4.Run "ruby app.rb" to start server.
5.In browser, open : "http://127.0.0.1:4567/natural_earth", enjoy.

Bug track
================================ 
if you have any question, my email is :mrcaobin@gmail.com.      
