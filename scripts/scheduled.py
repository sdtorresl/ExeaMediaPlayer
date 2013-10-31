#!/usr/bin/python
from time import gmtime, strftime, localtime, time
from datetime import datetime
import json
import os.path #For check if a file exist
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
         
    #Shedulled items
    if checkFile("/home/sdtorresl/exeamediaplayer/playlist/scheduled"):  

        json_scheduled = open('/home/sdtorresl/exeamediaplayer/playlist/scheduled')
        scheduled = json.load(json_scheduled)

        ts = time() # Current timestamp
        system_time = (int)(ts/100)

        print "System date:"
        print system_time

        for item in scheduled:
            print item
            item_ts = int(item['field_play_date_value'])
            item_dt = datetime.fromtimestamp(int(item_ts))
            item_time = (int)(item_ts/100)
            item_file = item['filename']
            item_path = '/home/sdtorresl/exeamediaplayer/media/share/' + item_file
           

            if (item_time <= system_time+5) or (item_time >= system_time-5):
                if not checkFile("" + item_file):
                    print '\n\n*********************************************************************\nSCHEDULED ITEM:'
                    print '\nName: ' + item_file
                    print 'Time: ' + item_dt.strftime('%D/%M %H:%m')
                    print 'Path: ' + item_path
                    print '*********************************************************************\n\n'
                else:
                    print "File to play at " + item_dt.strftime('%D/%M %H:%m') + " doesn't exist"

if __name__ == '__main__':
    main()
