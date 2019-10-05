//
//  ViewController.swift
//  ARWithOSCStudy
//
//  Created by mio kato on 2019/10/05.
//  Copyright © 2019 si-ro. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import F53OSC

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate  {

    @IBOutlet var sceneView: ARSCNView!

    var shipNode: SCNNode?
    
    let server = F53OSCServer.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView.delegate = self
        sceneView.session.delegate = self
        
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.scene = SCNScene(named: "art.scnassets/ship.scn")!
        shipNode = sceneView.scene.rootNode.childNodes.first!
        shipNode?.simdPosition = simd_float3(0, -0.1, -0.8)
        
        // osc
        server.port = 8080
        server.delegate = self
        
        if server.startListening() {
            print("server listning \(server.port)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()

        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
}

extension ViewController: F53OSCPacketDestination {
    func take(_ message: F53OSCMessage?) {
        guard let node = shipNode else {return}
        
        let value: Int = message?.arguments[0] as! Int
        let smoothed = round(Float(value) * 5.0) / 5.0
        let deg = round(smoothed / 1024.0 * 360)
        let rad = 2 * Float.pi * deg / 360
        
        node.eulerAngles.y = rad
    }
}
