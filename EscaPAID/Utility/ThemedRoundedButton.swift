//
//  ThemedRoundedButton.swift
//  EscaPAID
//
//  Created by Michael Miller on 4/18/18.
//  Copyright © 2018 Michael Miller. All rights reserved.
//

import UIKit

@IBDesignable class ThemedRoundedButton: RoundedButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        // sharedInit() This crashes in Interface Builder for some reason
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    func sharedInit() {
        self.setTitleColor(Config.current.mainColor, for: .normal)
        self.tintColor = Config.current.mainColor
    }
}
