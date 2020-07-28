//
//  tblCellAlarms.swift
//  Digitail
//
//  Created by Iottive on 07/06/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import  MGSwipeTableCell

class tblCellAlarms: MGSwipeTableCell {
    
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var lblAlrmEventName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
