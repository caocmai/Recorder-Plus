//
//  ViewController.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/6/21.
//

import UIKit

class RecordingListVC: UIViewController {
    let tableview = UITableView()
    let coreDataStack = CoreDataStack()
    // to be able to use uitable header content must be in 2d array
    var categories = [[RecordingCategory]]()
    var tappedCell: Recording!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAndSet()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableAndUI()
    }
    
    private func setUpTableAndUI() {
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Recordings"
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        self.navigationItem.rightBarButtonItem = addButton
        
        let quickRec = UIBarButtonItem(title: "QuickREC", style: .plain, target: self, action: #selector(quickRecTapped))
        self.navigationItem.leftBarButtonItem = quickRec
        
        self.view.addSubview(tableview)
        tableview.frame = view.bounds
        tableview.dataSource = self
        tableview.delegate = self
        tableview.register(TableViewCell.self, forCellReuseIdentifier: "tableviewcellid")
        tableview.register(CategoryHeader.self, forHeaderFooterViewReuseIdentifier: CategoryHeader.indentifier)

    }
    
    private func fetchAndSet() {
        categories = []
        
        coreDataStack.fetchAllRecordingCategories { (r) in
            switch r {
            case .failure(let error):
                print(error)
            case .success(let cate):
                for c in cate {
                    self.categories.append([c])
                }
            //                print(self.categories)
            }
        }
        
        tableview.reloadData()
    }
    
    @objc func quickRecTapped() {
        let newRecordingVC = NewRecording()
        newRecordingVC.quickRec = true
        newRecordingVC.coreDataStack = coreDataStack
        self.navigationController?.pushViewController(newRecordingVC, animated: true)
    }
    
    @objc func addButtonTapped() {
        let newRecordingVC = NewRecording()
        newRecordingVC.coreDataStack = coreDataStack
        self.navigationController?.pushViewController(newRecordingVC, animated: true)
    }
}

// - MARK: UITableView

extension RecordingListVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return categories.count
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    // Recording Topic header
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableview.dequeueReusableHeaderFooterView(withIdentifier: CategoryHeader.indentifier) as! CategoryHeader
        headerView.title.text = categories[section][0].category
        headerView.newRecordingcompletion = {
            let newRecordingVC = NewRecording()
            newRecordingVC.selectedCategory = self.categories[section][0]
            newRecordingVC.coreDataStack = self.coreDataStack
            self.navigationController?.pushViewController(newRecordingVC, animated: true)
        }
        
        headerView.deleteCompletion = {
            let refreshAlert = UIAlertController(title: "Delete Topic Recordings", message: "WARNING: This will delete ALL recordings for this topic", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (action: UIAlertAction!) in
                // reset unknown topic
                let unknownTopicId = UserDefaults.standard.string(forKey: "unknownTopicId")
                if let validUnknownTopicId = unknownTopicId {
                    if self.categories[section][0].categoryID! == UUID(uuidString: validUnknownTopicId) {
                        UserDefaults.standard.set(nil, forKey: "unknownTopicId")
                    }
                }
                
                let quickRecId = UserDefaults.standard.string(forKey: "quickRecTopicId")
                if let validQuickRecId = quickRecId {
                    if self.categories[section][0].categoryID! == UUID(uuidString: validQuickRecId) {
                        UserDefaults.standard.set(nil, forKey: "quickRecTopicId")
                    }
                }
                
                self.coreDataStack.deleteRecordingsByCategoryId(parentCategory: self.categories[section][0])
                self.coreDataStack.deleteCategoryByID(identifier: self.categories[section][0].categoryID!)
                
                self.categories.remove(at: section)
                self.tableview.deleteSections([section], with: .fade)
                self.fetchAndSet()
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                print("User cancels delete")
            }))
            
            self.present(refreshAlert, animated: true, completion: nil)
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "tableviewcellid", for: indexPath) as? TableViewCell {
            
            let model = categories[indexPath.section][indexPath.row]
            let sortby = "date"
            coreDataStack.fetchRecordingsByCategory(sortBy: sortby, selectedCategory: model) { (r) in
                switch r {
                case .failure(let error):
                    print(error)
                case .success(let r):
                    cell.updateCellNew(row: r)
                }
            }
            // set cell's delegate
            cell.cellDelegate = self
            
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }

}

// - MARK: CollectionViewCellDelegate

extension RecordingListVC: CollectionViewCellDelegate {
    
    func collectionView(collectionviewcell: RecordingCollectionViewCell?, index: Int, didTappedInTableViewCell: TableViewCell) {
        
        if let recordingRow = didTappedInTableViewCell.recordings {
            let editVC = NewRecording()
            editVC.coreDataStack = coreDataStack
            editVC.editRecording = recordingRow[index]
            self.navigationController?.pushViewController(editVC, animated: true)
            self.tappedCell = recordingRow[index]
            // prints the recording
            //            print(recordingRow[index])
            
        }
    }
}

