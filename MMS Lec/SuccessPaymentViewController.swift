//
//  SuccessPaymentViewController.swift
//  MMS Lec
//
//  Created by prk on 23/11/24.
//

import UIKit
import FirebaseFirestore

class SuccessPaymentViewController: UIViewController {
    
    var subtotal = 0
    var shippingCost = 3000000
    
    @IBOutlet weak var subtotalLBL: UILabel!
    @IBOutlet weak var shippingCostLBL: UILabel!
    @IBOutlet weak var feeLBL: UILabel!
    @IBOutlet weak var cardLBL: UILabel!
    @IBOutlet weak var totalLBL: UILabel!
    @IBOutlet weak var pricingView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyCustomCorners(to: pricingView, corners: [.bottomLeft,.bottomRight,.topRight,.topLeft], radius: 25)
        
        // Do any additional setup after loading the view.
    }
    
    func applyCustomCorners(to view: UIView, corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: view.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        view.layer.mask = maskLayer
    }
    @IBAction func back(_ sender: Any) {
        updateBalanceAfterPayment()
        
    }
    func updateBalanceAfterPayment() {
            // Ambil email dari UserDefaults
            guard let email = UserDefaults.standard.string(forKey: "email") else {
                print("Email not found!")
                return
            }

            let db = Firestore.firestore()

            // Ambil dokumen pengguna berdasarkan email
            db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting user data: \(error.localizedDescription)")
                    return
                }
                
                if let documents = querySnapshot?.documents, !documents.isEmpty {
                    // Ambil saldo yang ada dan kurangi dengan subtotal
                    for document in documents {
                        if var currentBalance = document.get("balance") as? Int {
                            // Kurangi saldo dengan total pembayaran
                            let newBalance = currentBalance - self.subtotal - self.shippingCost

                            // Update saldo di Firestore
                            db.collection("users").document(document.documentID).updateData([
                                "balance": newBalance
                            ]) { error in
                                if let error = error {
                                    print("Error updating balance: \(error.localizedDescription)")
                                } else {
                                    print("Balance successfully updated!")
                                    
                                    // Setelah update saldo, kembali ke halaman Home
                                    self.navigateToHome()
                                }
                            }
                        }
                    }
                } else {
                    print("No user found with the email \(email)")
                }
            }
        }

        func navigateToHome() {
            // Menavigasi kembali ke halaman Home setelah transaksi berhasil
            if let tabBarController = self.tabBarController {
                tabBarController.selectedIndex = 0 // Pindah ke halaman Home
            }
        }
}
