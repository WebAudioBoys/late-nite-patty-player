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

    var tempoVal: Float = 120
    var velocityVal: Float = 128
    
    @IBOutlet var tempo: UISlider!
    
    @IBAction func tempoChange(_ sender: Any) {
        tempoVal = floor(tempo.value * 220) + 30
    }
    
    @IBOutlet var velocity: UISlider!
    
    @IBAction func velocityChange(_ sender: Any) {
        velocityVal = floor(velocity.value * 128)
        print(velocityVal)
    }
    
    @IBAction func kick(_ sender: Any) {
        sendMessage(0x90, 0x24, UInt8(velocityVal))
        sendMessage(0x80, 0x24, 0x7f)
    }
    
    @IBAction func rim(_ sender: Any) {
        sendMessage(0x90, 0x25, UInt8(velocityVal))
        sendMessage(0x80, 0x25, 0x7f)
    }
    
    @IBAction func snare(_ sender: Any) {
        sendMessage(0x90, 0x26, UInt8(velocityVal))
        sendMessage(0x80, 0x26, 0x7f)
    }
    
    @IBAction func clap(_ sender: Any) {
        sendMessage(0x90, 0x27, UInt8(velocityVal))
        sendMessage(0x80, 0x27, 0x7f)
    }
    
    @IBAction func hihat(_ sender: Any) {
        sendMessage(0x90, 0x2a, UInt8(velocityVal))
        sendMessage(0x80, 0x2a, 0x7f)
    }
    
    @IBAction func hihatOpen(_ sender: Any) {
        sendMessage(0x90, 0x2e, UInt8(velocityVal))
        sendMessage(0x80, 0x2e, 0x7f)
    }
    
    @IBAction func tomLo(_ sender: Any) {
        sendMessage(0x90, 0x2d, UInt8(velocityVal))
        sendMessage(0x80, 0x2d, 0x7f)
    }
    
    @IBAction func tomMid(_ sender: Any) {
        sendMessage(0x90, 0x2f, UInt8(velocityVal))
        sendMessage(0x80, 0x2f, 0x7f)
    }
    
    @IBAction func tomHi(_ sender: Any) {
        sendMessage(0x90, 0x30, UInt8(velocityVal))
        sendMessage(0x80, 0x30, 0x7f)
    }
    
    @IBAction func cymbal(_ sender: Any) {
        sendMessage(0x90, 0x31, UInt8(velocityVal))
        sendMessage(0x80, 0x31, 0x7f)
    }
    
    @IBAction func cowbell(_ sender: Any) {
        sendMessage(0x90, 0x38, UInt8(velocityVal))
        sendMessage(0x80, 0x38, 0x7f)
    }
    
    @IBAction func congaLo(_ sender: Any) {
        sendMessage(0x90, 0x40, UInt8(velocityVal))
        sendMessage(0x80, 0x40, 0x7f)
    }
    
    @IBAction func congaMid(_ sender: Any) {
        sendMessage(0x90, 0x3f, UInt8(velocityVal))
        sendMessage(0x80, 0x3f, 0x7f)
    }
    
    @IBAction func congaHi(_ sender: Any) {
        sendMessage(0x90, 0x3e, UInt8(velocityVal))
        sendMessage(0x80, 0x3e, 0x7f)
    }
    
    @IBAction func maraca(_ sender: Any) {
        sendMessage(0x90, 0x46, UInt8(velocityVal))
        sendMessage(0x80, 0x46, 0x7f)
    }
    
    @IBAction func clave(_ sender: Any) {
        sendMessage(0x90, 0x4b, UInt8(velocityVal))
        sendMessage(0x80, 0x4b, 0x7f)
    }
    

    
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

}

