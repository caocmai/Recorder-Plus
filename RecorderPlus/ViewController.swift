//
//  ViewController.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/6/21.
//

import UIKit

class ViewController: UIViewController {
    var colorsArray = Colors()
    var tappedCell: CollectionViewCellModel!
    var tappedCell2: Recording!
    let tableview = UITableView()
    
    var coreDataStack = CoreDataStack()
    // to be able to use uitable header content must be in 2d array
    var categories = [[RecordingCategory]]()
    var allRecordings = [Recording]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableview.reloadData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "HomeView"
        self.view.addSubview(tableview)
        tableview.frame = view.bounds
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(TableViewCell.self, forCellReuseIdentifier: "tableviewcellid")
        tableview.register(CategoryHeader.self, forHeaderFooterViewReuseIdentifier: CategoryHeader.indentifier)
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))

        self.navigationItem.rightBarButtonItem = addButton
        
//
//        let newRecording = RecordingCategory(context: coreDataStack.managedContext)
//        newRecording.category = "A second song"
//        newRecording.categoryID = UUID()
        
        
//        newRecording.name = "Another on for song"
//        newRecording.date = Date()
//        newRecording.recordingID = UUID()
//        newRecording.category = "A New Song"

//        coreDataStack.saveContext()
        
        let id1 = "7730BFA5-5079-4865-81B4-C32446ED6F40"
        let id2 = "2A87972A-1EFE-47DF-84F8-490A8CF35836"

        var uuid = UUID(uuidString: id1)!

        
//
//        coreDataStack.fetchRecordingCategoryByID(identifier: uuid) { (results) in
//            switch results {
//            case .failure(let error):
//                print(error)
//                print("error")
//            case .success(let recordings):
//
//                let new = Recording(context: self.coreDataStack.managedContext)
//                new.date = Date()
//                new.recordingID = UUID()
//                new.recordingParent = recordings.first
//                new.name = "Second Recording"
//                new.note = "a note of recording"
//                self.coreDataStack.saveContext()
//
////                var data = [DisplayRecordings].self
////                for r in recordings {
////                    print("success")
//////                    print(r.date)
//////                    print(r.note)
//////                    print(r.name)
////                    print(r.category)
////                    print(r.categoryID)
////                }
//            }
//        }
        
        
        coreDataStack.fetchAllRecordingCategories { (r) in
            switch r {
            case .failure(let error):
                print(error)
            case .success(let cate):
                for c in cate {
                    self.categories.append([c])
                }
            }
        }
        
        coreDataStack.fetchAllRecordings { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let recordings):
                self.allRecordings = recordings
//                for r in recordings {
//                    print(r.name)
//                    print(r.recordingParent?.category)
//                }
            }
        }
        
//        coreDataStack.fetchAllRecordingCategories { (r) in
//            switch r {
//            case .failure(let error):
//                print(error)
//            case .success(let categories):
//                for c in categories {
//                    print(c.category)
//                }
//            }
//        }
        
//        let newcate = RecordingCategory(context: coreDataStack.managedContext)
//        newcate.category = "Homie"
//        newcate.categoryID = UUID()
//        coreDataStack.saveContext()
//
//        coreDataStack.fetchRecordingCategoryByTitle(identifier: "Homie") { (r) in
//            switch r {
//                case .failure(let error):
//                    print(error)
//                case .success(let categories):
//                    let new = Recording(context: self.coreDataStack.managedContext)
//                        new.date = Date()
//                        new.recordingID = UUID()
//                        new.recordingParent = categories.first
//                        new.name = "The ultimate test of this"
//                        new.note = "if this passes then it's over"
//                        self.coreDataStack.saveContext()
//                }
//        }


    }
    

    
    @objc func addButtonTapped() {
        
        let newRecordingVC = NewRecording()
//        let navController = UINavigationController(rootViewController: newRecordingVC)
        self.navigationController?.pushViewController(newRecordingVC, animated: true)
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
//        return colorsArray.objectsArray.count
        return categories.count

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return colorsArray.objectsArray[section].subcategory.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    // Category Title
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = UIColor.colorFromHex("#BC224B")
//        let titleLabel = UILabel(frame: CGRect(x: 8, y: 0, width: 200, height: 44))
//        headerView.addSubview(titleLabel)
//        titleLabel.textColor = UIColor.white
//        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
////        titleLabel.text = colorsArray.objectsArray[section].category
//        titleLabel.text = categories[section][0].category
//
        let headerView = tableview.dequeueReusableHeaderFooterView(withIdentifier: CategoryHeader.indentifier) as! CategoryHeader
        headerView.title.text = categories[section][0].category
        headerView.completion = {
            let newRecordingVC = NewRecording()
            newRecordingVC.selectedCategory = self.categories[section][0].category
            self.navigationController?.pushViewController(newRecordingVC, animated: true)
        }
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcellid", for: indexPath) as? TableViewCell {
            // Show SubCategory Title
//            let subCategoryTitle = colorsArray.objectsArray[indexPath.section].subcategory
//            cell.subCategoryLabel.text = subCategoryTitle[indexPath.row]

            // Pass the data to colletionview inside the tableviewcell
//            let rowArray = colorsArray.objectsArray[indexPath.section].colors[indexPath.row]
//            cell.updateCellWith(row: rowArray)
            
            let model = categories[indexPath.section][indexPath.row]
//            print(model.category)
            
            let sortby = "date"
            coreDataStack.fetchRecordingsByCategory(sortBy: sortby, selectedCategory: model) { (r) in
                switch r {
                case .failure(let error):
                    print(error)
                case .success(let r):
                    cell.updateCellNew(row: r)

                }
            }
            // Set cell's delegate
            cell.cellDelegate = self
            
            cell.selectionStyle = .none
            return cell
       }
        return UITableViewCell()
    }
    
    
}

extension ViewController: CollectionViewCellDelegate {
    func collectionView(collectionviewcell: CollectionViewCell?, index: Int, didTappedInTableViewCell: TableViewCell) {
        
//        if let colorsRow = didTappedInTableViewCell.rowWithColors {
//            self.tappedCell = colorsRow[index]
//            // just prints the color within the index
//            print(colorsRow[index])
//
//        }
        
        if let recordingRow = didTappedInTableViewCell.recordings {
            self.tappedCell2 = recordingRow[index]
            // prints the recording
            print(recordingRow[index])

        }
    }
}


struct DisplayRecordings {
    let category: String
    let recordings: [Recording]
}

