//
//  ViewController.swift
//  MMS Lec
//
//  Created by prk on 22/11/24.
//

import UIKit
import LocalAuthentication

var dataCart = DataBarang()

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    // MARK: - Outlets
    @IBOutlet weak var price: UIView!
    @IBOutlet weak var totalPriceLBL: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var subTotalLBL: UILabel!
    @IBOutlet weak var taxLBL: UILabel!
    @IBOutlet weak var deliveryLBL: UILabel!
    @IBOutlet weak var paymentBTN: UIButton!
    var subTotal = 0
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchData()
        print(dataCart.listCart.count)

        tableView.dataSource = self
        tableView.delegate = self

        applyTopCornersRadius(to: price, radius: 40)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetchData()
        updateTotalPriceLabel()
        self.tabBarController?.tabBar.isHidden = true
        
        if dataCart.listCart.count == 0{
            paymentBTN.isEnabled = false
        }else{
            paymentBTN.isEnabled = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    // MARK: - Data Handling
    func fetchData() {
        // Ambil data cart berdasarkan email pengguna yang sedang aktif
        guard let email = UserDefaults.standard.string(forKey: "email") else { return }
        dataCart.fetchCartItems(email: email)

        // Reload table view untuk menampilkan data terbaru
        tableView.reloadData()
    }

    func calculateTotalPrice() -> Int {
        var totalPrice = 0
        for cartItem in dataCart.listCart {
            totalPrice += Int(cartItem.harga) * cartItem.quantity
        }
        return totalPrice
    }

    func updateTotalPriceLabel() {
        let totalPrice = calculateTotalPrice()
        totalPriceLBL.text = "Rp\(totalPrice)"
        
        var tax = 0
        var delivery = 0
        
        if dataCart.listCart.count >= 1{
            tax = 2000000
            delivery = 1000000
        }
        
        subTotal = totalPrice + delivery + tax
        
        taxLBL.text = "Rp\(tax)"
        deliveryLBL.text = "Rp\(delivery)"
        subTotalLBL.text = "Rp\(subTotal)"
    }

    // MARK: - TableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataCart.listCart.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cartList", for: indexPath) as? cartListTableViewCell else {
            return UITableViewCell() // Ensure we have a valid cell
        }

        // Ambil item cart
        let cartItem = dataCart.listCart[indexPath.row]

        // Setel nilai untuk elemen-elemen UI di cell
        cell.quantity.text = "\(cartItem.quantity)"
        cell.namaProdukLBL.text = cartItem.namaproduk
        cell.gambar.image = cartItem.image
        cell.hargaLBL.text = "Rp\(cartItem.harga)"

        // Setel nilai awal stepper
        cell.stepper.value = Double(cartItem.quantity)
        cell.stepper.minimumValue = 1  // Minimum value stepper
        cell.stepper.maximumValue = 100 // Maximum value stepper

        // Pass referensi tableView dan indexPath ke cell
        cell.tableView = tableView
        cell.indexPath = indexPath

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }

    // MARK: - Swipe Action (Delete)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completionHandler in
            guard let self = self else { return }

            // Ambil item yang akan dihapus
            let itemToDelete = dataCart.listCart[indexPath.row]

            // Hapus item dari Core Data
            if let email = UserDefaults.standard.string(forKey: "email") {
                dataCart.deleteCartItemByProductName(productName: itemToDelete.namaproduk, email: email)
            }
            
            fetchData()

            tableView.reloadData()
            // Update total harga
            self.updateTotalPriceLabel()

            // Selesaikan aksi swipe
            completionHandler(true)
        }

        deleteAction.backgroundColor = .red
        let swipeActions = UISwipeActionsConfiguration(actions: [deleteAction])
        swipeActions.performsFirstActionWithFullSwipe = true

        return swipeActions
    }

    // MARK: - Actions
    @IBAction func back(_ sender: Any) {
        print("Back button clicked")
        self.tabBarController?.selectedIndex = 0
    }
    
    @IBAction func payment(_ sender: Any) {
        // Sebelum membuka PaymentViewController, kirimkan data yang dibutuhkan
//        let popUpVC = self.storyboard?.instantiateViewController(withIdentifier: "pamentViewController") as! pamentViewController
//
//        // Kirim data ke pamentViewController
//        popUpVC.total = subTotal
//        popUpVC.tax = 2000000  // Contoh tax yang sudah didefinisikan
//        popUpVC.deliveryPrice = 1000000  // Contoh delivery fee
//
//        // Set ukuran preferensi untuk pop-up
//        popUpVC.preferredContentSize = CGSize(width: self.view.frame.width, height: 400)
//
//        // Menampilkan pamentViewController sebagai pop-up
//        popUpVC.modalPresentationStyle = .overCurrentContext  // Efek pop-up
//        popUpVC.modalTransitionStyle = .crossDissolve        // Efek transisi
//
//        present(popUpVC, animated: true, completion: nil)
        
        performSegue(withIdentifier: "gotopayment", sender: self)
        fetchData()
        tableView.reloadData()
    }

    
    // MARK: - Helper Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotopayment"{
            if let destination = segue.destination as? pamentViewController{
                destination.total = subTotal
            }
        }
    }

    func applyTopCornersRadius(to view: UIView, radius: CGFloat) {
        // Membuat path untuk sudut atas kiri dan kanan
        let path = UIBezierPath(roundedRect: view.bounds,
                                byRoundingCorners: [.topLeft, .topRight],  // Menentukan sudut atas kiri dan kanan
                                cornerRadii: CGSize(width: radius, height: radius))

        // Membuat shape layer untuk mask
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }
}
