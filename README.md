# Air Share
The aim of the app is to allow people who are near each other to share their itunes music by streaming.

##Multipeer Connectivity Framework
The app uses the multipeer connectivity framework to connect devices with the app in order to send data between devices as well as stream data bewtween devices.  These can happen simultaneously and are separate.

##MediaPlayer Framework
The mediaplayer framework is used to interact with itune libraries, pick songs from the library to make a play list.

##AVAudio Framework
The AVAudio framework is used to write a customized audio-player which plays the music file as it is been streamed accross device.

##The general idea
Once connected, the server/dj device can go to his or her itunes library inside the app, and pick some songs to add to a playlist to be shared.  This send a message(data) of song titles and images to the other device, which upon receipt of these data, builds a table view of the playlist.  When the client/listener device clicks on one of the songs, it sends a message to the dj device to send the length of the song back as well as start to stream the song across.  With the first chunk of data received back, the client initialize our customized audio player to start playing from the audio stream data.  It is worth noting that, the way audio player is made is done is by telling AVPlayer that it needs to play a file it does not know how to play, it then therefore ask you to specify how it is to be played, when it is asking for the next data chunk, you point it to the incoming audio data.  

##Latest work
Latest version is on the sending_images branch

