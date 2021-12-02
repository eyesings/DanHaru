//
//  TodoListDetailViewController+tableView.swift
//  DanHaruProject
//
//  Created by RADCNS_DESIGN on 2021/11/09.
//

import Foundation
import UIKit

extension TodoListDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weeklyCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoListDetailTableViewCell", for: indexPath) as! TodoListDetailTableViewCell
        
        cell.selectionStyle = .none
        
        cell.backView.layer.borderColor = UIColor.lightGray.cgColor
        cell.backView.layer.borderWidth = 1
        cell.backView.layer.shadowColor = UIColor.black.cgColor
        cell.backView.layer.shadowOpacity = 0.7
        cell.backView.layer.shadowOffset = CGSize(width: 2, height: 2)
        cell.backView.layer.shadowRadius = 5
        cell.backView.backgroundColor = .white
        
        
        if indexPath.row >= todoListCellBackGroundColor.count {
            
            cell.weeklyBar.tintColor = todoListCellBackGroundColor[indexPath.row - todoListCellBackGroundColor.count * (indexPath.row / todoListCellBackGroundColor.count)]
            
            
        } else {
            
            cell.weeklyBar.tintColor =  todoListCellBackGroundColor[indexPath.row]
            
        }
        
        cell.weeklyBar.setProgress(0.8, animated: true)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableCellHeight
    }
}
