//
//  TblCellCasualModeSetting.swift
//  Digitail
//
//  Created by Iottive on 28/06/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit

class TblCellCasualModeSetting: UITableViewCell {
    
    @IBOutlet var btnCheckBox: UIButton!
    
    
    @IBOutlet var lblCasualCategoryName: UILabel!
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
