//
//  AlarmsVC.swift
//  Digitail
//
//  Created by Iottive on 07/06/19.
//  Copyright © 2019 Iottive. All rights reserved.
//

import UIKit
import MGSwipeTableCell
import SideMenu

let kError = "Error"
let kMsgAlarmName = "needs movelist name"
let kArrDictAlarmDetail = "AlrmDetail"
let kArrDictMoveList = "MoveList"
let kAlarmName = "AlarmName"
let kMoveName = "MoveName"
let kAlarmTime = "AlarmTime"

class AlarmsVC:UIViewController,UITableViewDelegate,UITableViewDataSource,MGSwipeTableCellDelegate,UITextFieldDelegate
{
    //MARK: - Properties
    @IBOutlet weak var tableView: UITableView!
    var indexPathForOpr : Int!
    var selectedDate : String!
    var selectedTime : String!
    var selectedDateTime : String!
    var convertedArray: [Date] = []
    var ConvertedArrDict = [[String:Any]]()
    let defaultCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        return calendar
    }()
    
    @IBOutlet var lblDeletePopDesc: UILabel!
    @IBOutlet var btnCreate: UIButton!
    @IBOutlet var btnMenu: UIButton!
    
    @IBOutlet weak var viewAlarmDesc: UIView!
    @IBOutlet weak var btnAddAlrm: UIButton!
    @IBOutlet weak var viewPopUpAddAlrmBackground: UIView!
    @IBOutlet weak var viewAddAlarmPopUp: UIView!
    @IBOutlet var viewPopUpDelete: UIView!
    @IBOutlet weak var txtAlrmName: UITextField!
    @IBOutlet weak var viewBotoomFortxt: UIView!
    var arrdictAlarmData = [[String:Any]]()
    @IBOutlet var pickerViewTime: UIDatePicker!
    @IBOutlet var nsLayoutPickerViewBottom: NSLayoutConstraint!
   
    var currentDate: Date! = Date() {
        didSet {
            //    setDate()
        }
    }
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUI()
        tableView.reloadData()
        currentDate = Date()
    }
    //MARK: - Custome Function -
    func setUpMainUI(){
        
        btnMenu.layer.cornerRadius = 5.0

        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        
        btnCreate.isUserInteractionEnabled = false
        btnCreate.alpha = 0.5
        
    
         let tapRegister: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AlarmsVC.dismissKeyboard))
        viewPopUpAddAlrmBackground.addGestureRecognizer(tapRegister)
        nsLayoutPickerViewBottom.constant = -207
        pickerViewTime.datePickerMode = .time
        pickerViewTime.isHidden = true
        viewAlarmDesc.layer.shadowColor = UIColor.darkGray.cgColor
        viewAlarmDesc.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        viewAlarmDesc.layer.shadowRadius = 1.7
        viewAlarmDesc.layer.shadowOpacity = 0.5
        
        btnAddAlrm.layer.cornerRadius = btnAddAlrm.frame.height/2.0
        btnAddAlrm.clipsToBounds = true
        
        viewPopUpAddAlrmBackground.isHidden = true
        viewAddAlarmPopUp.isHidden = true
        viewPopUpDelete.isHidden = true
        
        if let arrDictAlarmDetail = UserDefaults.standard.array(forKey: kArrDictAlarmDetail) as? [[String: Any]] {
            arrdictAlarmData = arrDictAlarmDetail
        }
        txtAlrmName.delegate = self
        
        viewPopUpDelete.layer.shadowColor = UIColor.black.cgColor
        viewPopUpDelete.layer.shadowOpacity = 1
        viewPopUpDelete.layer.shadowOffset = .zero
        viewPopUpDelete.layer.shadowRadius = 10
        
        viewAddAlarmPopUp.layer.shadowColor = UIColor.black.cgColor
        viewAddAlarmPopUp.layer.shadowOpacity = 1
        viewAddAlarmPopUp.layer.shadowOffset = .zero
        viewAddAlarmPopUp.layer.shadowRadius = 10
        
        btnMenu.layer.cornerRadius = 5.0
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
        viewPopUpAddAlrmBackground.isHidden = true
        viewAddAlarmPopUp.isHidden = true
        viewPopUpDelete.isHidden = true
        
    }
    
    func openAlertView() {
        let alert = UIAlertController(title: kError, message: kMsgAlarmName, preferredStyle: UIAlertController.Style.alert)
        //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
            ///print("User click Ok button")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showPickerView(){
        pickerViewTime.isHidden = false
        pickerViewTime.reloadInputViews()
        self.nsLayoutPickerViewBottom.constant = 0;
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hidePickerView(){
        self.nsLayoutPickerViewBottom.constant = -207;
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func ViewPicker()  {
      //  return

        let xibView = Bundle.main.loadNibNamed("CalendarPopUp", owner: nil, options: nil)?[0] as! CalendarPopUp
        xibView.calendarDelegate = self
        xibView.selected = currentDate
        xibView.startDate = Calendar.current.date(byAdding: .month, value: -12, to: currentDate)!
        PopupContainer.generatePopupWithView(xibView).show()
    }
    
    //MARK: - Actions -
    @IBAction func Menu_Clicked(_ sender: UIButton) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        present(SideMenuManager.default.leftMenuNavigationController!, animated: true, completion: nil)
    }
    
    @objc func Swipable_Menu_Clicked(sender: UIButton){
        let section = 0
        let row = sender.tag
        let indexPath = IndexPath(row: row, section: section)
        let cell: MGSwipeTableCell = self.tableView.cellForRow(at: indexPath) as! MGSwipeTableCell
        cell.showSwipe(.rightToLeft, animated: true)
    }
    
    @IBAction func Add_Alarm_Clicked(_ sender: UIButton) {
        viewPopUpAddAlrmBackground.isHidden = false
        viewAddAlarmPopUp.isHidden = false
    }
    
    @IBAction func Cancel_Clicked(_ sender: UIButton) {
        hidePickerView()
    }
    
    @IBAction func Ok_Clicked_popupDelete(_ sender: UIButton) {
        if let arrDictAlarmDetail = UserDefaults.standard.array(forKey: kArrDictAlarmDetail) as? [[String: Any]] {
            arrdictAlarmData = arrDictAlarmDetail
        }
        self.arrdictAlarmData.remove(at: indexPathForOpr)
     UserDefaults.standard.set(self.arrdictAlarmData, forKey: kArrDictAlarmDetail)
        viewPopUpAddAlrmBackground.isHidden = true
        viewPopUpDelete.isHidden = true
        tableView.reloadData()
    }
    
    @IBAction func Cancel_Clicked_PopupDelete(_ sender: UIButton) {
        viewPopUpAddAlrmBackground.isHidden = true
        viewPopUpDelete.isHidden = true
    }
    
    @IBAction func Ok_Clicked(_ sender: UIButton) {
        if selectedTime == nil{
            let alert = UIAlertController(title: kError, message: "Plese Select Time", preferredStyle: UIAlertController.Style.alert)
            //        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:nil))
            alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
                ///print("User click Ok button")
            }))
            self.present(alert, animated: true, completion: nil)        }
        else{
            selectedDateTime = selectedDate +  ","  + " " + selectedTime
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, d MMM,yyyy, hh:mm a"
            let myDate = formatter.date(from: selectedDateTime)!
            let dateString = formatter.string(from: myDate as Date)
                    if let arrDictAlarmDetail = UserDefaults.standard.array(forKey: kArrDictAlarmDetail) as? [[String: Any]] {
                        arrdictAlarmData = arrDictAlarmDetail
                    }
            arrdictAlarmData[indexPathForOpr][kAlarmTime] = dateString
            if arrdictAlarmData.count >= 2{
                let sortedArray = self.arrdictAlarmData.sorted{[formatter] one, two in
                    print(one)
                    print(two)
                    return formatter.date(from:one[kAlarmTime] as! String)! > formatter.date(from: two[kAlarmTime] as! String)!
                }
                UserDefaults.standard.set(sortedArray, forKey: kArrDictAlarmDetail)
            }
            else{
                UserDefaults.standard.set(arrdictAlarmData, forKey: kArrDictAlarmDetail)
            }
            tableView.reloadData()
            hidePickerView()
        }
        
    }
    
    @IBAction func Create_Clicked(_ sender: UIButton) {
        if txtAlrmName.text == ""{
            openAlertView()
        }
        else{
            let now = Date()
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone.current
            formatter.dateFormat = "EEEE, d MMM,yyyy, hh:mm a"
            let dateString = formatter.string(from: now)
            var dictAlarmData = [String:Any]()
            dictAlarmData[kAlarmName] = txtAlrmName.text
            dictAlarmData[kAlarmTime] = dateString
            
            if let arrDictAlarmDetail = UserDefaults.standard.array(forKey: kArrDictAlarmDetail) as? [[String: Any]] {
                arrdictAlarmData = arrDictAlarmDetail
            }
            
            arrdictAlarmData.append(dictAlarmData)
            if arrdictAlarmData.count >= 2{
                let sortedArray = self.arrdictAlarmData.sorted{[formatter] one, two in
                    return formatter.date(from:one[kAlarmTime] as! String)! > formatter.date(from: two[kAlarmTime] as! String)!
                    
                }
                UserDefaults.standard.set(sortedArray, forKey: kArrDictAlarmDetail)
            }
            else{
                UserDefaults.standard.set(arrdictAlarmData, forKey: kArrDictAlarmDetail)
            }
            viewPopUpAddAlrmBackground.isHidden = true
            viewAddAlarmPopUp.isHidden = true
            tableView.reloadData()
        }
    }
    
    @IBAction func TimePicker_Clicked(_ sender: UIDatePicker) {
        selectedTime = DateFormatter.localizedString(from: sender.date, dateStyle: .none, timeStyle: .short)
        
    }
    
    //MARK: - TableView Delegate Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrdictAlarmData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tblCellAlarms") as! tblCellAlarms
        
        cell.selectionStyle = .none
        cell.btnMenu.tag = indexPath.row
        cell.btnMenu.addTarget(self, action: #selector(Swipable_Menu_Clicked), for: .touchUpInside)
        cell.delegate = self
        cell.rightButtons = [MGSwipeButton(title: "", icon: UIImage(named:"delete"), backgroundColor: .clear, padding: 30, callback: { (MGSwipeTableCell) -> Bool in
            self.indexPathForOpr = indexPath.row
            self.viewPopUpAddAlrmBackground.isHidden = false
            self.viewPopUpDelete.isHidden = false
            if let arrDictAlarmDetail = UserDefaults.standard.array(forKey: kArrDictAlarmDetail) as? [[String: Any]] {
                self.arrdictAlarmData = arrDictAlarmDetail
            }
            self.lblDeletePopDesc.text = self.arrdictAlarmData[indexPath.row][kAlarmName] as? String
            let alramName = self.arrdictAlarmData[indexPath.row][kAlarmName] as? String
            self.lblDeletePopDesc.text = "Are you sure that you want to remove the alarm \(alramName ?? "")?"
          //  self.arrdictAlarmData.remove(at: indexPath.row)
            //UserDefaults.standard.set(self.arrdictAlarmData, forKey: kArrDictAlarmDetail)
            //tableView.reloadData()
            return true
            
        }),MGSwipeButton(title: "", icon: UIImage(named: "clock"), backgroundColor: .clear, padding: 30, callback: { (MGSwipeTableCell) -> Bool in
            self.indexPathForOpr = indexPath.row
            self.ViewPicker()
            return true
        }),MGSwipeButton(title: "", icon: UIImage(named: "edit"), backgroundColor: .clear, padding: 30, callback: { (MGSwipeTableCell) -> Bool in
            let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let upDateAlarmVC = storyboard.instantiateViewController(withIdentifier: "UpDateAlarmVC") as! UpDateAlarmVC
            self.navigationController?.pushViewController(upDateAlarmVC, animated: true)
            return true
        })]
        
        cell.swipeBackgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        cell.leftSwipeSettings.transition = .drag
        
        if let alarmDetail = UserDefaults.standard.array(forKey: kArrDictAlarmDetail) as? [[String: Any]] {
            let data = alarmDetail[indexPath.row]
            cell.lblAlrmEventName.text = data[kAlarmName] as? String
            cell.lblTime.text = data[kAlarmTime] as? String
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // indexPathForOpr = indexPath.row
    }
    
    //Navigation hide Show according to  TableView scrolling
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if targetContentOffset.pointee.y < scrollView.contentOffset.y {
            // it's going up
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            // it's going down
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    //MARK: - TextField Delegate Methods
    func textFieldDidBeginEditing(_ textField: UITextField) {
        viewBotoomFortxt.TextFieldBottomViewEffect()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        btnCreate.isUserInteractionEnabled = true
        btnCreate.alpha = 1.0
    }

}
extension UIView {
    func TextFieldBottomViewEffect() {
        UIView.animate(withDuration: 0.6,animations: {
            self.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        }, completion: { _ in
            UIView.animate(withDuration: 0.6) {
                self.transform = CGAffineTransform.identity
            }
        })
    }
}
extension AlarmsVC: CalendarPopUpDelegate {
    func dateChaged(date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMM,yyyy"
        selectedDate = formatter.string(from: date as Date)
        showPickerView()
    }
}

