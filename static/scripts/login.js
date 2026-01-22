const login_form = document.forms.login;

login_form.option.onchange = assert_mode;

window.onload = () => {
    assert_mode();
    setTimeout(() => login_form.className = "show", 1000);
}

login_form.addEventListener('submit', (event) => {
    event.preventDefault();
    let mode = login_form.submit.value;
    let room_alias = login_form.room.value;
    let password = login_form.password.value;
    console.log("alias: " + room_alias + ", password: " + password + ", mode: " + mode);
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