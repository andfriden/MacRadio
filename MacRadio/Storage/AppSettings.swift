//
//  AppSettings.swift
//  MacRadio
//
//  Created by Андерс Фриден on 16.08.2026.
//

import Foundation
import Combine


final class AppSettings: ObservableObject {
    
    
    @Published var lastStationID: String {
        
        didSet {
            
            UserDefaults.standard.set(
                lastStationID,
                forKey: "lastStationID"
            )
            
        }
        
    }
    
    
    
    @Published var volume: Double {
        
        didSet {
            
            UserDefaults.standard.set(
                volume,
                forKey: "volume"
            )
            
        }
        
    }
    
    
    
    @Published var isMuted: Bool {
        
        didSet {
            
            UserDefaults.standard.set(
                isMuted,
                forKey: "isMuted"
            )
            
        }
        
    }
    
    
    
    init() {
        
        let savedVolume =
        UserDefaults.standard.object(
            forKey: "volume"
        ) as? Double
        ?? 1.0
        
        
        lastStationID =
        UserDefaults.standard.string(
            forKey: "lastStationID"
        )
        ?? ""
        
        
        volume = savedVolume
        
        
        isMuted =
        UserDefaults.standard.bool(
            forKey: "isMuted"
        )
        
    }
}
