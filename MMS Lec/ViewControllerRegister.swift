import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewControllerRegister: UIViewController {

    @IBOutlet weak var usernameLBL: UITextField!
    @IBOutlet weak var emailLBL: UITextField!
    @IBOutlet weak var passworLBL: UITextField!
    @IBOutlet weak var confirmPasswordLBL: UITextField!
    @IBOutlet weak var tlpLBL: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Membuat gesture recognizer untuk tap di luar keyboard
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
            
            // Menambahkan gesture recognizer ke view
            self.view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        // Menutup keyboard dengan resignFirstResponder
        self.view.endEditing(true)
    }
    
    @IBAction func createAccount(_ sender: Any) {
        // Ambil data input pengguna
        guard let username = usernameLBL.text, !username.isEmpty else {
            showErrorAlert(message: "Username is required.")
            return
        }
        
        guard let email = emailLBL.text, !email.isEmpty else {
            showErrorAlert(message: "Email is required.")
            return
        }
        
        guard let password = passworLBL.text, !password.isEmpty else {
            showErrorAlert(message: "Password is required.")
            return
        }
        
        guard let confirmPassword = confirmPasswordLBL.text, !confirmPassword.isEmpty else {
            showErrorAlert(message: "Please confirm your password.")
            return
        }
        
        guard let phoneNumber = tlpLBL.text, !phoneNumber.isEmpty else {
            showErrorAlert(message: "Phone number is required.")
            return
        }
        
        // Validasi password dan konfirmasi password
        guard password == confirmPassword else {
            showErrorAlert(message: "Passwords do not match.")
            return
        }
        
        // Validasi format email
        if !isValidEmail(email) {
            showErrorAlert(message: "Invalid email format.")
            return
        }
        
        // Daftarkan pengguna ke Firebase Authentication
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                self.showErrorAlert(message: error.localizedDescription)
                return
            }
            
            // Setelah berhasil mendaftar, simpan data ke Firestore
            self.saveUserDataToFirestore(username: username, email: email, phoneNumber: phoneNumber)
        }
    }
    
    func saveUserDataToFirestore(username: String, email: String, phoneNumber: String) {
        guard let user = Auth.auth().currentUser else {
            showErrorAlert(message: "User is not authenticated.")
            return
        }
        
        // Dapatkan reference ke Firestore
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.uid)
        
        // Simpan data ke Firestore
        userRef.setData([
            "username": username,
            "email": email,
            "phoneNumber": phoneNumber,
            "uid": user.uid,
            "balance": 0
        ]) { error in
            if let error = error {
                self.showErrorAlert(message: "Failed to save user data: \(error.localizedDescription)")
            } else {
                // Berhasil menyimpan data, navigasi ke tampilan lain
                self.navigateToHomeScreen()
            }
        }
    }
    
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
    
    func navigateToHomeScreen() {
        // Simpan data ke UserDefaults setelah pendaftaran berhasil
        UserDefaults.standard.set(true, forKey: "isLogin")
        UserDefaults.standard.set(passworLBL.text, forKey: "userPassword")
        UserDefaults.standard.set(emailLBL.text, forKey: "email")
        UserDefaults.standard.set(tlpLBL.text, forKey: "tlp")
        UserDefaults.standard.set(usernameLBL.text, forKey: "username")
        
        // Misalnya, setelah pendaftaran berhasil, Anda ingin pindah ke tampilan Home
        performSegue(withIdentifier: "gotohome", sender: self)
    }
    
    // Fungsi untuk validasi format email
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: email)
    }
}
