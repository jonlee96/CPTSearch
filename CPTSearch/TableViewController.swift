//
//  TableViewController.swift
//  CPTSearch
//
//  Created by Truc Tran  on 10/3/19.
//  Copyright © 2019 Cleveland Clinic. All rights reserved.
//

import UIKit


// MARK: - global variables

var CPTCodeData = [String]() // stores all CPT codes
var shortData = [String]() // stores all CPT short descriptions
var longData = [String]() // stores all CPT long descriptions
var CPTDictionary = [String: [String]]() // stores key->value(s) pairs

var orderIndex = 0 // tracks index location of each order
var indexTrackerforLongdescription = 0 // tracks index location of CPT long description
var indexTrackerforCPTCode = 0 // tracks index location of CPT code
var dictionaryIndex = 0 //keeps track of index location of orderList
var alphabeticalBoolean = true

var DataGrabber = 0
var deleteCounter = CPTCodeData.count


// map CPTDictionary to easily obtain each component
var orderList = CPTDictionary.map {(CPTCode: $0.key,
                                    Short: $0.value.first ?? "",
                                    Long:  $0.value.dropFirst().first ?? "")}

//sort short description alphabetically in descending order
var sortedDictionary = orderList.sorted(by: { $0.Short < $1.Short })

//filter options - MRI/MR and CT
var filterOrder = sortedDictionary

// counter for each filter option
var filterCount = 0


// filter booleans
var MRIFilterBoolean = false
var CTFilterBoolean = false
var headBoolean = false
var legBoolean = false
var armBoolean = false
var handBoolean = false
var feetBoolean = false
var chestBoolean = false



//  For Search Screen, Lindsey:
var pressedSearchButton = false
var proceduresList = [String]()
var c = [String]()
var s = [String]()
var l = [String]()
// MARK: - UITableViewCell

// customized row in UITableView: includes 2 labels
class HeadlineTableViewCell: UITableViewCell {
    
    @IBOutlet var CPTCodeLabel: UILabel!
    @IBOutlet var CPTShortDescriptionLabel: UILabel!
    
}

// MARK: - UITableViewController
class TableViewController: UITableViewController {
    
    @IBOutlet var catalogTableview: UITableView!
    
    @IBOutlet var resultLabel: UILabel!
    @IBOutlet var filterView: UIView!
    @IBOutlet var sortButton: UIButton!
    
    //sort catalog short description alphabetically
     @IBAction func sortButton(_ sender: Any) {
        procedureBoolean(MRI: false, CT: false)
        alphabeticalBoolean = !alphabeticalBoolean
        displayResults(NumberOfRows: deleteCounter)
     }
    func armFilter(){
        hideView()
        filterData(keyword: "UPPER")
        filterCount = filterOrder.count
        displayResults(NumberOfRows: filterCount)
    }

    func chestFilter(){
           hideView()
           filterData(keyword: "CHEST")
           filterCount = filterOrder.count
           displayResults(NumberOfRows: filterCount)
       }
    func legFilter(){
        hideView()
        filterData(keyword: "PELVIS")
        filterCount = filterOrder.count
        displayResults(NumberOfRows: filterCount)
    }

    func feetFilter(){
        hideView()
        filterData(keyword: "LOWER")
        filterCount = filterOrder.count
        displayResults(NumberOfRows: filterCount)
    }

    func handFilter(){
        hideView()
        filterData(keyword: "HAND")
        filterCount = filterOrder.count
        displayResults(NumberOfRows: filterCount)
    }

    func headFilter(){
        hideView()
        filterData(keyword: "HEAD")
        filterCount = filterOrder.count
        displayResults(NumberOfRows: filterCount)
    }
    
    //filter by MR and MRI
    @IBAction func MRButton(_ sender: Any) {
        hideView()
        procedureBoolean(MRI: true, CT: false)
        filterData(keyword: "MR")
        filterCount = filterOrder.count
        displayResults(NumberOfRows: filterCount)
    }
    
    //filter by CT
    @IBAction func CTButton(_ sender: Any) {
        hideView()
        procedureBoolean(MRI: false, CT: true)
        filterData(keyword: "CT ")
        filterCount = filterOrder.count
        displayResults(NumberOfRows: filterCount)
    }
    
    //display all results
    @IBAction func allResultsButton(_ sender: Any) {
        filterView.isHidden = true
        sortButton.isHidden = false
        alphabeticalBoolean = true
        procedureBoolean(MRI: false, CT: false)
        displayResults(NumberOfRows: deleteCounter)
    }
    
    //hide the filter options (MR/MRI, CT, and ALL)
    @IBAction func filterButton(_ sender: Any) {
        filterView.isHidden = !filterView.isHidden
    }
    
    //hide filter options and sort button
    func hideView() {
        filterView.isHidden = true
        sortButton.isHidden = true
    }
    
    //depending on the selected filter, booleans will change accordingly
    func procedureBoolean(MRI: Bool, CT: Bool) {
        MRIFilterBoolean = MRI
        CTFilterBoolean = CT
    }
    
    //display the number of results found
    func displayResults(NumberOfRows: Int) {
        catalogTableview.reloadData()
        resultLabel.text = "\(NumberOfRows) results"
    }
    
    //filter data by a particular keyword, case insensitive
    func filterData(keyword: String) {
         filterOrder = sortedDictionary.filter {($0.Short.range(of: keyword, options: .caseInsensitive)) != nil}
    }
    
    
    
    
    //loads content of catalog page
    override func viewDidLoad() {
        super.viewDidLoad()
        //  The line below is needed for the Search screen -Lindsey
        pressedSearchButton = false
        // cuztomize row height of table
        catalogTableview.rowHeight = 80.0
        if(DataGrabber == 0) {
        loadData()
        }
        resultLabel.text = "\(deleteCounter) results"
        catalogTableview.reloadData()
        
        let data = UserDefaults.standard.object(forKey: "bodyPart") // may not be "bodyPart", whatever
        //       you named it
        if let typeOfBodyPart = data as? String
        {
               if (typeOfBodyPart == "head")
               {
                //      call the method that only gets the head data
                headBoolean = true
                headFilter()
               }
               else if (typeOfBodyPart == "arm")
               {
                //       call a method that only gets the arm data
                armBoolean = true
                armFilter()
               }
            else if (typeOfBodyPart == "leg")
            {
                //       call a method that only gets the leg data
                legBoolean = true
                legFilter()
            }
            else if (typeOfBodyPart == "feet")
            {
                //       call a method that only gets the leg data
                feetBoolean = true
                feetFilter()
            }
            else if (typeOfBodyPart == "hand")
            {
                //       call a method that only gets the hand data
                handBoolean = true
                handFilter()
            }
            else if (typeOfBodyPart == "chest")
            {
                //       call a method that only gets the hand data
                chestBoolean = true
                chestFilter()
            }
        }
    }
    //pulls data from plist and store them in arrays
    func loadData() {
        //print("Added the stuff")
        CPTCodeData.removeAll()
        shortData.removeAll()
        longData.removeAll()
        indexTrackerforLongdescription = 0
        indexTrackerforCPTCode = 0
        dictionaryIndex = 0
        
        
        
        // obtains Orders.plist
        let url = Bundle.main.url(forResource:"Orders", withExtension: "plist")!
        
        // extract plist info into arrays
        do {
            let data = try Data(contentsOf: url)
            let sections = try PropertyListSerialization.propertyList(from: data, format: nil) as! [[Any]]
            
            // loop through each subarray of plist
            // _ defines unnamed parameter, did not need to keep track of index of each subarray
            for (_, section) in sections.enumerated() {
                // obtains all components(CPTCode, short description, and long description of a subarray
                for item in section {
                    indexTrackerforLongdescription+=1
                    // adds all CPT longDescription to longData
                    if(indexTrackerforLongdescription%3==0){
                        longData.append(item as! String)
                    }
                    else {
                        // adds all CPTCodes to CPTCodeData
                        if(indexTrackerforCPTCode%2==0) {
                            CPTCodeData.append(item as! String)
                        }
                        else { // add all CPT shortDescription to shortData
                            shortData.append(item as! String)
                        }
                        indexTrackerforCPTCode+=1
                    }
                }
                // create dictionary: CPTCodeData (key) --> shortData, longData (values)
                CPTDictionary[CPTCodeData[dictionaryIndex]] = [shortData[dictionaryIndex], longData[dictionaryIndex]]
                dictionaryIndex+=1
            }
        } catch {
            print("Error grabbing data from properly list: ", error)
        }
       
        //grabs data from plist once
        DataGrabber+=1
    }
    
// MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
   
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(MRIFilterBoolean == true || CTFilterBoolean == true || headBoolean == true || armBoolean == true || legBoolean == true || feetBoolean == true || feetBoolean == true || handBoolean == true || chestBoolean == true) {
            return filterCount
        }
        else {
        return CPTCodeData.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //use cell format of customized UITableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "LabelCell", for: indexPath) as! HeadlineTableViewCell

        if(headBoolean == true){
            print("head boolean working")
            cell.CPTCodeLabel.text = "CPT Code: \(filterOrder[indexPath.row].CPTCode)"
            cell.CPTShortDescriptionLabel.text = filterOrder[indexPath.row].Short
            return cell
        }
        if(armBoolean == true){
            cell.CPTCodeLabel.text = "CPT Code: \(filterOrder[indexPath.row].CPTCode)"
            cell.CPTShortDescriptionLabel.text = filterOrder[indexPath.row].Short
            return cell
        }
        if(legBoolean == true){
            cell.CPTCodeLabel.text = "CPT Code: \(filterOrder[indexPath.row].CPTCode)"
            cell.CPTShortDescriptionLabel.text = filterOrder[indexPath.row].Short
            return cell
        }
        if(handBoolean == true){
            cell.CPTCodeLabel.text = "CPT Code: \(filterOrder[indexPath.row].CPTCode)"
            cell.CPTShortDescriptionLabel.text = filterOrder[indexPath.row].Short
            return cell
        }
        if(feetBoolean == true){
            cell.CPTCodeLabel.text = "CPT Code: \(filterOrder[indexPath.row].CPTCode)"
            cell.CPTShortDescriptionLabel.text = filterOrder[indexPath.row].Short
            return cell
        }
        if(chestBoolean == true){
            cell.CPTCodeLabel.text = "CPT Code: \(filterOrder[indexPath.row].CPTCode)"
            cell.CPTShortDescriptionLabel.text = filterOrder[indexPath.row].Short
            return cell
        }
        // Configure the cell...
        if (MRIFilterBoolean == true && CTFilterBoolean == false || CTFilterBoolean == true && MRIFilterBoolean == false && headBoolean == false) {
            cell.CPTCodeLabel.text = "CPT Code: \(filterOrder[indexPath.row].CPTCode)"
            cell.CPTShortDescriptionLabel.text = filterOrder[indexPath.row].Short
            return cell
        }
       
        //catalog page displays CPT Code in ascending order
       if alphabeticalBoolean && MRIFilterBoolean == false && headBoolean == false {
            cell.CPTCodeLabel.text = "CPT Code: \(CPTCodeData[indexPath.row])"
            cell.CPTShortDescriptionLabel.text = shortData[indexPath.row]
            return cell
        }
            // once sort button is clicked, catalog page displays CPT short description
            // alphabetically
        else  {
            cell.CPTCodeLabel.text = "CPT Code: \(sortedDictionary[indexPath.row].CPTCode)"
            cell.CPTShortDescriptionLabel.text = sortedDictionary[indexPath.row].Short
            return cell
        }
       
    }
    
    @IBAction func unwindToViewControllerA(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.resultLabel.text = "\(deleteCounter) results"
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        pressedSearchButton = false
        orderIndex = indexPath.row
        print(orderIndex)
        performSegue(withIdentifier: "segue", sender: self)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {
            
            
            CPTCodeData.remove(at: indexPath.row)
            shortData.remove(at: indexPath.row)
            longData.remove(at: indexPath.row)
            catalogTableview.deleteRows(at: [indexPath], with: UITableView.RowAnimation.automatic)
            
                       
            deleteCounter -= 1
            displayResults(NumberOfRows: deleteCounter)
        }
    }
}
