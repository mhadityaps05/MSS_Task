//
//  detailViewController.swift
//  MMS Lec
//
//  Created by fits on 17/12/24.
//

import UIKit

class detailViewController: UIViewController {
    
    var produk : String = ""
    var brand : String = ""
    var data = DataBarang()

    @IBOutlet weak var gambarProduk: UIImageView!
    @IBOutlet weak var namaProduk: UILabel!
    @IBOutlet weak var detailProduk: UILabel!
    @IBOutlet weak var harga: UIButton!
    @IBOutlet weak var caraKerjaLBL: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(produk)
        print(brand)
        data.fetchDetail(namaProduk: produk, brand: brand)
        
        print(data.detail.count)
        
        namaProduk.text = data.detail[0].nama
        detailProduk.text = data.detail[0].detail
        harga.setTitle("Rp \(data.detail[0].harga)", for: .normal)
        caraKerjaLBL.text = data.detail[0].carakerja
        gambarProduk.image = data.detail[0].image

        // Do any additional setup after loading the view.
    }
    @IBAction func buyBTN(_ sender: Any) {
        data.addItemToCart(namaproduk: produk, quantity: 1, email: UserDefaults.standard.string(forKey: "email")!, from: self)
    }
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
