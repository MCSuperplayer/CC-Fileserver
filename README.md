These programs were initially created for a stargate dialing program i was working on, but decided to expand its features to other use cases.

The file listener is still called address file listener, but you can change the names of things, just make sure to update references to anything properly.

To "host" a file you place an advanced computer with a wireless modem on top, give it the fileserver and parallelfilesender programs, as well as the file you want to host.
then start the server with `fileserver [FILENAME]`

any other computer can then use the filerequest program to download the hosted file from the other computer, provided it is within range of the modem

to save on ender modems, i'd recommend a relay computer with ender modem, using the `relay` program, that way only 1 ender modem is required.
