import UIKit
import FirebaseAuth
import FirebaseFirestore

class ViewController23: UIViewController {
    
    @IBOutlet weak var emailLBL: UITextField!
    @IBOutlet weak var passwordLBL: UITextField!
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Cek status login saat tampilan muncul
        checkLoginStatus()
    }
    
    func checkLoginStatus() {
        // Cek apakah isLogin di UserDefaults bernilai true
        let isLoggedIn = UserDefaults.standard.bool(forKey: "isLogin")
        
        print("User isLogin status: \(isLoggedIn)")  // Debugging
        
        if isLoggedIn {
            // Jika sudah login, langsung lakukan segue ke Home
            performSegue(withIdentifier: "gotohome", sender: self)
        }
    }
    
    @IBAction func loginBTN(_ sender: Any) {
        // 1. Validasi Input Pengguna
        guard let email = emailLBL.text, !email.isEmpty else {
            showErrorAlert(message: "Email is required.")
            return
        }
        
        guard let password = passwordLBL.text, !password.isEmpty else {
            showErrorAlert(message: "Password is required.")
            return
        }
        
        // 2. Lakukan Login Menggunakan Firebase Authentication
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            if let error = error {
                // Menampilkan pesan error jika login gagal
                self.showErrorAlert(message: error.localizedDescription)
                return
            }
            
            // 3. Simpan Email dan Password ke UserDefaults
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(password, forKey: "userPassword")
            UserDefaults.standard.set(true, forKey: "isLogin")
            
            // 4. Cari username dan phone number di Firestore berdasarkan email yang login
            self.getUserDataFromFirestore(email: email) { (username, phoneNumber, error) in
                if let error = error {
                    self.showErrorAlert(message: error.localizedDescription)
                    return
                }
                
                // Menyimpan data pengguna ke UserDefaults (jika ditemukan)
                if let username = username, let phoneNumber = phoneNumber {
                    UserDefaults.standard.set(username, forKey: "username")
                    UserDefaults.standard.set(phoneNumber, forKey: "tlp")
                }
                
                // 5. Jika login berhasil, pindah ke tampilan Home
                self.performSegue(withIdentifier: "gotohome", sender: self)
            }
        }
    }
    
    // Fungsi untuk mencari data pengguna di Firestore berdasarkan email
    func getUserDataFromFirestore(email: String, completion: @escaping (String?, String?, Error?) -> Void) {
        let db = Firestore.firestore()
        
        // Mencari pengguna berdasarkan email di Firestore
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
            if let error = error {
                completion(nil, nil, error)
                return
            }
            
            guard let documents = querySnapshot?.documents, !documents.isEmpty else {
                completion(nil, nil, NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"]))
                return
            }
            
            // Ambil data dari dokumen pertama (anggap hanya ada satu dokumen untuk satu email)
            let document = documents[0]
            let username = document.get("username") as? String
            let phoneNumber = document.get("phoneNumber") as? String
            
            completion(username, phoneNumber, nil)
        }
    }
    
    // Fungsi untuk menampilkan alert error
    func showErrorAlert(message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true)
    }
}
