import UIKit
import FirebaseAuth
import FirebaseFirestore
import LocalAuthentication

class ListSaldoViewController: UIViewController {

    // Variabel untuk menyimpan saldo yang dipilih
    var selectedAmount: Int = 0
    var currentBalance: Int = UserDefaults.standard.integer(forKey: "balance")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setup atau hal-hal lain yang diperlukan
    }

    // Pilihan saldo yang akan ditambahkan
    @IBAction func seratusribu(_ sender: Any) {
        selectedAmount = 100000
    }
    
    @IBAction func limaratusribu(_ sender: Any) {
        selectedAmount = 500000
    }
    
    @IBAction func satujuta(_ sender: Any) {
        selectedAmount = 1000000
    }
    
    @IBAction func satujutalimaratus(_ sender: Any) {
        selectedAmount = 1500000
    }
    
    @IBAction func duajuta(_ sender: Any) {
        selectedAmount = 2000000
    }
    
    @IBAction func duajutalimaratus(_ sender: Any) {
        selectedAmount = 2500000
    }

    // Fungsi untuk memproses pembayaran dan pembaruan saldo
    @IBAction func paymentBalance(_ sender: Any) {
        // Cek apakah useFaceID aktif atau tidak
        let useFaceID = UserDefaults.standard.bool(forKey: "useFaceID")
        
        if useFaceID {
            // Jika Face ID aktif, langsung autentikasi menggunakan Face ID
            authenticateWithFaceID()
        } else {
            // Jika Face ID tidak aktif, minta password
            promptForPassword()
        }
    }

    // Fungsi untuk meminta password
    func promptForPassword() {
        let alert = UIAlertController(title: "Masukkan Password", message: "Untuk melanjutkan, masukkan password Anda.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Password"
        }
        alert.addAction(UIAlertAction(title: "Batal", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Konfirmasi", style: .default, handler: { [weak self] _ in
            guard let password = alert.textFields?.first?.text else { return }
            self?.verifyPassword(password)
        }))
        self.present(alert, animated: true, completion: nil)
    }

    // Fungsi untuk memverifikasi password
    func verifyPassword(_ enteredPassword: String) {
        guard let storedPassword = UserDefaults.standard.string(forKey: "userPassword") else { return }

        if enteredPassword == storedPassword {
            // Jika password benar, lanjutkan dengan pembaruan saldo
            print("masuk password")
            updateBalanceInFirestore()
        } else {
            // Jika password salah
            showErrorAlert(message: "Password yang Anda masukkan salah.")
        }
    }

    // Fungsi untuk autentikasi menggunakan Face ID
    func authenticateWithFaceID() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Gunakan Face ID untuk melanjutkan") { [weak self] success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Jika autentikasi berhasil, lanjutkan dengan pembaruan saldo
                        self?.updateBalanceInFirestore()
                    } else {
                        // Jika gagal
                        self?.showErrorAlert(message: "Autentikasi gagal. Silakan coba lagi.")
                    }
                }
            }
        } else {
            // Jika Face ID tidak tersedia
            self.showErrorAlert(message: "Face ID tidak tersedia di perangkat ini.")
        }
    }

    // Fungsi untuk memperbarui saldo di Firestore
    func updateBalanceInFirestore() {
        print("masuk")
        let newBalance = currentBalance + selectedAmount
        
        // Ambil email pengguna yang sedang login
        guard let user = Auth.auth().currentUser else {
            showErrorAlert(message: "Pengguna tidak terautentikasi.")
            return
        }

        let email = user.email ?? ""
        
        // Update saldo di Firestore berdasarkan email
        let db = Firestore.firestore()
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                self.showErrorAlert(message: "Gagal mengambil data pengguna: \(error.localizedDescription)")
                return
            }

            if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                // Update saldo pengguna di Firestore
                for document in querySnapshot.documents {
                    document.reference.updateData([
                        "balance": newBalance
                    ]) { error in
                        if let error = error {
                            self.showErrorAlert(message: "Gagal memperbarui saldo: \(error.localizedDescription)")
                        } else {
                            UserDefaults.standard.set(newBalance, forKey: "balance")
                            self.showSuccessAlert(amount: self.selectedAmount)
                        }
                    }
                }
            } else {
                self.showErrorAlert(message: "Pengguna dengan email \(email) tidak ditemukan.")
            }
        }
    }

    // Fungsi untuk menampilkan alert error
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }

    // Fungsi untuk menampilkan alert sukses
    func showSuccessAlert(amount: Int) {
        let alertController = UIAlertController(title: "Saldo Terisi", message: "Saldo Anda telah bertambah Rp\(amount).", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true)
    }
}
