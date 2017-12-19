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

    var tempoVal: Double = 0.25
    var velocityVal: Float = 127
    var timer: Timer? = nil
    var mode = -1
    var playing: Int = -1
    var pattern: Int = 0
    var nextPattern: Int = 0
    var step: Int = 0
    
    var beats: [[[Int]]] = [
       // 0 - motorik
       [[1,0,1,0,0,0,1,0,1,0,1,0,0,0,1,0],
        [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
        [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],
       // 1 - ramones
       [[1,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0],
        [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
        [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],
       // 2 - fill 1
       [[1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0],
        [0,0,0,0,1,0,0,0,0,0,1,1,1,1,1,1],
        [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],
       // 3 - fill 2
       [[1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0],
        [1,1,0,0,1,1,0,0,1,1,0,0,0,0,0,0],
        [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],
        [0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,1,1,0,0,0,0,1,1,1,1]],
       // 4 - metal fill
       [[0,0,1,1,0,0,1,1,0,0,1,1,0,0,0,0],
        [1,1,0,0,0,0,0,0,0,0,0,0,1,0,0,0],
        [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],
        [0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0],
        [0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0]],
       // 5 - Fill
        [[1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0],
         [1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0],
         [0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0]],
        // 6 - Haha Beat
        [[1,0,0,0,0,0,0,0,1,0,0,0,0,1,0,0],
         [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
         [1,0,1,1,1,0,1,1,1,0,1,1,1,0,1,1],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],
        // 7 - Linear Beat
        [[1,0,0,1,0,1,0,0,1,0,0,1,0,1,0,0],
         [0,1,0,0,1,0,0,1,0,1,0,0,1,0,0,1],
         [0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0],
         [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0],
         [0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0]],
        // 8 - B-B-B-BASIC BEAT
        [[1,0,0,0,0,0,1,0,1,0,1,0,0,0,0,0],
         [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
         [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0]],
        // 9 - STEVIE WONDER BEAT
        [[1,0,0,0,0,0,1,0,1,0,1,0,0,0,1,0],
         [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,1],
         [1,0,1,1,1,1,1,0,1,0,1,1,1,1,1,0],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],
        // 10 - COUNTRY BEAT
        [[1,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0],
         [0,0,1,0,0,0,1,0,0,0,1,0,0,0,1,0],
         [1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],
        // 11 - FUNNY WEEZER FILL
        [[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0],
         [0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0]],
        // 12 - Trapish
        [[1,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1],
         [0,0,0,0,1,0,0,1,0,0,0,0,1,0,0,0],
         [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],
        // 13 - Fresh/Clean
        [[1,1,0,1,0,1,0,1,0,1,0,1,0,1,1,1],
         [0,0,0,0,1,0,0,0,0,0,0,0,1,0,0,0],
         [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]],
        // 14 - Randy fill, baby!
        [[1,0,1,0,1,0,1,0,1,0,1,0,1,0,1,0],
         [0,1,0,0,1,0,1,1,0,1,0,0,1,0,0,1],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [0,0,1,0,1,0,1,0,0,0,1,0,0,1,0,0],
         [0,0,0,1,0,1,0,0,0,0,0,1,0,0,1,0]],
        // 15 - Thrill Fill
        [[0,1,0,0,1,0,0,0,1,0,0,1,0,1,0,0],
         [1,0,1,1,1,0,0,0,0,0,1,0,1,0,1,1],
         [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
         [0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,0],
         [0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0]]
   ]

    @IBOutlet weak var modeLabel: UILabel!
    
    @IBAction func toggleMode(_ sender: Any) {
        self.mode = self.mode * -1
        if (mode == -1) {
            self.modeLabel.text = "Tap"
        } else {
            self.modeLabel.text = "1"
        }
    }
    
    @IBAction func togglePlay(_ sender: Any) {
        self.playing = self.playing * -1
        if (playing == 1) {
            timer = Timer.scheduledTimer(withTimeInterval: self.tempoVal, repeats: true) { timer in
                if (self.step == 0 && self.pattern != self.nextPattern) {
                    self.pattern = self.nextPattern
                    self.modeLabel.text = String(self.pattern + 1)
                }
                if (self.beats[self.pattern][2][self.step] == 1) {
                    self.sendMessage(0x90, 0x2a, UInt8(self.velocityVal))
                    self.sendMessage(0x80, 0x2a, 0x7f)
                }
                if (self.beats[self.pattern][1][self.step] == 1) {
                    self.sendMessage(0x90, 0x26, UInt8(self.velocityVal))
                    self.sendMessage(0x80, 0x26, 0x7f)
                }
                if (self.beats[self.pattern][0][self.step] == 1) {
                    self.sendMessage(0x90, 0x24, UInt8(self.velocityVal))
                    self.sendMessage(0x80, 0x24, 0x7f)
                }
                if (self.beats[self.pattern][3][self.step] == 1) {
                    self.sendMessage(0x90, 0x2f, UInt8(self.velocityVal))
                    self.sendMessage(0x80, 0x2f, 0x7f)
                }
                if (self.beats[self.pattern][4][self.step] == 1) {
                    self.sendMessage(0x90, 0x2b, UInt8(self.velocityVal))
                    self.sendMessage(0x80, 0x2b, 0x7f)
                }
                

                
                // TODO: add the rest of the drums here
                self.step = (self.step + 1) % 16
            }
            timer?.fire()
        } else {
            timer?.invalidate()
            self.step = 0
        }
    }
    
    @IBOutlet var tempo: UISlider!
    
    @IBAction func tempoChange(_ sender: Any) {
        tempoVal = Double(15 / ((tempo.value * 220) + 30))
    }
    
    @IBOutlet var velocity: UISlider!
    
    @IBAction func velocityChange(_ sender: Any) {
        velocityVal = floor(velocity.value * 127)
    }
    
    @IBAction func kick(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x24, UInt8(velocityVal))
            sendMessage(0x80, 0x24, 0x7f)
        } else {
            self.nextPattern = 0
        }
    }
    
    @IBAction func rim(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x25, UInt8(velocityVal))
            sendMessage(0x80, 0x25, 0x7f)
        } else {
            self.nextPattern = 1
        }
    }
    
    @IBAction func snare(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x26, UInt8(velocityVal))
            sendMessage(0x80, 0x26, 0x7f)
        } else {
            self.nextPattern = 2
        }
    }
    
    @IBAction func clap(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x27, UInt8(velocityVal))
            sendMessage(0x80, 0x27, 0x7f)
        } else {
            self.nextPattern = 3
        }
    }
    
    @IBAction func hihat(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x2a, UInt8(velocityVal))
            sendMessage(0x80, 0x2a, 0x7f)
        } else {
            self.nextPattern = 4
        }
    }
    
    @IBAction func hihatOpen(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x2e, UInt8(velocityVal))
            sendMessage(0x80, 0x2e, 0x7f)
        } else {
            self.nextPattern = 5
        }
    }
    
    @IBAction func tomLo(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x2d, UInt8(velocityVal))
            sendMessage(0x80, 0x2d, 0x7f)
        } else {
            self.nextPattern = 6
        }
    }
    
    @IBAction func tomMid(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x2f, UInt8(velocityVal))
            sendMessage(0x80, 0x2f, 0x7f)
        } else {
            self.nextPattern = 7
        }
    }
    
    @IBAction func tomHi(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x30, UInt8(velocityVal))
            sendMessage(0x80, 0x30, 0x7f)
        } else {
            self.nextPattern = 8
        }
    }
    
    @IBAction func cymbal(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x31, UInt8(velocityVal))
            sendMessage(0x80, 0x31, 0x7f)
        } else {
            self.nextPattern = 9
        }
    }
    
    @IBAction func cowbell(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x38, UInt8(velocityVal))
            sendMessage(0x80, 0x38, 0x7f)
        } else {
            self.nextPattern = 10
        }
    }
    
    @IBAction func congaLo(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x40, UInt8(velocityVal))
            sendMessage(0x80, 0x40, 0x7f)
        } else {
            self.nextPattern = 11
        }
    }
    
    @IBAction func congaMid(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x3f, UInt8(velocityVal))
            sendMessage(0x80, 0x3f, 0x7f)
        } else {
            self.nextPattern = 12
        }
    }
    
    @IBAction func congaHi(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x3e, UInt8(velocityVal))
            sendMessage(0x80, 0x3e, 0x7f)
        } else {
            self.nextPattern = 13
        }
    }
    
    @IBAction func maraca(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x46, UInt8(velocityVal))
            sendMessage(0x80, 0x46, 0x7f)
        } else {
            self.nextPattern = 14
        }
    }
    
    @IBAction func clave(_ sender: Any) {
        if (self.mode == -1) {
            sendMessage(0x90, 0x4b, UInt8(velocityVal))
            sendMessage(0x80, 0x4b, 0x7f)
        } else {
            self.nextPattern = 15
        }
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

