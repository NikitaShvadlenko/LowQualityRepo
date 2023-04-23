import Vapor

class WebSocketClient {
    var ws: WebSocket
    var id: String

    init(ws: WebSocket, id: String) {
        self.ws = ws
        self.id = id
    }
}
func routes(_ app: Application) throws {

    app.get { req -> EventLoopFuture<View> in
        return req.view.render("index")
    }

    var webSocketClients = [WebSocketClient]()

    // Handle WebSocket connections
    app.webSocket("play-sound") { req, ws in
        let id = UUID().uuidString

        // Add new WebSocket client to the list of connected clients
        let client = WebSocketClient(ws: ws, id: id)
        webSocketClients.append(client)
        // Disconnect WebSocket client
        ws.onClose.whenComplete { _ in
            webSocketClients.removeAll(where: { $0.id == id })
        }
    }

    // Handle API calls to trigger sound
    app.post("play-sound") { req -> HTTPStatus in
        for client in webSocketClients {
            client.ws.send("play-sound")
            print("sent stuff")
        }
        return .ok
    }
}
