let chat_box = document.getElementsByTagName('textarea')[0];
let send_button = document.getElementsByTagName('button')[1];

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