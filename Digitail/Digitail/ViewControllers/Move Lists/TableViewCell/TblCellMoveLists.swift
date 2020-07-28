//
//  TblCellMoveLists.swift
//  Digitail
//
//  Created by Iottive on 03/07/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import MGSwipeTableCell

class TblCellMoveLists: MGSwipeTableCell {
    
    @IBOutlet var lblMoveName: UILabel!
    @IBOutlet var btnSwipeMenu: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
