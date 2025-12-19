import secrets
import time
import base64

class Chat:

    def __init__(self):
        self.chats = {}
        self.startTime = time.time()

    def new(self, room: str, password:str):
        chats = self.chats
        rooms = list(chats.keys())
        if room in rooms:
            return "room unavailable", 1
        
        key = secrets.token_hex(15)
        passwd = base64.b64encode(password.encode("utf-8")).decode("utf-8")
        chats.update({room: {"keys": [key], "chats": [], "password" : passwd}})
        return key, 0
    
    def join(self, room:str, password:str):
        chats = self.chats
        rooms = list(chats.keys())
        if room not in rooms:
            return "invalid room", 1
             
        room = chats[room]
        passwd = base64.b64encode(password.encode("utf-8")).decode("utf-8")
        if passwd != room["password"]:
            return "wrong password", 1
        
        key = secrets.token_hex(15)
        while key in room["keys"]:
            key = secrets.token_hex(15)
            
        room["keys"].append(key)
        return key, 0
    
    def chat(self, room:str, key:str, message:str=None):
        chats = self.chats
        rooms = list(chats.keys())
        if room not in rooms:
            return "invalid room", 1
             
        room = chats[room]
        if key not in room["keys"]:
            return "invalid key", 1
        
        if message in [None, '', " "] or message.isspace():
            return room["chats"], 0
        
        room["chats"].append({key : message})
        return room["chats"][::-1], 0
        