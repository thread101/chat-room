let chat_box = document.getElementsByTagName('textarea')[0];
let send_button = document.getElementById("send-message");
let chat_interval = null;
let loaded_chats = 0;
let num_members = 0;
let show_member = false;

window.onload = async () => await get_messages();

async function get_messages() {
    get_members();
    if (localStorage.getItem("session_cookie")) {
        let session_cookie = JSON.parse(localStorage.getItem("session_cookie"));

        if (!document.getElementById("leave-chat")) {
            document.getElementsByTagName("h2")[0].innerText = session_cookie.room;
            let button = document.createElement("button");
            button.innerText = "Leave chat";
            button.id = "leave-chat";
            button.onclick = leave_chat;
            document.getElementsByTagName("header")[0].appendChild(button);
        }
        
        await fetch(`${api_path}/chat`, {
            method: 'POST',
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                key: session_cookie.key,
                room: session_cookie.room,
                message: ""
            })
        })
        .then(resp => {
            if (resp.ok)
                return resp.json();
            else {
                toast(resp.statusText);
                return;
            }
        })
        .then(data => {
            if (data.error) {
                toast(data.error);
                localStorage.removeItem("session_cookie");
                setTimeout(() => window.location.replace(base_url), 1500);
            } else {
                update_chat(data.chats);
                if (chat_interval)
                    clearInterval(chat_interval);

                chat_interval = setInterval(() => get_new_messages(), 2000);
            }
        })
        .catch(error => toast(error));
    } else {
        window.location.replace(base_url);
    }
}

async function leave_chat() {
    toast("Closing connection...");
    let session_cookie = JSON.parse(localStorage.getItem("session_cookie"));
    await fetch(`${api_path}/leave`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            room: session_cookie.room,
            key: session_cookie.key
        })
    })
    .then(resp => {
        if (resp.ok)
            return resp.json();
        else {
            toast(resp.statusText);
            return;
        }
    })
    .then(data => {
        if (data.error)
            toast(data.error);
        else
            toast(data.success);
    })
    .catch(error => {});
    localStorage.removeItem("session_cookie");
    setTimeout(() => window.location.replace(base_url), 1500);
    if (chat_interval)
        clearInterval(chat_interval);
}

function get_members() {
    let session_cookie = JSON.parse(localStorage.getItem("session_cookie"));
    fetch(`${api_path}/members`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            key: session_cookie.key,
            room: session_cookie.room
        })
    })
    .then(resp => {
        if (resp.ok)
            return resp.json();
        else {
            toast(resp.statusText);
            return;
        }
    })
    .then(data => {
        if (data.error) {
            toast(data.error);
        } else {
            let members = data.members;
            if (members.length != num_members) {
                let ul = document.getElementById("members");
                if (num_members > members.length) {
                    num_members = 0;
                    ul.innerHTML = "";
                }
                for (let i=num_members; i<members.length; i++) {
                    let li = document.createElement("li");
                    li.innerText = members[i];
                    ul.appendChild(li);
                }
            }
            num_members = members.length;
        }
    })
    .catch(error => toast(error));

    if (window.innerWidth < 820) {
        let h2 = document.getElementsByTagName("h2")[0];
        h2.style.cursor = "pointer";
        h2.addEventListener('click', function() {
            let menu = document.getElementById("menu");
            let content = document.getElementById("content");
            if (show_member) {
                menu.style.display = "none";
                content.style.display = "flex";
            } else {
                menu.style.display = "block";
                menu.style.minHeight = "100%";
                content.style.display = "none";
            }
            show_member = !show_member;
        });
    }
}

chat_box.oninput = () => {
    let text = chat_box.value;
    if (text.trim().length === 0) {
        send_button.disabled = true;
        send_button.style.backgroundColor = "darkgrey";
    } else {
        send_button.disabled = false;
        send_button.style.backgroundColor = "darkgreen";
    }
}

chat_box.addEventListener('keypress', key => {
    if (key.code === "Enter") {
        if (chat_box.value.trim().length === 0) {
            chat_box.value = "";
        } else {
            send_button.click();
        }        
    }
});

send_button.onclick = () => {
    let message = chat_box.value.trim();
    send_button.disabled = true;
    send_button.style.backgroundColor = "darkgrey";
    chat_box.value = ""
    let session_cookie = JSON.parse(localStorage.getItem("session_cookie"));

    fetch (`${api_path}/chat`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            room: session_cookie.room,
            key: session_cookie.key,
            message: message
        })
    })
    .then(resp => {
        if (resp.ok)
            return resp.json();
        else
            toast(resp.statusText);
    })
    .then(data => {
        if (data.error)
            toast(data.error);
        else
            update_chat(data.chats);
    })
    .catch(error => {});
}

function get_new_messages() {
    get_members();
    let session_cookie = JSON.parse(localStorage.getItem("session_cookie"));
    fetch (`${api_path}/chat`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            room: session_cookie.room,
            key: session_cookie.key,
            message: ""
        })
    })
    .then(resp => {
        if (resp.ok)
            return resp.json();
        else
            return;
    })
    .then(data => {
        if (data.error) {
            toast(data.error);
            localStorage.removeItem("session_cookie");
            setTimeout(() => window.location.replace(base_url), 1500);
            if (chat_interval)
                clearInterval(chat_interval);
        }
        else
            update_chat(data.chats);
    })
    .catch(error => {});
}

function update_chat(chats) {
    let session_cookie = JSON.parse(localStorage.getItem("session_cookie"));
    let chats_div = document.getElementsByClassName("chats")[0];
    if (document.getElementsByClassName("chats-list")[0]) {
        let ul = document.getElementsByClassName("chats-list")[0];
        for (let i = loaded_chats; i < chats.length; i++) {
            let chat = chats[i];
            let alias = Object.keys(chat)[0];
            let message = Object.values(chat)[0];
            let li = document.createElement("li");
            let p = document.createElement("p");
            let span = document.createElement("span");
            span.innerText = alias;
            p.innerText = message;
            if (alias === session_cookie.alias)
                li.className = "sent";
            else {
                li.className = "received";
                toast("New message");
                setTimeout(() => chats_div.scrollBy(0, chats_div.scrollHeight), 250);
            }
            li.appendChild(p);
            li.appendChild(span);
            ul.appendChild(li);
        }
    } else {
        let ul = document.createElement("ul");
        ul.className = "chats-list";
        chats.forEach((chat, index) => {
            let alias = Object.keys(chat)[0];
            let message = Object.values(chat)[0];
            let li = document.createElement("li");
            let p = document.createElement("p");
            let span = document.createElement("span");
            span.innerText = alias;
            p.innerText = message;
            li.appendChild(p);
            li.appendChild(span);
            ul.appendChild(li);
            if (alias === session_cookie.alias)
                li.className = "sent";
            else
                li.className = "received";
        });
        chats_div.appendChild(ul);
        chats_div.scrollBy(0, chats_div.scrollHeight);
    }
    loaded_chats = chats.length;
}