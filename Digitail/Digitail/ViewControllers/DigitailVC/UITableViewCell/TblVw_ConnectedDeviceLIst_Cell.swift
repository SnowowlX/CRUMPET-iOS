//
//  TblVw_ConnectedDeviceLIst_Cell.swift
//  CRUMPET
//
//  Created by Bhavik Patel on 08/03/21.
//  Copyright © 2021 Iottive. All rights reserved.
//

import UIKit

class TblVw_ConnectedDeviceLIst_Cell: UITableViewCell {

    @IBOutlet weak var iv_BatteryStatus: UIImageView!
    @IBOutlet weak var lblDeviceName: UILabel!
    @IBOutlet weak var lblPercentage: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var btnDeviceInfo: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
