//
//  ViewController.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/6/21.
//

import UIKit

class RecordingListVC: UIViewController {
    var tappedCell2: Recording!
    let tableview = UITableView()
    
    var coreDataStack = CoreDataStack()
    // to be able to use uitable header content must be in 2d array
    var categories = [[RecordingCategory]]()
    var allRecordings = [Recording]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        categories = []
        
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
        
        tableview.reloadData()

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "Recordings"
        self.view.addSubview(tableview)
        tableview.frame = view.bounds
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(TableViewCell.self, forCellReuseIdentifier: "tableviewcellid")
        tableview.register(CategoryHeader.self, forHeaderFooterViewReuseIdentifier: CategoryHeader.indentifier)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))

        self.navigationItem.rightBarButtonItem = addButton

    }

    @objc func addButtonTapped() {
        let newRecordingVC = NewRecording()
        self.navigationController?.pushViewController(newRecordingVC, animated: true)
    }
}


extension RecordingListVC: UITableViewDelegate, UITableViewDataSource {
    
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

extension RecordingListVC: CollectionViewCellDelegate {
    func collectionView(collectionviewcell: RecordingCollectionViewCell?, index: Int, didTappedInTableViewCell: TableViewCell) {

        if let recordingRow = didTappedInTableViewCell.recordings {
            self.tappedCell2 = recordingRow[index]
            // prints the recording
            print(recordingRow[index])

        }
    }
}

