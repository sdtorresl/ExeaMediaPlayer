#!/usr/bin/python
from time import gmtime, strftime, localtime, time
from datetime import datetime
import json
import os #For check if a file exist and execute shell commands
from jsonrpclib.jsonrpc import TransportMixIn, XMLTransport
from jsonrpclib import Server
from unicodedata import numeric

class Transport(TransportMixIn, XMLTransport):
    """Replaces the json-rpc mixin so we can specify the http headers."""
    def send_content(self, connection, request_body):
        connection.putheader("Content-Type", "application/json")
        connection.putheader("Content-Length", str(len(request_body)))
        connection.endheaders()
        if request_body:
            connection.send(request_body)

def checkFile(file):
    if os.path.exists(file):
        return True
    else:
        return False
        
def main():

    server = Server("http://exea:exea@localhost:8080/jsonrpc", transport=Transport())
    name_playlist = strftime("%H:00", localtime()) 

    #Add items to playlist
    if checkFile('/home/pi/ExeaMediaPlayer/playlist/sync'):
        json_data = open('/home/pi/ExeaMediaPlayer/playlist/sync')
        try:
            data = json.load(json_data)
            # Current Playlist info
            info = server.Playlist.GetItems(1)
            print info

            # Current total items in playlist
            total = info['limits']['total']
            total = int(total)
            print total

            if total <= 10:
                server.Playlist.Clear(1)

                for (i, playlist) in data.items():
                    current_playlist = playlist[name_playlist]
                    for(j, item) in current_playlist.items():
                        item_file = item['path']
                        print item_file
                        if checkFile("/home/pi/ExeaMediaPlayer/media/share/" + item_file):
                            server.Playlist.Add(1, {'file': '/home/pi/ExeaMediaPlayer/media/share/' + item_file})

            info = server.Playlist.GetItems(1)
            print info

        except:
			print "No JSON object could be decoded"
			os.system('killall xbmc.bin')
           
    #Shedulled items
    if checkFile("/home/pi/ExeaMediaPlayer/playlist/sheduled"):  
        try:
            json_sheduled = open('/home/pi/ExeaMediaPlayer/playlist/sheduled')
            sheduled = json.load(json_sheduled)

            ts = time() # Current timestamp
            system_time = (int)(ts/100)

            print "System date:"
            print system_time

            for (i, item) in sheduled.items():
                item_ts = int(item['time'])
                item_dt = datetime.fromtimestamp(int(item_ts))
                item_time = (int)(item_ts/100)

                print "Item time:"
                print item_time

                if(item_time == system_time):
                    item_file = item['path']
                    if checkFile("/home/pi/ExeaMediaPlayer/media/share/" + item_file):
                        server.Playlist.Clear(1)
                        server.Playlist.Add(1, {'file': '/home/pi/ExeaMediaPlayer/media/share/' + item_file})
                    else:
                        print "File to play at " + item_dt.strftime('%D/%M %H:%m') + " doesn't exist"
        except:
			print "No JSON object could be decoded"
			os.system('killall xbmc.bin')

    #server.Playlist.Clear(1)
    #server.Player.Open({'playlistid': 1})
    players = server.Player.GetActivePlayers()
    players_count = len(players)

    if players_count < 1:
        server.Player.Open({'playlistid': 1})

if __name__ == '__main__':
    main()
