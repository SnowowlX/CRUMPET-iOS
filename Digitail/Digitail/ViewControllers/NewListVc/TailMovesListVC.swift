//
//  TailMovesListVC.swift
//  CRUMPET
//
//  Created by Bhavik Patel on 28/01/21.
//  Copyright © 2021 Iottive. All rights reserved.
//

import UIKit

protocol MoveListDelegate: class {
    func fetchSavedData(strMoveName : String)
}

let kName = "Name"
let kSliderValue = "SliderValue"
let kSelectedData = "SelectedData"
let kMsgAlarmNameAlreadyExixts = "Please choose another movelist name"

class TailMovesListVC: UIViewController,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collVw_SequenceList: UICollectionView!
    @IBOutlet weak var lblDurationValue: UILabel!
    @IBOutlet weak var slider_Duration: UISlider!
    @IBOutlet weak var tf_MoveListName: UITextField!
    @IBOutlet weak var tblVw_TailMovesListVc: UITableView!
    
    weak var delegate : MoveListDelegate?
    var isFromEdit : Bool = false
    var savedMoveListName : String = ""
    var checkedIndexes = [String]()
    let arrHomePosition = [NSLocalizedString("kSlowwag1", comment: ""),NSLocalizedString("kSlowwag2", comment: ""),NSLocalizedString("kSlowwag3", comment: ""),NSLocalizedString("kFastWag", comment: ""),NSLocalizedString("kShortWag", comment: ""),NSLocalizedString("kHappyWag", comment: ""),NSLocalizedString("kErect", comment: ""),NSLocalizedString("kErectPulse", comment: ""),NSLocalizedString("kTremble1", comment: ""),NSLocalizedString("kTremble2", comment: ""),NSLocalizedString("kErectTrem", comment: "")]
    //    ["Slow wag 1","Slow wag 2","Slow wag 3","Fast wag","Short wag","Happy wag","Stand up!","Tremble 1","Tremble 2","Tremble Erect","High Wag"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMainUIAndView()
    }
    
    //MARK:- CUSTOM METHODS -
    func setUpMainUIAndView() {
        self.title = NSLocalizedString("kCreateMoveList", comment: "")
        
        if isFromEdit == true {
            if let pravSavedData = UserDefaults.standard.value(forKey: "\(savedMoveListName) MoveList") as? [String : AnyObject] {
                print(pravSavedData)
                tf_MoveListName.text = pravSavedData["Name"] as? String
                let sliderValue = pravSavedData["SliderValue"]
                lblDurationValue.text = "\((sliderValue as! NSString).integerValue) seconds"
                slider_Duration.value = (sliderValue as! NSString).floatValue
                checkedIndexes = pravSavedData["SelectedData"] as! [String]
                self.tblVw_TailMovesListVc.reloadData()
                self.collVw_SequenceList.reloadData()
            }
        } else {
            lblDurationValue.text = "20 seconds"
            slider_Duration.value = 20.0
        }
    }
    
    func saveCreatedList() {
        if checkedIndexes.count > 0 {
            if tf_MoveListName.text == "" {
                openAlertView(alertMsg: kMsgAlarmName)
            } else {
                var dictData =  [String : AnyObject]()
                dictData[kName] = tf_MoveListName.text! as AnyObject
                dictData[kSliderValue] = "\(slider_Duration.value)" as AnyObject
                dictData[kSelectedData] = checkedIndexes as AnyObject
                print(dictData)
                UserDefaults.standard.setValue(dictData, forKey: "\(tf_MoveListName.text!) MoveList")
                if isFromEdit == false {
                    self.delegate?.fetchSavedData(strMoveName: tf_MoveListName.text!)
                }
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            print("Please select any one from list")
        }
    }
    
    func openAlertView(alertMsg : String) {
        let alert = UIAlertController(title: kError, message: alertMsg, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: kAlertActionOK, style: .default, handler:{ (UIAlertAction) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK:- TEXT FIELD METHODS -
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - TableView Delegate Methods -
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let calmAndRelaxedCell = tableView.dequeueReusableCell(withIdentifier: "TblVw_TailMovesListCalmAndRelaxedCell") as! TblVw_TailMovesListCalmAndRelaxedCell
            
            addShadow(sender: calmAndRelaxedCell.btnSlowWag1)
            addShadow(sender: calmAndRelaxedCell.btnSlowWag2)
            addShadow(sender: calmAndRelaxedCell.btnSlowWag3)
            calmAndRelaxedCell.btnSlowWag1.setTitle(self.arrHomePosition[calmAndRelaxedCell.btnSlowWag1.tag], for: .normal)
            calmAndRelaxedCell.btnSlowWag2.setTitle(self.arrHomePosition[calmAndRelaxedCell.btnSlowWag2.tag], for: .normal)
            calmAndRelaxedCell.btnSlowWag3.setTitle(self.arrHomePosition[calmAndRelaxedCell.btnSlowWag3.tag], for: .normal)
            calmAndRelaxedCell.btnSlowWag1.addTarget(self, action: #selector(tailMoves_Clicked(sender:)), for: .touchUpInside)
            calmAndRelaxedCell.btnSlowWag2.addTarget(self, action: #selector(tailMoves_Clicked(sender:)), for: .touchUpInside)
            calmAndRelaxedCell.btnSlowWag3.addTarget(self, action: #selector(tailMoves_Clicked(sender:)), for: .touchUpInside)

            return calmAndRelaxedCell
        } else if indexPath.section == 1 {
            let fastAndRelaxedCell = tableView.dequeueReusableCell(withIdentifier: "TblVw_FastAndExited_Cell") as! TblVw_FastAndExited_Cell
            addShadow(sender: fastAndRelaxedCell.btnFastTag)
            addShadow(sender: fastAndRelaxedCell.btnShortWag)
            addShadow(sender: fastAndRelaxedCell.btnHappyWag)
            addShadow(sender: fastAndRelaxedCell.btnStandup)
            fastAndRelaxedCell.btnFastTag.setTitle(self.arrHomePosition[            fastAndRelaxedCell.btnFastTag.tag], for: .normal)
            fastAndRelaxedCell.btnShortWag.setTitle(self.arrHomePosition[            fastAndRelaxedCell.btnShortWag.tag], for: .normal)
            fastAndRelaxedCell.btnHappyWag.setTitle(self.arrHomePosition[            fastAndRelaxedCell.btnHappyWag.tag], for: .normal)
            fastAndRelaxedCell.btnStandup.setTitle(self.arrHomePosition[            fastAndRelaxedCell.btnStandup.tag], for: .normal)
            fastAndRelaxedCell.btnFastTag.addTarget(self, action: #selector(tailMoves_Clicked(sender:)), for: .touchUpInside)
            fastAndRelaxedCell.btnShortWag.addTarget(self, action: #selector(tailMoves_Clicked(sender:)), for: .touchUpInside)
            fastAndRelaxedCell.btnHappyWag.addTarget(self, action: #selector(tailMoves_Clicked(sender:)), for: .touchUpInside)
            fastAndRelaxedCell.btnStandup.addTarget(self, action: #selector(tailMoves_Clicked(sender:)), for: .touchUpInside)

            return fastAndRelaxedCell
        } else {
            let FrustretedAndTenseCell = tableView.dequeueReusableCell(withIdentifier: "TblVw_FrustretedAndTense_Cell") as! TblVw_FrustretedAndTense_Cell
            addShadow(sender: FrustretedAndTenseCell.btnTremble1)
            addShadow(sender: FrustretedAndTenseCell.btnTremble2)
            addShadow(sender: FrustretedAndTenseCell.btnTremblErect)
            addShadow(sender: FrustretedAndTenseCell.btnHighWag)
            FrustretedAndTenseCell.btnTremble1.setTitle(self.arrHomePosition[            FrustretedAndTenseCell.btnTremble1.tag], for: .normal)
            FrustretedAndTenseCell.btnTremble2.setTitle(self.arrHomePosition[            FrustretedAndTenseCell.btnTremble2.tag], for: .normal)
            FrustretedAndTenseCell.btnTremblErect.setTitle(self.arrHomePosition[            FrustretedAndTenseCell.btnTremblErect.tag], for: .normal)
            FrustretedAndTenseCell.btnHighWag.setTitle(self.arrHomePosition[            FrustretedAndTenseCell.btnHighWag.tag], for: .normal)
            
            FrustretedAndTenseCell.btnTremble1.addTarget(self, action: #selector(tailMoves_Clicked(sender:)), for: .touchUpInside)
            FrustretedAndTenseCell.btnTremble2.addTarget(self, action: #selector(tailMoves_Clicked(sender:)), for: .touchUpInside)
            FrustretedAndTenseCell.btnTremblErect.addTarget(self, action: #selector(tailMoves_Clicked(sender:)), for: .touchUpInside)
            FrustretedAndTenseCell.btnHighWag.addTarget(self, action: #selector(tailMoves_Clicked(sender:)), for: .touchUpInside)

            return FrustretedAndTenseCell
        }
       
    }
    
    //MARK: - Collection View  Delegate Methods -
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return checkedIndexes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollVw_MoveListSequence_Cell" ,for: indexPath) as! CollVw_MoveListSequence_Cell
        cell.vwDurationBg.layer.cornerRadius = cell.vwDurationBg.frame.height/2
        cell.lblMovesName.text = checkedIndexes[indexPath.row]
        let sliderValue = Int(slider_Duration.value)
        cell.lblDuration.text = "\(sliderValue)s"
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(deleteMoves_Clicked(sender:)), for: .touchUpInside)

        if indexPath.row == 0 {
            cell.LayConstsVwBgWidth.constant = 0
            cell.vwDurationBg.isHidden = true
        } else {
            cell.LayConstsVwBgWidth.constant = 48
            cell.vwDurationBg.isHidden = false
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func moveCollectionToFrame(contentOffset : CGFloat) {
        let frame: CGRect = CGRect(x : contentOffset ,y : self.collVw_SequenceList.contentOffset.y ,width : self.collVw_SequenceList.frame.width,height : self.collVw_SequenceList.frame.height)
        self.collVw_SequenceList.scrollRectToVisible(frame, animated: true)
    }
    
    //MARK:- SLIDER DELEGATE METHOD -
    @IBAction func slider_Duration_Value(_ sender: UISlider) {
        let sliderValue = Int(sender.value)
        lblDurationValue.text = "\(sliderValue) seconds"
        collVw_SequenceList.reloadData()
    }
    
    //MARK:- BUTTON EVENTS -
    @IBAction func Save_Clicked(_ sender: UIButton) {
        tf_MoveListName.resignFirstResponder()
        saveCreatedList()
    }
    
    @objc
    func tailMoves_Clicked(sender: UIButton) {
        checkedIndexes.append(arrHomePosition[sender.tag])
        let collectionBounds = self.collVw_SequenceList.bounds
        let contentOffset = CGFloat(floor(self.collVw_SequenceList.contentOffset.x + collectionBounds.size.width))
        self.moveCollectionToFrame(contentOffset: contentOffset)
        collVw_SequenceList.reloadData()
    }
    
    @objc
    func deleteMoves_Clicked(sender: UIButton) {
        let newArray = checkedIndexes.filter { $0 != checkedIndexes[sender.tag] }
        checkedIndexes = newArray
        collVw_SequenceList.reloadData()
    }
}


func isKeyPresentInUserDefaults(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
}
