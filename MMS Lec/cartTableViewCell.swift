//
//  cartTableViewCell.swift
//  MMS Lec
//
//  Created by prk on 22/11/24.
//

import UIKit

class cartTableViewCell: UITableViewCell {

    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var imageUI: UIImageView!
    @IBOutlet weak var namaUI: UILabel!
    @IBOutlet weak var hargaUI: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stepper.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        quantity.text = "\(Int(stepper.value))"
        stepper.addTarget(self, action: #selector(stepperValueChanged), for: .valueChanged)
        // Initialization code
    }
    
    @objc func stepperValueChanged() {
        quantity.text = "\(Int(stepper.value))"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
