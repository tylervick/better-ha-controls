//
//  WebServer.swift
//  Better HA Controls
//
//  Created by Tyler Vick on 5/15/22.
//

import Darwin.C

func serveOAuthCallback() {
    let zero = Int8(0)
    let transportLayerType = SOCK_STREAM
    let internetLayerProtocol = AF_INET
    let sock = socket(internetLayerProtocol, Int32(transportLayerType), 0)
    let portNumber = UInt16(4000)  // TODO: make this random/dynamic
    let socklen = UInt8(socklen_t(MemoryLayout<sockaddr_in>.size))
    var serveraddr = sockaddr_in()
    serveraddr.sin_family = sa_family_t(AF_INET)
    serveraddr.sin_port = in_port_t((portNumber << 8) + (portNumber >> 8))
    serveraddr.sin_addr = in_addr(s_addr: in_addr_t(0))
    serveraddr.sin_zero = (zero, zero, zero, zero, zero, zero, zero, zero)
    withUnsafePointer(to: &serveraddr) { sockaddrInPtr in
        let sockaddrPtr = UnsafeRawPointer(sockaddrInPtr).assumingMemoryBound(to: sockaddr.self)
        bind(sock, sockaddrPtr, socklen_t(socklen))
    }
    listen(sock, 4)

    let client = accept(sock, nil, nil)
    let html = """
        <!DOCTYPE html><link rel='redirect_uri' href='betterha://auth'><html><body></body></html>
        """
    let httpResponse = """
        HTTP/1.1 200 OK
        server: better-ha-controls
        content-length: \(html.count)

        \(html)
        """
    
    httpResponse.withCString { bytes in
        send(client, bytes, Int(strlen(bytes)), 0)
        close(client)
    }
    
    shutdown(sock, SHUT_RDWR)
    close(sock)
}
