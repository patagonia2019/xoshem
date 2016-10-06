//
//  TitleView.swift
//  Xoshem
//
//  Created by Javier Fuchs on 8/18/16.
//  Copyright © 2016 Fuchs. All rights reserved.
//

import UIKit

class TitleView: UILabel {
    
    init(appName: String, title: String?) {
        super.init(frame: CGRectMake(0, 0, 100, 50))
        self.font = UIFont.boldSystemFontOfSize(20)
        self.textColor = UIColor.whiteColor()
        self.shadowColor = UIColor.blackColor()
        self.shadowOffset = CGSize(width: 1, height: 1)
        self.text = appName
        if let _title = title {
            self.text = self.text! + " " + _title
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

