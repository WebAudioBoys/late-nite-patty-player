//
//  ViewController.swift
//  Patty Player
//
//  Created by Brad & Dave-O on 11/13/17.
//  Copyright © 2017 Brad & Dave-0. All rights reserved.
//

import UIKit
import CoreMIDI

class ViewController: UIViewController, NetServiceBrowserDelegate {
    
    let browser = NetServiceBrowser()
    
    var endpoint: MIDIEndpointRef? = nil
    var outputPort: MIDIPortRef? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        browser.delegate = self
        browser.searchForServices(ofType: MIDINetworkBonjourServiceType, inDomain: "")
        print("Searching for type \(MIDINetworkBonjourServiceType)")
    }
    
    var services: [NetService] = []
    
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        print("didFindService:", service, "moreComing:", moreComing)
        
        services.append(service)
        connectMIDINetwork()
    }
    
    func connectMIDINetwork() {
        let service = services[0]
        print("printing to:", service)
        let host = MIDINetworkHost(name: service.name, netService: service)
        let connection = MIDINetworkConnection(host: host)
        
        let session = MIDINetworkSession.default()
        session.addConnection(connection)
        session.isEnabled = true
        
        var client = MIDIClientRef()
        MIDIClientCreateWithBlock("MIDI Client" as CFString, &client) { p in
            let notification: MIDINotification = p.pointee
            print("Notification: \(notification)")
        }
        
        var port = MIDIPortRef()
        MIDIOutputPortCreate(client, "MIDI Output" as CFString, &port)
        
        self.endpoint = session.destinationEndpoint()
        self.outputPort = port
        
        print("Output Port:", port)
    }

    func sendMessage(_ status: UInt8, _ data1: UInt8, _ data2: UInt8, timestamp: MIDITimeStamp = 0) {
        guard let outputPort = self.outputPort, let endpoint = self.endpoint else {
            print("No outputPort or endpoint available")
            return
        }
        
        var list = MIDIPacketList()
        list.numPackets = 1
        list.packet.timeStamp = 0
        list.packet.length = 3
        list.packet.data.0 = status
        list.packet.data.1 = data1
        list.packet.data.2 = data2
        
        MIDISend(outputPort, endpoint, &list)
        print("Sent message: (\(status), \(data1), \(data2)) to port: \(outputPort), endpoint: \(endpoint)")
    }
    
    @IBAction func click(_ sender: Any) {
        sendMessage(0x90, 0x24, 0x7f)
    }
    
}

