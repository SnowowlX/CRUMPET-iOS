//
//  TblCellMoveListUpdate.swift
//  Digitail
//
//  Created by Iottive on 09/07/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class TblCellMoveListUpdate: MGSwipeTableCell {
    
    @IBOutlet var lblSeconds: UILabel!
    
    
    @IBOutlet var btnMenu: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
