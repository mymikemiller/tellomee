//
//  ThemedButton.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/25/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

class ThemedButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        self.backgroundColor = Config.current.mainColor
    }
}