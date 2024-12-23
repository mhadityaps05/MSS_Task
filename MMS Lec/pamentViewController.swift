//
//  pamentViewController.swift
//  MMS Lec
//
//  Created by fits on 21/12/24.
//

import UIKit
import LocalAuthentication
import FirebaseAuth
import FirebaseFirestore

class pamentViewController: UIViewController, UISheetPresentationControllerDelegate {
    
    var total = 0
    var tax = 2000000
    var deliveryPrice = 1000000
    
    var allTotalPrice = 0
    
    var data = DataBarang()

    @IBOutlet weak var balance: UIButton!
    @IBOutlet weak var masterCard: UIButton!
    @IBOutlet weak var paypall: UIButton!
    @IBOutlet weak var totalPrice: UILabel!
    @IBOutlet weak var taxPrice: UILabel!
    @IBOutlet weak var delivery: UILabel!
    @IBOutlet weak var subTotalLbl: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        balance.isSelected = true
        
        totalPrice.text = "Rp\(total)"
        taxPrice.text = "Rp\(tax)"
        delivery.text = "Rp\(deliveryPrice)"
        subTotalLbl.text = "Rp\(total + tax + deliveryPrice)"
        
        allTotalPrice = total + tax + deliveryPrice
        
        sheetPresentationController.delegate = self
        sheetPresentationController.selectedDetentIdentifier = .medium
        sheetPresentationController.prefersGrabberVisible = true
        sheetPresentationController.detents = [
            .medium()
        ]

        // Do any additional setup after loading the view.
    }
    
    override var sheetPresentationController: UISheetPresentationController {
        presentationController as! UISheetPresentationController
    }
    
    @IBAction func processPayment(_ sender: Any) {
            // Ambil saldo pengguna dari UserDefaults
            let currentBalance = UserDefaults.standard.integer(forKey: "balance")
        let totalAmount = total + tax + deliveryPrice
            
            // Periksa apakah saldo cukup
            if currentBalance < totalAmount {
                // Jika saldo tidak cukup, beri pemberitahuan
                showInsufficientBalanceAlert()
            } else {
                // Jika saldo cukup, lanjutkan dengan autentikasi
                if UserDefaults.standard.bool(forKey: "useFaceID") {
                    // Cek apakah perangkat mendukung Face ID/Touch ID
                    authenticateWithFaceID()
                } else {
                    // Jika Face ID tidak diaktifkan, langsung meminta password
                    promptForPassword()
                }
            }
        }
    
    func showInsufficientBalanceAlert() {
            let alert = UIAlertController(title: "Saldo Tidak Cukup", message: "Saldo Anda tidak mencukupi untuk melanjutkan pembayaran. Silakan tambahkan saldo terlebih dahulu.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }

    
    func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        // Cek apakah Face ID tersedia
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Mencoba autentikasi menggunakan Face ID/Touch ID
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Gunakan Face ID untuk melanjutkan pembayaran.") { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        // Jika Face ID berhasil, lanjutkan ke pembayaran
                        self!.data.deleteAllCartItemsByEmail(email: UserDefaults.standard.string(forKey: "email")!)
                        self?.updateBalanceInFirestore(email: UserDefaults.standard.string(forKey: "email")!, newBalance: self!.allTotalPrice)
                        self!.performSegue(withIdentifier: "successPayment", sender: self)
                    } else {
                        // Jika Face ID gagal, tampilkan error dan minta password
                        self?.showFaceIDError()
                        self?.promptForPassword()
                    }
                }
            }
        } else {
            // Jika Face ID tidak tersedia
            showFaceIDError()
            promptForPassword()
        }
    }
    
    func showErrorAlert(message: String) {
           let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
           alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
           self.present(alertController, animated: true)
       }
    
    func updateBalanceInFirestore(email: String, newBalance: Int) {
            let db = Firestore.firestore()

            // Cari pengguna berdasarkan email
            db.collection("users").whereField("email", isEqualTo: email).getDocuments { [weak self] querySnapshot, error in
                if let error = error {
                    self?.showErrorAlert(message: "Gagal mengambil data pengguna: \(error.localizedDescription)")
                    return
                }

                if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                    for document in querySnapshot.documents {
                        // Update saldo pengguna di Firestore
                        document.reference.updateData([
                            "balance": newBalance
                        ]) { error in
                            if let error = error {
                                self?.showErrorAlert(message: "Gagal memperbarui saldo: \(error.localizedDescription)")
                            } else {
                                // Berhasil mengurangi saldo di Firestore
//                                self?.showSuccessAlert(amount: self?.total ?? 0)
                            }
                        }
                    }
                } else {
                    self?.showErrorAlert(message: "Pengguna dengan email \(email) tidak ditemukan.")
                }
            }
        }

    
    func promptForPassword() {
        // Membuat alert untuk memasukkan password
        let alert = UIAlertController(title: "Masukkan Password", message: "Untuk melanjutkan ke pembayaran, masukkan password Anda.", preferredStyle: .alert)

        // Menambahkan TextField untuk input password
        alert.addTextField { textField in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }

        // Aksi Cancel
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        // Aksi Submit
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            guard let self = self else { return }
            if let password = alert.textFields?.first?.text, !password.isEmpty {
                // Verifikasi password dari UserDefaults
                if let savedPassword = UserDefaults.standard.string(forKey: "userPassword") {
                    if password == savedPassword {
                        // Hapus semua item keranjang berdasarkan email
                        if let email = UserDefaults.standard.string(forKey: "email") {
                            dataCart.deleteAllCartItemsByEmail(email: email)
                        }
                        // Password benar, lanjutkan ke pembayaran
                        performSegue(withIdentifier: "successPayment", sender: self)
                    } else {
                        // Password salah, beri peringatan
                        self.showPasswordError()
                    }
                }
            }
        }
        alert.addAction(submitAction)

        // Tampilkan alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func showFaceIDError() {
        let alert = UIAlertController(title: "Kesalahan Face ID", message: "Face ID gagal. Silakan coba lagi atau masukkan password Anda.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    func handleSuccessfulPayment() {
            let alert = UIAlertController(title: "Pembayaran Berhasil", message: "Pembayaran Anda telah berhasil dilakukan.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }

        func showPasswordError() {
            let alert = UIAlertController(title: "Kesalahan", message: "Password yang Anda masukkan salah. Silakan coba lagi.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true, completion: nil)
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "successPayment"{
            if let destination = segue.destination as? SuccessPaymentViewController{
                destination.subtotal = total
            }
        }
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
