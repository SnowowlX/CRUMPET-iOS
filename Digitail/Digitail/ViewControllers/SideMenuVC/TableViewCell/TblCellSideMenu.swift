//
//  TblCellSideMenu.swift
//  Digitail
//
//  Created by Iottive on 21/06/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit

class TblCellSideMenu: UITableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblMenuName: UILabel!
    @IBOutlet weak var modeSwitch: UISwitch!
    
    var changeMode:((Bool) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func modeSwitchAction(_ sender: UISwitch) {
        changeMode?(sender.isOn)
    }
}
