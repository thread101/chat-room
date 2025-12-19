import requests, json

URL = "http://127.0.0.1:5000"

def get_choice():
    choice = 0
    while choice not in [2, 3]:
        print("[1] Check server runtime\n[2] start new chat room\n[3] join a chat room\n")
        try:
            choice = int(input(">>> "))
            
        except Exception:
            pass
        
        if choice == 1:
            d = requests.get(URL).content
            data = json.loads(d.decode("utf-8"))
            print(round(data["run_time"], 3), "seconds")

    return choice

def get_details():
    while True:
        room = input("room: ")
        password = input("password: ")
        c = input(f"confirm (\"room\": {room}, \"password\": {password}) [Y/n]")
        if c.lower() != "n":
            break
        
    return room, password

def get_key(url: str):
    room, password = get_details()
    d = requests.post(url, json={"room" : room, "password" : password}).content
    data = json.loads(d.decode("utf-8"))
    
    while "key" not in list(data.keys()):
        print(data)
        room, password = get_details()
        d = requests.post(url, json={"room" : room, "password" : password}).content
        data = json.loads(d.decode("utf-8"))
        
    return room, data["key"]

def chat(room:str, key:str):
    url = f"{URL}/chat"
    while True:
        message = input(">>> ")
        data = {"room" : room, "key" : key, "message" : message}
        d = requests.post(url, json=data).content
        data = json.loads(d.decode("utf-8"))
        print(data)

def main():
    choice = get_choice()
    
    url = f"{URL}/new" if choice == 2 else f"{URL}/join"
    room, key = get_key(url)
    
    chat(room, key)

try:
    requests.get(URL)
    main()
    
except Exception:
    print("server offline")