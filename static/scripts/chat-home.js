let chat_box = document.getElementsByTagName('textarea')[0];
let send_button = document.getElementsByTagName('button')[1];

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
                room: session_cookie.room,
                key: session_cookie.key,
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
                console.log(data.chats);
            }
        })
        .catch(error => {});
    } else {
        window.location.replace(base_url);
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