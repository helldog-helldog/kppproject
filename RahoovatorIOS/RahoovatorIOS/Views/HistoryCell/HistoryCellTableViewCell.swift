//
//  HistoryCellTableViewCell.swift
//  RahoovatorIOS
//
//  Created by Юра Калинчук on 5/18/17.
//  Copyright © 2017 Helldog. All rights reserved.
//

import UIKit

class HistoryCellTableViewCell: UITableViewCell {

    @IBOutlet weak var inputVal: UILabel!
    @IBOutlet weak var inputPrice: UILabel!
    @IBOutlet weak var outputVal: UILabel!
    @IBOutlet weak var outputPrice: UILabel!
    @IBOutlet weak var pricePerUnit: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
