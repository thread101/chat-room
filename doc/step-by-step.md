
# 👣 Step by step configuration

- *Clone the repository and move into the repo root directory*

```sh
git clone https://github.com/thread101/chat-room.git
cd chat-room
```

> If you don't have git installed you can download repo as zip and extract it on your machine then switch into the directory and open a terminal on that path.

---

- *Installing python on your machine*

| OS | Installation |
| -- | ------------ |
| Windows users | Visit [python.org](https://www.python.org/downloads/) and get python exe |
| Mac/Linux | Using your package manager else from [python.org](https://www.python.org/downloads/) |

> **windows:** Restart may be required else you can setup the python path manually.<br/>
**Linux:** If using package manager you may need to install `python-venv` and `python-pip` for example on debian, ubuntu and kali if not yet installed.

---

- *Configure a python environment  and install packages*

```sh
# ms windows
python -m venv .App-env
.App-env\Scripts\activate
pip install -r requirements.txt

# Mac/Linux
python3 -m venv .App-env
source .App-env\bin\activate
pip3 install -r requirements.txt
```

---

- *Install cloudflared*

<details>
<summary>Windows</summary>

## Method 1

### Get binary from [their github releases page](https://github.com/cloudflare/cloudflared/releases), you might want to pick the `.msi` binary

> Run the installer then restart may be needed if you don't know how to set the path manually.

## Method 2

### Using Winget

- If you don't have winget, open powershell as admin and run the following, visit [this page](https://learn.microsoft.com/en-us/windows/package-manager/winget/) for more information.

```powershell
$progressPreference = 'silentlyContinue'
Write-Host "Installing WinGet PowerShell module from PSGallery..."
Install-PackageProvider -Name NuGet -Force | Out-Null
Install-Module -Name Microsoft.WinGet.Client -Force -Repository PSGallery | Out-Null
Write-Host "Using Repair-WinGetPackageManager cmdlet to bootstrap WinGet..."
Repair-WinGetPackageManager -AllUsers
Write-Host "Done."
```

- Now install python by running:

```powershell
Winget install --name  "Cloudflared" --source winget
```

> Restart may be required there after.

- Confirm installation.

```sh
cloudflared --version
```

---

</details>

<details>
<summary>Linux</summary>

- Search for cloudflared package

```sh
# Debian/Ubuntu/Kali
apt search cloudflared

# Fedora
dnf search cloudflared

# CentOS/RHEL
yum search cloudflared

# Arch Linux
pacman -Ss cloudflared

# openSUSE
zypper search cloudflared

# Alpine Linux
apk search cloudflared
```

- If you the package is available you can install it and you are good to go. If not [get cloudflared](https://github.com/cloudflare/cloudflared/releases) from their github releases page and install manually.

```sh
# Debian/Ubuntu (using dpkg)
# sudo dpkg -i <cloudflared>.deb

# Fedora (using dnf)
# sudo dnf install <cloudflared>.rpm

# CentOS/RHEL (using yum)
# sudo yum install <cloudflared>.rpm

# Arch Linux (using pacman)
# pacman -U <cloudflared>.pkg.tar.zst

# openSUSE (using zypper)
# sudo zypper install <cloudflared>.rpm

# Alpine Linux (using apk)
# apk add --allow-untrusted <cloudflared>.apk
```

- confirm installation

```sh
cloudlflared --version
```

</details>

---

- *Running the project run*

#### Starting the flask backend

```sh
# ms windows
.App-env\Scripts\activate
flask run -h localhost -p 8099

# Mac/Linux
source .App-env/bin/activate
flask run -h localhost -p 8099
```

> This runs on localhost and not yet reachable

#### Starting cloudflared tunnel

From another terminal window run.

```sh
cloudflared tunnel --url localhost:8099
```

Look through the logs you should get your routable link ending in `.trycloudflare.com`.

---

- *Stopping the code*

#### press `CTRL+C` on both terminal windows to stop

#### else run

```sh
# ms windows
taskkill /f /im flask.exe
taskkill /f /im cloudflared.exe

# Mac/Linux
pkill -9 flask
pkill -9 cloudflared
```

---
