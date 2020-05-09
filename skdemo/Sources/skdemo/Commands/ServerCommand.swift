import Foundation
import ConsoleKit

#if canImport(WebSocketKit)
import WebSocketKit
import NIO
import NIOWebSocket

struct ServerCommand: Command {
    struct Signature: CommandSignature {
        @Option(name: "host")
        var host: String?

        @Option(name: "port")
        var port: Int?
    }

    var help: String = "Host a \"Suicide King\" server"

    func run(using context: CommandContext, signature: Signature) throws {
        let console = context.console
        defer {
            console.output("")
        }

        console.output("""
        - - - - - - - - - - - - - - - -
         ♔ Welcome to Suicide Kings ♔
        - - - - - - - - - - - - - - - -
        + Server Mode
        + v0.0.1
        - - - - - - - - - - - - - - - -
        |        ~ TEAM SKETH ~       |
        - - - - - - - - - - - - - - - -

        """.consoleText(color: .brightYellow))

        let port = signature.port ?? 8080
        let host = signature.host ?? "localhost"
        console.output("Opening websocket...".consoleText(.info))

        let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
        defer {
            try! group.syncShutdownGracefully()
        }
        
        var gameServer  = GameServer.shared
        let gameSession = GameSession(startingAmount: 10_000.0, valueAwardedEachRound: 100.0)
        
        let server = try createWebSocket(host: host, port: port, group: group, connection: { ws in
            console.output("Connection received".consoleText(.info))
            /* Do Something */
            ws.onText { ws, string in
                console.output("Recevied: \(string)")
                ws.send("back at ya")
            }
            ws.onBinary { ws, binary in
                let data = Data(buffer: binary)
                console.output("Recevied: \(data)".consoleText())
            }
            ws.onClose.whenComplete {
                console.output("Connection closed. \($0)".consoleText(.info))
            }
        }).wait()
        console.output("Listening on port \(port)...".consoleText(.info))

        gameSession.start(on: &gameServer)
        gameSession.stop(on: &gameServer)

        try server.closeFuture.wait()
    }
}

extension ServerCommand {
    fileprivate func createWebSocket(host: String, port: Int, group: MultiThreadedEventLoopGroup, connection: @escaping (WebSocket) -> ()) -> EventLoopFuture<Channel> {
        ServerBootstrap(group: group).childChannelInitializer { channel in
            let webSocket = NIOWebSocketServerUpgrader(
                shouldUpgrade: { channel, _ in
                    channel.eventLoop.makeSucceededFuture([:])
                },
                upgradePipelineHandler: { channel, req in
                    WebSocket.server(on: channel) { ws in
                        connection(ws)
                    }
                }
            )
            return channel.pipeline.configureHTTPServerPipeline(withServerUpgrade: (
                upgraders: [webSocket],
                completionHandler: { ctx in }
            ))
        }.bind(host: host, port: port)
    }
}

#endif

extension String {
		static func randomString(ofLength length: Int) -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).compactMap({ _ in
            characters.randomElement()
        }))
    }

    fileprivate static func generateJoinCode() -> Self {
        randomString(ofLength: 6)
    }
}
