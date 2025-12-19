fetch('http://127.0.0.1:5000/join', {
    method: 'POST',
    headers: {
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({
        room: 'room',
        password: 'password'
    })
})
.then(resp => resp.json())
.then(data => console.log(data));