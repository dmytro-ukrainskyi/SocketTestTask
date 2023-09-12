//
//  ViewController.swift
//  socket-test
//
//  Created by DevHive.
//

import UIKit

class ViewController: UIViewController {
    
    /*
     Only necessary methods were implemented.
     Networking related code should be in a separate class, not in the ViewController.
     Third party libraries could be used to achieve the same functionality, e.g. Starscream.
     */
    
    // MARK: Private Properties
    private let serverHost: String? = ProcessInfo.processInfo.environment["ws_address"]
    private let serverPort: String? = ProcessInfo.processInfo.environment["ws_port"]
    
    private var webSocket: URLSessionWebSocketTask?
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        connect()
    }
    
}

// MARK: - URLSessionWebSocketDelegate

extension ViewController: URLSessionWebSocketDelegate {
    
    func connect() {
        guard let serverHost,
              let serverPort,
              let url = generateURLForServerWith(
                host: serverHost,
                port: serverPort
              ) else { return }
        
        let urlSession: URLSession = URLSession(
            configuration: .default,
            delegate: self,
            delegateQueue: OperationQueue()
        )
        
        webSocket = urlSession.webSocketTask(with: url)
        
        webSocket?.resume()
    }
    
    func receive() {
        webSocket?.receive { [weak self] result in
            switch result {
            case .success(let message):
                self?.handle(message: message)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func send(message: String) {
        webSocket?.send(.string(message)) { error in
            if let error {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: Delegate Methods
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        receive()
    }
    
    // MARK: Helper Methods
    
    func handle(message: URLSessionWebSocketTask.Message) {
        switch message {
        case .string(let message):
            if message == "ping" {
                send(message: "pong")
            }
        default:
            break
        }
    }
    
    func generateURLForServerWith(host: String, port: String) -> URL? {
        var components = URLComponents()
        
        components.scheme = "ws"
        components.host = host
        components.port = Int(port)
                
        return components.url
    }
    
}
