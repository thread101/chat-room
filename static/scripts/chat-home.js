let chat_box = document.getElementsByTagName('textarea')[0];
let leave_button = document.getElementsByTagName("button")[0];
let send_button = document.getElementsByTagName('button')[1];
let loaded_chats = 0;

window.onload = get_messages;

async function get_messages() {
    if (localStorage.getItem("session_cookie")) {
        let session_cookie = JSON.parse(localStorage.getItem("session_cookie"));
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
            } else 
                update_chat(data.chats);
        })
        .catch(error => {});
    } else {
        window.location.replace(base_url);
    }
}

leave_button.onclick = async function() {
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
    let message = chat_box.value;
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

function update_chat(chats) {
    let session_cookie = JSON.parse(localStorage.getItem("session_cookie"));
    if (document.getElementsByClassName("sent").length != 0 || document.getElementsByClassName("received").length != 0) {
        let ul = document.getElementsByTagName("ul")[0];
        new_chats = chats.length - loaded_chats - 1;
        console.log("new chats: " + new_chats + ", old chats: " + loaded_chats + ", received chats: " + chats.length);
        for (let i = new_chats; i >= 0; i--) {
            let chat = chats[i];
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
            else {
                li.className = "received";
                toast("New message");
            }
            loaded_chats += 1;
        }
        let chats_div = document.getElementsByClassName("chats")[0];
        chats_div.appendChild(ul);
        chats_div.scrollBy(0, chats_div.scrollHeight);
    } else {
        let ul = document.createElement("ul");
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
        let chats_div = document.getElementsByClassName("chats")[0];
        chats_div.appendChild(ul);
        chats_div.scrollBy(0, chats_div.scrollHeight);
        loaded_chats = chats.length;
    }
}