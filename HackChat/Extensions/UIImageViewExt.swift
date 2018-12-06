//
//  UIImageViewExt.swift
//  HackChat
//
//  Created by Milan Bojic on 12/7/18.
//  Copyright © 2018 Milan Bojic. All rights reserved.
//

import UIKit

extension UIImageView {
    
    public func maskCircle(anyImage: UIImage) {
        self.contentMode = .scaleAspectFill
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.masksToBounds = false
        self.clipsToBounds = true
        self.layer.borderWidth = 1.0
        self.layer.borderColor = #colorLiteral(red: 0.1318563018, green: 0.140281814, blue: 0.1578911434, alpha: 1)
        self.image = anyImage
    }
}
