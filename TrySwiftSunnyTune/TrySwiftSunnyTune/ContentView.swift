//
//  ContentView.swift
//  TrySwiftSunnyTune
//
//  Created by hisaki sato on 2024/03/22.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {
    
    @State var time: Float = 1
    @State var cloud: Float = 0
    @State var windAngle: Float = 0
    @State var windPower: Float = 0
    @State var dome: Entity?
    @State var grass: Entity?
    
    var body: some View {
        ZStack {
            RealityView { content in
                if let scene = try? await Entity(named: "Scene", in: realityKitContentBundle) {
                    self.dome = scene.findEntity(named: "Dome_geometry")
                    self.grass = scene.findEntity(named: "Grass_geometry")
                    content.add(scene)
                }
            }
            VStack {
                HStack {
                    Image(systemName: "timer")
                    Slider(value: $time, in: -1...1)
                        .onChange(of: time) { oldValue, newValue in
                           updateTime(time: newValue)
                    }
                }
                HStack {
                    Image(systemName: "cloud")
                    Slider(value: $cloud, in: 0...1)
                        .onChange(of: cloud) { oldValue, newValue in
                           updateCloud(cloud: newValue)
                    }
                }
                HStack {
                    Image(systemName: "angle")
                    Slider(value: $windAngle, in: 0...360)
                        .onChange(of: windAngle) { oldValue, newValue in
                            UpdateWind(angle: .init(degrees: Double(newValue)), power: windPower)
                    }
                }
                HStack {
                    Image(systemName: "wind")
                    Slider(value: $windPower, in: 0...2)
                        .onChange(of: windPower) { oldValue, newValue in
                            UpdateWind(angle: .init(degrees: Double(windAngle)), power: newValue)
                    }
                }
            }
            .padding()
            .frame(width: 300)
            .glassBackgroundEffect()
            .offset(y:100)
        }
    }
    
    func UpdateWind(angle:Angle, power:Float) {
        updateMaterial(entity: self.grass) { material in
            let wind = SIMD3<Float>(Float(cos(angle.radians)), 0, Float(sin(angle.radians))) * power
            try? material.setParameter(name: "Wind", value: .simd3Float(wind))
        }
    }
    
    func updateTime(time:Float){
        updateMaterial(entity: self.dome) { material in
            try? material.setParameter(name: "Time", value: .float(time))
        }
    }
    
    func updateCloud(cloud:Float){
        updateMaterial(entity: self.dome) { material in
            try? material.setParameter(name: "Cloud", value: .float(cloud))
        }
    }
    
    func updateMaterial(entity:Entity?, callback:@escaping (inout ShaderGraphMaterial)->Void) {
        guard var modelComponent = entity?.components[ModelComponent.self] else { return }
        
        guard var material = modelComponent.materials.first as? ShaderGraphMaterial else { return }
        
        callback(&material)
        
        modelComponent.materials = [material]
        entity?.components.set(modelComponent)
    }
}

#Preview(windowStyle: .volumetric) {
    ContentView()
}
