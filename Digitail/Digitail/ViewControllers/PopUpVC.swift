//
//  PopUpVC.swift
//  Digitail
//
//  Created by Iottive on 25/06/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
//import JTAppleCalendar

class PopUpVC: UIViewController {

    var currentDate: Date! = Date() {
        didSet {
            //    setDate()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = Date()
        ViewPicker()
    }

    func ViewPicker()  {
        let xibView = Bundle.main.loadNibNamed("CalendarPopUp", owner: nil, options: nil)?[0] as! CalendarPopUp
        xibView.calendarDelegate = self
        xibView.selected = currentDate
        xibView.startDate = Calendar.current.date(byAdding: .month, value: -12, to: currentDate)!
       PopupContainer.generatePopupWithView(xibView).show()
    }

}

extension PopUpVC: CalendarPopUpDelegate {
    func dateChaged(date: Date) {
        //  ArrDelegateData = NSMutableArray()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        print(formatter.string(from: date as Date) as NSString)
        //SelectedDate = formatter.string(from: date as Date) as NSString
    }
}
