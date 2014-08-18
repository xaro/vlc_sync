# VLC Sync #

This is an experiment to use WebRTC to sync two instances of the VLC player
that are being run in different computers.

## Setup ##
You need to install the npm packages (`npm install`), then the bower dependencies (`bower install`).

## Execution ##
In development mode, you can use Grunt to run a server that auto compiles the coffeescript, haml and sass files,
using `grunt server`.

### VLC ###
In the *server* folder, there is a go file that works as a proxy for the VLC API (because of Cross-Origin issues
you can't directly call the VLC API).

For the app to work, you need to run the server (compiling it and executing it, or doing `go run server.go`).
The server will run by default on port `9393` (you'll have to input this in the web app).

The final step is opening VLC. For this, you need to use the command line version of VLC and open it
using the command `vlc --extraintf http --http-host localhost --http-port 8080 --http-password vlc`.
Note the port as you'll need to input it to the web app (this port also allows you to open up two VLC instances
and try the app in one computer).
After opening the player, you have to open a video you want to sync.

Now you can control the playing status of the synced instances by using the web app.

## Disclaimer ##
This is just an experiment to try out if it's possible to communicate with the VLC API and
the usage of WebRTC to transfer arbitrary data. It is *not* meant to be a finished (or usable) product.