import secrets
import time
import base64


class Chat:

    def __init__(self):
        self.chats = {}
        self.startTime = time.time()

    def new(self, room: str, password: str, alias: str):
        chats = self.chats
        rooms = list(chats.keys())
        if room in rooms:
            return "room unavailable", 1

        key = secrets.token_hex(15)
        passwd = base64.b64encode(password.encode("utf-8")).decode("utf-8")
        chats.update(
            {
                room: {
                    "chats": [],
                    "password": passwd,
                    "aliases": [{"alias": alias, "key": key}],
                }
            }
        )
        return key, 0

    def join(self, room: str, password: str, alias: str):
        chats = self.chats
        rooms = list(chats.keys())
        if room not in rooms:
            return "invalid room", 1

        room = chats[room]
        passwd = base64.b64encode(password.encode("utf-8")).decode("utf-8")
        if passwd != room["password"]:
            return "wrong password", 1

        aliases = [alias["alias"] for alias in room["aliases"]]
        if alias in aliases:
            return "alias taken", 1

        key = secrets.token_hex(15)
        keys = [alias["key"] for alias in room["aliases"]]
        while key in keys:
            key = secrets.token_hex(15)

        room["aliases"].append({"alias": alias, "key": key})
        return key, 0

    def chat(self, room: str, key: str, message: str = None):
        chats = self.chats
        rooms = list(chats.keys())
        if room not in rooms:
            return "invalid room", 1

        room = chats[room]
        alias = None
        for user in room["aliases"]:
            if key == user["key"]:
                alias = user["alias"]
                break

        if alias is None:
            return "invalid key", 1

        if message in [None, "", " "] or message.isspace():
            return room["chats"], 0

        room["chats"].append({alias: message})
        return room["chats"], 0

    def leave(self, room: str, key: str):
        chats = self.chats
        rooms = list(chats.keys())
        if room not in rooms:
            return "invalid room", 1

        room = chats[room]
        alias = None
        for user in room["aliases"]:
            if key == user["key"]:
                alias = user
                break

        if alias == None:
            return "invalid key", 1

        room["aliases"].remove(user)
        return "logged out", 0


if __name__ == "__main__":
    C = Chat()
    key1, _ = C.new("chatq", "password", "kendre")
    key2, _ = C.join("chatq", "password", "Andre")
    print(C.chat("chatq", key1, "hello"))
    print(C.chat("chatq", key2, "Hi"))
    print(C.chats)
    print(C.leave("chatq", key2 + " "))
    print(C.leave("chatq", key1))
    print(C.chats)
