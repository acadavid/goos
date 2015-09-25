ws = new WebSocket("ws://localhost:4567/ws");
ws.onmessage = function(eventMessage) {
    document.getElementById("sniper_status").innerHTML = "Lost";
}
