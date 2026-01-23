const base_url = `${window.location.origin}`;
const api_path = `${base_url}/api`;

function toast(message, timeout=1500, position="90vh") {
    let div = document.getElementsByClassName("toast")[0] || document.createElement("div");
    let span = div.firstChild || document.createElement("span");
    span.innerText = message;
    div.appendChild(span);
    div.className = "toast";
    div.style.top = position;
    document.body.appendChild(div);
    setTimeout(() => div.className = "toast hide", timeout);
}
