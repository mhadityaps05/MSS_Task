import UIKit
import CoreLocation
import FirebaseAuth
import FirebaseFirestore

class HomeViewController: UIViewController, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    let geocoder = CLGeocoder()

    var baranglist = DataBarang()
    var selectedProduk: String = ""  // Menyimpan nama produk yang dipilih
    var selectedBrand: String = ""   // Menyimpan brand produk yang dipilih

    // MARK: - IBOutlet
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var collectionProduct: UICollectionView!
    @IBOutlet weak var balanceTopUp: UIImageView!
    @IBOutlet weak var usernameLBL: UILabel!
    @IBOutlet weak var balanceLBL: UILabel!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update username di UI
        usernameLBL.text = "\(UserDefaults.standard.string(forKey: "username")!)"
        
        // Setup lokasi
        setupLocationManager()
        
        // Fetch Barang data
        baranglist.fetchBarangData()
        collectionProduct.dataSource = self
        collectionProduct.delegate = self
        
        // Set layout collection view
        if let flowLayout = collectionProduct.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            // Pastikan balance selalu diperbarui setiap kali halaman ini muncul
            fetchBalanceFromFirestore()
        }

    // MARK: - Collection View Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        baranglist.listBarang.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! listCollectionViewCell
        cell.nama.text = baranglist.listBarang[indexPath.row].nama
        cell.harga.text = "Rp\(baranglist.listBarang[indexPath.row].harga)"
        cell.gambar.image = baranglist.listBarang[indexPath.row].gambar
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedItem = baranglist.listBarang[indexPath.row]
        selectedProduk = selectedItem.nama
        selectedBrand = selectedItem.brand
        performSegue(withIdentifier: "gotodetail", sender: nil)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = 128  // Lebar cell
        let height: CGFloat = 220 // Tinggi cell
        return CGSize(width: width, height: height)
    }

    // MARK: - Location Manager Setup
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        geocoder.reverseGeocodeLocation(currentLocation) { placemarks, error in
            if let error = error {
                print("Failed to reverse geocode: \(error.localizedDescription)")
                self.location.text = "Location not available"
                return
            }
            if let placemark = placemarks?.first {
                let city = placemark.locality ?? "Unknown City"
                let country = placemark.country ?? "Unknown Country"
                self.location.text = "\(city)"
                UserDefaults.standard.set(city, forKey: "location")
            }
        }
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
        location.text = "Failed to get location"
    }

    // MARK: - Fetch Balance from Firestore (based on Email)
        func fetchBalanceFromFirestore() {
            guard let user = Auth.auth().currentUser else {
                print("User is not logged in.")
                return
            }

            let email = UserDefaults.standard.string(forKey: "email")!

            let db = Firestore.firestore()
            
            // Mengambil data dari koleksi "users" berdasarkan email
            db.collection("users").whereField("email", isEqualTo: email).getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error.localizedDescription)")
                    return
                }

                if let querySnapshot = querySnapshot, !querySnapshot.isEmpty {
                    // Jika ada hasil, ambil balance
                    for document in querySnapshot.documents {
                        if let balance = document.get("balance") as? Int {
                            print("User balance: \(balance)")
                            
                            // Update UI dengan balance yang didapat
                            self.balanceLBL.text = "Saldo: Rp\(balance)"
                            UserDefaults.standard.set(balance, forKey: "balance")
                        }
                    }
                } else {
                    print("No document found for user with email: \(email)")
                }
            }
        }

    // MARK: - Prepare for Segue
    @IBAction func topUpBalance(_ sender: Any) {
        performSegue(withIdentifier: "balanceTopUp", sender: self)
    }
       override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "gotodetail" {
               if let destination = segue.destination as? detailViewController {
                       destination.brand = selectedBrand
                       destination.produk = selectedProduk
               }
           }
       }
}

