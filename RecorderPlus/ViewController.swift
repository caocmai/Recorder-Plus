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
    let tableview = UITableView()
    
    var coreDataStack = CoreDataStack()


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
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))

        self.navigationItem.rightBarButtonItem = addButton
        

//        let newRecording = Recording(context: coreDataStack.managedContext)
//        newRecording.name = "Another on for song"
//        newRecording.date = Date()
//        newRecording.recordingID = UUID()
//        newRecording.category = "A New Song"
//        coreDataStack.saveContext()
        
        coreDataStack.fetchAllProjects { (results) in
            switch results {
            case .failure(let error):
                print(error)
                print("error")
            case .success(let recordings):
                var data = [DisplayRecordings].self
                for r in recordings {
                    print("success")
                    print(r.date)
                    print(r.note)
                    print(r.name)
                    print(r.category)
                }
            }
        }
        


    }
    

    
    @objc func addButtonTapped() {
        
        let newRecordingVC = NewRecording()
//        let navController = UINavigationController(rootViewController: newRecordingVC)
        self.navigationController?.pushViewController(newRecordingVC, animated: true)
    }
}


extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return colorsArray.objectsArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colorsArray.objectsArray[section].subcategory.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    // Category Title
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.colorFromHex("#BC224B")
        let titleLabel = UILabel(frame: CGRect(x: 8, y: 0, width: 200, height: 44))
        headerView.addSubview(titleLabel)
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        titleLabel.text = colorsArray.objectsArray[section].category
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcellid", for: indexPath) as? TableViewCell {
            // Show SubCategory Title
            let subCategoryTitle = colorsArray.objectsArray[indexPath.section].subcategory
            cell.subCategoryLabel.text = subCategoryTitle[indexPath.row]

            // Pass the data to colletionview inside the tableviewcell
            let rowArray = colorsArray.objectsArray[indexPath.section].colors[indexPath.row]
            cell.updateCellWith(row: rowArray)

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
        if let colorsRow = didTappedInTableViewCell.rowWithColors {
            self.tappedCell = colorsRow[index]
            print(colorsRow[index])

        }
    }
}


struct DisplayRecordings {
    let category: String
    let recordings: [Recording]
}
