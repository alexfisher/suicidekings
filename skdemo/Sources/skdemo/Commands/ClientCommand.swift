import Foundation

#if canImport(WebSocketKit)
import WebSocketKit
import NIO
import ConsoleKit

struct ClientCommand: Command {
    struct Signature: CommandSignature {
        @Option(name: "name", help: "Sets the player name")
        var name: String?

        @Option(name: "host")
        var host: String?

        @Option(name: "port")
        var port: Int?

        @Option(name: "roomCode")
        var roomCode: String?
    }

    private let _queue: DispatchQueue = DispatchQueue(label: "com.skdemo.command.client.queue")

    var help: String = "Connect to a server and play \"Suicide Kings\""

    func run(using context: CommandContext, signature: Signature) throws {
        let console = context.console
        defer {
            console.output("")
        }

        console.output("""
        - - - - - - - - - - - - - - - -
         ♔ Welcome to Suicide Kings ♔
        - - - - - - - - - - - - - - - -
        + Client Mode
        + v0.0.1
        - - - - - - - - - - - - - - - -
        |        ~ TEAM SKETH ~       |
        - - - - - - - - - - - - - - - -

        """.consoleText(color: .brightYellow))

        let name = signature.name ?? console.ask("Enter your name:")

        let port = signature.port ?? 8080
        let host = signature.host ?? "localhost"
        console.output("👋 Hello, \(name)!".consoleText(.info))

        let player = Player(name: name)
        console.output(try player.prettyPrinted().consoleText(.info))

        let elg = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        let webSocket = try createWebsocket(updating: console, host: host, port: port, on: elg)

				webSocket.onText { ws, string in
						print("> \(string)")
				}

        repeat {
						defer { console.popEphemeral() }
						console.pushEphemeral()

						let roomCode = signature.roomCode ?? console.ask("Enter room code:")
						webSocket.send(roomCode)
        } while true
    }
}

extension ClientCommand {
    private static let encoder = JSONEncoder()

    fileprivate func createWebsocket(updating console: Console, host: String, port: Int, on elg: EventLoopGroup) throws -> WebSocket {
        var ws: WebSocket!

        let loadingBar = console.loadingBar(title: "Connecting to \"ws://\(host):\(port)\"...")
        loadingBar.start()
        do {
            try WebSocket
                .connect(host: host, port: port, on: elg, onUpgrade: { ws = $0 })
                .wait()
            loadingBar.succeed()
        } catch {
            loadingBar.fail()
            throw error
        }

        return ws
    }
}
#endif
