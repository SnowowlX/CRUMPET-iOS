//
//  CalendarPopUp.swift
//  CalendarPopUp
//
//  Created by Atakishiyev Orazdurdy on 11/16/16.
//  Copyright © 2016 Veriloft. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol CalendarPopUpDelegate: class {
    func dateChaged(date: Date)
}

class CalendarPopUp: UIView {
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblYear: UILabel!
    @IBOutlet weak var calendarView: JTACMonthView!
    @IBOutlet weak var dateLabel: UILabel!
    weak var calendarDelegate: CalendarPopUpDelegate?

    var endDate: Date!
    var startDate: Date = Date().getStart()
    var testCalendar = Calendar(identifier: .gregorian)
    var selectedDate: Date! = Date() {
        didSet {
            setDate()
        }
    }
    var selected:Date = Date() {
        didSet {
            calendarView.scrollToDate(selected)
            calendarView.selectDates([selected])
        }
    }

    @IBAction func closePopupButtonPressed(_ sender: AnyObject) {
        if let superView = self.superview as? PopupContainer {
            (superView ).close()
        }
    }

    @IBAction func GetDateOk(_ sender: Any) {
        calendarDelegate?.dateChaged(date: selectedDate)
        if let superView = self.superview as? PopupContainer {
            (superView ).close()
        }
    }

    @IBAction func Previous_Clicked(_ sender: UIButton) {
         calendarView.scrollToSegment(.previous)
        let visibleDates = calendarView.visibleDates()
        setupViewsOfCalendar(from: visibleDates)
    }

    @IBAction func Next_Clicked(_ sender: UIButton) {
        calendarView.scrollToSegment(.next)
        let visibleDates = calendarView.visibleDates()
        setupViewsOfCalendar(from: visibleDates)
    }

    @IBAction func Today_Clicked(_ sender: UIButton) {
       // calendarView.scrollToSegment()
        calendarView.selectDates([Date()], triggerSelectionDelegate: true)
    }

    override func awakeFromNib() {
        //Calendar
        // You can also use dates created from this function -2 , 4
        startDate = Calendar.current.date(byAdding: .month, value: -1000, to: startDate)!
        endDate = Calendar.current.date(byAdding: .month, value: 2000, to: startDate)!
        setDate()
        self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
        setCalendar()

    }

    func setDate() {
        let month = testCalendar.dateComponents([.month], from: selectedDate).month!
        let weekday = testCalendar.component(.weekday, from: selectedDate)

        let monthName = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)
        let week = DateFormatter().shortWeekdaySymbols[weekday-1] //GetTurkmenWeek(weekDay: weekday)
        
        let year = testCalendar.component(.year, from: selectedDate)

        let day = testCalendar.component(.day, from: selectedDate)

       // dateLabel.text = "\(week), " + monthName + " " + String(day)
        
        // dateLabel.text = "\(week), " + monthName + " " + String(day)
         dateLabel.text = "\(monthName )" + "  " +  String(year)
    }

    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = testCalendar.dateComponents([.month], from: startDate)
        let monthName = DateFormatter().monthSymbols[Int(month.month!)-1] //GetHumanDate(month: month)

        let year = testCalendar.component(.year, from: startDate)
        
        dateLabel.text = "\(monthName)" + "  " + String(year)
      //  calendarHeaderLabel.text = monthName + ", " + String(year)
    }

    func setCalendar() {
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        let nibName = UINib(nibName: "CellView", bundle:nil)
        calendarView.register(nibName, forCellWithReuseIdentifier: "CellView")
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
    }

}

// MARK : JTAppleCalendarDelegate
extension CalendarPopUp: JTACMonthViewDelegate, JTACMonthViewDataSource {

    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"

        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: testCalendar,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .sunday)

        return parameters
    }

    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        (cell as? CellView)?.handleCellSelection(cellState: cellState, date: date, selectedDate: selectedDate)
    }

    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        myCustomCell.handleCellSelection(cellState: cellState, date: date, selectedDate: selectedDate)
        return myCustomCell
    }

    func calendar(_ calendar: JTACMonthView, didSelectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath){

        selectedDate = date
        
        //For Getting Date
        let month = testCalendar.dateComponents([.month], from: selectedDate).month!
        let weekday = testCalendar.component(.weekday, from: selectedDate)
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)
        let week = DateFormatter().shortWeekdaySymbols[weekday - 1] //GetTurkmenWeek(weekDay: weekday)
        let year = testCalendar.component(.year, from: selectedDate)
        let day = testCalendar.component(.day, from: selectedDate)
        lblDate.text = "\(week), " + monthName + " " + String(day)
        lblYear.text = "\(year)"
        (cell as? CellView)?.cellSelectionChanged(cellState, date: date)
    }

    func calendar(_ calendar: JTACMonthView, didDeselectDate date: Date, cell: JTACDayCell?, cellState: CellState, indexPath: IndexPath) {
        (cell as? CellView)?.cellSelectionChanged(cellState, date: date)
    }

    func calendar(_ calendar: JTACMonthView, willResetCell cell: JTACDayCell) {
        (cell as? CellView)?.selectedView.isHidden = true
    }

    func calendar(_ calendar: JTACMonthView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.setupViewsOfCalendar(from: visibleDates)
    }
}

