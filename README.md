# Simple chat app with internet hosting

## 💡 Introduction

This is a simple chat app that allows you tunnel to the internet, no account needed. Share the link and those individuals with that very link can create chat rooms and join already existing ones. Simple python flask backend api and hosting some web files customizable if you understand a little bit about makeup languages.

## 🧠 How it works

Flask backend is responsible for hosting the pages and  running the api app on your local machine, then through the power of tunnelling thanks to [cloudflared](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/) we tunnel the pages to the internet where you get a random link routable from the internet. These link are used for testing and for mass production you can get your static url by creating an account [visit cloudflared](https://developers.cloudflare.com/cloudflare-one/setup/) to get started.

## 💻 Installation and usage

> **NOTE:** Applicable for both unix like and ms windows. This is a quick configuration via scripts, [step-by-step configuration guide](/doc/step-by-step.md) is available for detailed setup instructions.

- *Clone the repository and move into the repo root directory*

```sh
git clone https://github.com/thread101/chat-room.git
cd chat-room
```

> If you don't have git installed you can download repo as zip and extract it on your machine then switch into the directory and open a terminal on that path.

- *Run the configuration script (windows users use `command prompt`)*

```sh
# ms windows
configure.bat

# unix/linux
chmod +x configure.sh
./configure.sh
```

> This fetches python if not yet installed and installs it same to cloudflared. The configuration has been tested on `Win11 22H2`, `Win11 25H2`,`Win10 22H2` but guaranteed to work for most windows version. On linux It has been tested on `fedora`, `arch`,`kali`, `ubuntu` and `debian` also guaranteed to work for most of the linux distributions out there. <br><br/> **NOTE:** For termux users, you will need to install a proot linux environment as termux it self doesn't have a cloudflared binary.

- *Make sure you see the configuration successful massage, next just run the launch script*

```sh
# ms windows
Launch.bat

# unix/linux
chmod +x Launch.sh
./Launch.sh
```

- *You should get public url from your log messages, open this link on your browser and you should get a login page for creating a chat room else join*

- *Thats all about all of it.*

> **NOTE:** For windows users two other cmd windows will be opened as batch does not support multithreading, one running the flask app and another running the cloudflared tunnel, by default they are minimized. Nothing to be worried about.

## 🛠️ Known issues

- The user interface is not the cleanest but feel free to edit your copy.

- The use of out dated methods to handle api calls, a better version using javascript socketio is coming.

- No data base system, well this is not aimed to production and for simplicity and easy setup it uses python classes with no data storage, In the next release I'll work on storage.

### Hope you find it useful 😅
