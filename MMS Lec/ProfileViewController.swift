import UIKit
import LocalAuthentication

// Definisikan struktur generalmenu
struct generalmenu {
    var title: String
    var subtitle: String
    var img: UIImage
}


class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // List data untuk tabel, pastikan untuk mengambil gambar dari Asset Catalog
    var listgeneralmenu = [
        generalmenu(title: "My Account", subtitle: "Please setup your account", img: UIImage(named: "gg_profile")!),
        generalmenu(title: "Language", subtitle: "Change your language", img: UIImage(named: "tabler_language")!),
        generalmenu(title: "Face ID/Biometric", subtitle: "Manage your device security", img: UIImage(named: "material-symbols_lock-outline")!),
        generalmenu(title: "Two-Factor Authentication", subtitle: "Secure your account for safety", img: UIImage(named: "material-symbols_shield-outline")!),
        generalmenu(title: "Logout", subtitle: "Logout from your account", img: UIImage(named: "mdi_logout")!)
    ]
    
    
    @IBOutlet weak var Location: UILabel!
    @IBOutlet weak var generalsetting: UITableView!
    
    
    // Menentukan jumlah baris dalam tabel
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listgeneralmenu.count
    }
    
    // Menampilkan data di dalam setiap cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Menggunakan style .subtitle untuk mendukung title dan subtitle
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        // Ambil data untuk cell saat ini
        let menu = listgeneralmenu[indexPath.row]
        
        // Mengonfigurasi label dan image view dalam cell
        cell.textLabel?.text = menu.title      // Menampilkan title
        cell.detailTextLabel?.text = menu.subtitle  // Menampilkan subtitle
        if let imageView = cell.imageView {
                imageView.image = menu.img        // Menampilkan gambar
                imageView.contentMode = .scaleAspectFit // Mengatur mode tampilan gambar agar proporsional
                
                // Pastikan layout sudah selesai sebelum mengatur cornerRadius
                cell.layoutIfNeeded()  // Memaksa layout dihitung ulang
                
                // Membuat gambar menjadi bulat dengan sudut melengkung
                imageView.layer.cornerRadius = imageView.frame.size.width / 2
                imageView.layer.masksToBounds = true
            }
        
        return cell
    }

    // Optional: Menentukan tinggi cell agar subtitle terlihat dengan baik
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
        // Atur sesuai kebutuhan untuk memberi ruang bagi subtitle
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("klik")
        let selectedRow = listgeneralmenu[indexPath.row].title
        
        if selectedRow == "My Account"{
            performSegue(withIdentifier: "profileDetail", sender: self)
        }else if selectedRow == "Face ID/Biometric"{
            handleFaceIDSetting()
        }
        else if selectedRow == "Logout"{
            UserDefaults.standard.set(false, forKey: "isLogin")
            navigateToLoginScreen()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // Fungsi untuk berpindah ke ViewController23 (login screen)
        func navigateToLoginScreen() {
            // 1. Jika Anda menggunakan segue, gunakan performSegue:
            // performSegue(withIdentifier: "showLoginScreen", sender: self)
            
            // 2. Jika Anda ingin present ViewController23 secara langsung:
            if let loginVC = storyboard?.instantiateViewController(withIdentifier: "ViewController23") {
                // Jika ingin present full screen
                loginVC.modalPresentationStyle = .fullScreen
                present(loginVC, animated: true, completion: nil)
            }
        }
    
    func handleFaceIDSetting() {
        // Cek status Face ID di UserDefaults
        let isFaceIDEnabled = UserDefaults.standard.bool(forKey: "useFaceID")
        
        if isFaceIDEnabled {
            // Jika Face ID sudah aktif, tampilkan opsi untuk menonaktifkan
            showFaceIDDisableAlert()
        } else {
            // Jika Face ID belum aktif, tampilkan opsi untuk mengaktifkan
            showFaceIDEnableAlert()
        }
    }
    
    func showFaceIDEnableAlert() {
        let alert = UIAlertController(title: "Aktifkan Face ID/Biometric", message: "Untuk mengaktifkan Face ID, masukkan password Anda.", preferredStyle: .alert)
        
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
                        // Password benar, coba Face ID
                        self.authenticateWithFaceID(enable: true)
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
    
    func showFaceIDDisableAlert() {
        let alert = UIAlertController(title: "Nonaktifkan Face ID/Biometric", message: "Untuk menonaktifkan Face ID, masukkan password Anda.", preferredStyle: .alert)
        
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
                        // Password benar, coba Face ID
                        self.authenticateWithFaceID(enable: false)
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
    
    func authenticateWithFaceID(enable: Bool) {
        let context = LAContext()
        var error: NSError?
        
        // Cek apakah Face ID tersedia
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // Mencoba autentikasi menggunakan Face ID/Touch ID
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Gunakan Face ID untuk melanjutkan.") { [weak self] success, error in
                DispatchQueue.main.async {
                    if success {
                        // Jika Face ID berhasil, lanjutkan ke pengaturan
                        self?.updateFaceIDSetting(enable: enable)
                    } else {
                        // Jika Face ID gagal, beri peringatan
                        self?.showFaceIDError()
                    }
                }
            }
        } else {
            // Jika Face ID tidak tersedia, beri peringatan
            showFaceIDError()
        }
    }
    
    func updateFaceIDSetting(enable: Bool) {
        // Mengubah status Face ID di UserDefaults
        UserDefaults.standard.set(enable, forKey: "useFaceID")
        
        let message = enable ? "Face ID berhasil diaktifkan." : "Face ID berhasil dinonaktifkan."
        
        // Tampilkan pesan sukses
        let alert = UIAlertController(title: "Sukses", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    func showFaceIDError() {
        let alert = UIAlertController(title: "Kesalahan Face ID", message: "Face ID gagal. Silakan coba lagi atau masukkan password Anda.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    func showPasswordError() {
        let alert = UIAlertController(title: "Kesalahan Password", message: "Password yang Anda masukkan salah. Silakan coba lagi.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true, completion: nil)
    }
    
    @IBOutlet weak var fotoprofil: UIImageView!
    @IBOutlet weak var moresetting: UIView!
    @IBOutlet weak var bekgronlabel: UILabel!
    func applyGradientToTableView() {
            // Membuat CAGradientLayer
            let gradientLayer = CAGradientLayer()
            
            // Menentukan warna gradasi dengan kode hex
            gradientLayer.colors = [
                UIColor(hex: "#9A9CF2").cgColor,  // Warna pertama: #9A9CF2
                UIColor(hex: "#383BEF").cgColor   // Warna kedua: #383BEF
            ]
            
            // Menentukan posisi warna gradasi
            gradientLayer.locations = [0.0, 1.0]
            
            // Menentukan arah gradasi: Diagonal dari kiri atas ke kanan bawah
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            
            // Menyesuaikan ukuran gradasi dengan ukuran view
            gradientLayer.frame = generalsetting.bounds
            
            // Menambahkan gradientLayer ke layer dari UITableView
            generalsetting.layer.insertSublayer(gradientLayer, at: 0)
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.isNavigationBarHidden = true
        
        Location.text = UserDefaults.standard.string(forKey: "location")
        
        // Set data source dan delegate untuk tabel
        generalsetting.dataSource = self
        generalsetting.delegate = self
        
        generalsetting.layer.cornerRadius = 20  // Mengatur radius sudut
        generalsetting.layer.masksToBounds = true
        
        

        
        
        // Do any additional setup after loading the view.
    }
}

extension UIColor {
    // Fungsi untuk membuat UIColor dari kode hex string
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
}
