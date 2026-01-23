const login_form = document.forms.login;

login_form.option.onchange = assert_mode;

window.onload = async function() {
    assert_mode();
    if (localStorage.getItem("session_cookie")) {
        let previous_cookie = JSON.parse(localStorage.getItem("session_cookie"));
        toast("Validating previous session...");
        await fetch(`${api_path}/chat`, {
            method: 'POST',
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                room: previous_cookie.room,
                key: previous_cookie.key,
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
                setTimeout(() => login_form.className = "show", 1000);
                toast(data.error);
                localStorage.removeItem("session_cookie");
            } else {
                let page = `${base_url}/chat-home`;
                setTimeout(() => window.location.replace(page), 1500);
            }
        })
    } else {
        setTimeout(() => login_form.className = "show", 1000);
    }
}

login_form.addEventListener('submit', (event) => {
    event.preventDefault();
    let mode = login_form.submit.value;
    let room_alias = login_form.room.value;
    let password = login_form.password.value;
    let alias = login_form.alias.value;
    let route = mode === "Create" ? "/new" : "/join";
    
    fetch(`${api_path}${route}`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json"
        },
        body: JSON.stringify({
            room: room_alias,
            password: password,
            alias: alias
        })
    })
    .then(resp => {
        if (resp.ok) {
            return resp.json();
        } else {
            toast(resp.statusText);
            return;
        }
    })
    .then(data => {
        if (data.error) {
            toast(data.error, 1500, "95vh");
        } else {
            toast("Action completed");
            let session_cookie = JSON.stringify({
                room: room_alias,
                key: data.key,
                alias: alias
            });
            localStorage.setItem("session_cookie", session_cookie);
            let page = `${base_url}/chat-home`;
            setTimeout(() => window.location.replace(page), 1500);
        }
    })
    .catch(error => {});
});

function assert_mode() {
    let value = login_form.option.value;
    login_form.submit.value = value;
    if (value.toLowerCase() === "join") {
        login_form.room.placeholder = "Enter room alias";
        login_form.password.placeholder = "Enter password";
    } else {
        login_form.room.placeholder = "Set room alias";
        login_form.password.placeholder = "Set password";
    }
}
