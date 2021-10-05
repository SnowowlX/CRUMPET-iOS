//
//  TblVw_DeviceList_Cell.swift
//  CRUMPET
//
//  Created by Bhavik Patel on 05/03/21.
//  Copyright © 2021 Iottive. All rights reserved.
//

import UIKit

class TblVw_DeviceList_Cell: UITableViewCell {

    @IBOutlet weak var lblDeviceUuid: UILabel!
    @IBOutlet weak var btnConnect: UIButton!
    @IBOutlet weak var lblDeviceName: UILabel!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
