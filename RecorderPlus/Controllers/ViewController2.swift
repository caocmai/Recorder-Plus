//
//  ViewController2.swift
//  RecorderPlus
//
//  Created by Cao Mai on 1/6/21.
//

import UIKit
import AVFoundation

class ViewController2: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let test = ["a", "b", "c", "d"]
    let table = UITableView()
    
    let simpleConfig = UICollectionView.CellRegistration<RecordingCollectionViewCell, String> { (cell, indexPath, model) in
//      cell.label.text = model

    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .white
        self.title = "HomeView2"
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 60, height: 60)
        
        let myCollectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)

        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
//        myCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CVcell")
        myCollectionView.backgroundColor = .white
        self.view.addSubview(myCollectionView)
                
        if let flowLayout = myCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        

    }
    
    func setupTable(){
        view.addSubview(table)
        table.delegate = self
        table.dataSource = self
        table.separatorStyle = .none
        table.frame = view.bounds
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return test.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = test[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }


}


extension ViewController2 {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 19
    }
    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CVcell", for: indexPath)
//        myCell.backgroundColor = UIColor.blue
//        return myCell
//    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           print("User tapped on item \(indexPath.row)")
        }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let model = "Cell \(indexPath.row)"

      return collectionView.dequeueConfiguredReusableCell(using: simpleConfig,
                                                          for: indexPath,
                                                          item: model)
    }
}



