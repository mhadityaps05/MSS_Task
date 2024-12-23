import CoreData
import UIKit

class DataBarang {
    
    struct BarangItem {
        var gambar: UIImage
        var nama: String
        var harga: Double
        var brand: String
    }
    
    struct detailBarang{
        var nama: String
        var detail: String
        var harga: Double
        var carakerja: String
        var image: UIImage
    }
    
    struct cartItem{
        var email : String
        var namaproduk : String
        var quantity : Int
        var image : UIImage
        var harga : Double
    }

    // Array untuk menyimpan data barang
    var listBarang = [BarangItem]()
    
    var detail = [detailBarang]()
    
    var listCart = [cartItem]()
    
    // Context untuk berinteraksi dengan Core Data
    var context: NSManagedObjectContext!
    
    // Menginisialisasi context dari luar
    init() {
        // Ambil context dari AppDelegate
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            context = appDelegate.persistentContainer.viewContext
        }
        
        // Cek apakah context berhasil diinisialisasi
        if context == nil {
            print("Context is nil!")
            // Jika context nil, Anda bisa memberikan penanganan tambahan jika diperlukan.
        }
    }
    
    // Fungsi untuk mengambil data dari Core Data
    func fetchBarangData() {
        // Memastikan context tidak nil
        guard let context = context else {
            print("Context is nil!")
            return
        }

        // Membuat fetch request untuk mengambil data dari entity Barang
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Barang")
        
        var fetchedBarang: [BarangItem] = []

        do {
            // Mengambil data dari Core Data
            let barangList = try context.fetch(fetchRequest)

            // Konversi data menjadi array Barang
            for item in barangList {
                if let nama = item.value(forKey: "namaproduk") as? String,
                   let harga = item.value(forKey: "harga") as? Double,
                   let imageData = item.value(forKey: "gambar") as? Data,
                   let brand = item.value(forKey: "brand") as? String,
                   let gambar = UIImage(data: imageData) {
                    let newBarang = BarangItem(gambar: gambar, nama: nama, harga: harga, brand: brand)
                    fetchedBarang.append(newBarang)
                }
            }

            // Menyimpan hasil ke listBarang
            listBarang = fetchedBarang

        } catch let error as NSError {
            print("Failed to fetch data: \(error), \(error.userInfo)")
        }
    }
    
    func addBarangMedisIfNeeded() {
            guard let context = context else {
                print("Context is nil!")
                return
            }
            
            // Cek apakah sudah ada data barang medis dalam Core Data
            let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Barang")
            do {
                let barangList = try context.fetch(fetchRequest)
                
                // Jika data kosong, tambah data default
                if barangList.isEmpty {
                    addBarangMedis()  // Menambahkan data barang medis default
                } else {
                    print("Data sudah ada")
                }
            } catch {
                print("Failed to fetch data: \(error)")
            }
        }
    
    // Fungsi untuk menambahkan data barang medis ke Core Data
    func addBarangMedis() {
        // Memastikan context tidak nil
        guard let context = context else {
            print("Context is nil!")
            return
        }
        
        // Ambil entity Barang dari Core Data
        guard let barangEntity = NSEntityDescription.entity(forEntityName: "Barang", in: context) else {
            print("Failed to fetch entity description")
            return
        }

        let barangData: [(namaproduk: String, brand: String, carakerja: String, detail: String, harga: Double, gambar: String)] = [
            ("MRI Machine", "GE Healthcare", "Menggunakan medan magnet untuk menghasilkan gambaran detail bagian dalam tubuh.", "Alat pemindai tubuh menggunakan gelombang radio dan medan magnet untuk melihat struktur tubuh.", 1193046.0, "Mri"),
            ("CT Scan Machine", "Siemens Healthineers", "Menggunakan sinar-X untuk mengambil gambar detil tubuh.", "Pemindaian tubuh dengan menggunakan sinar-X untuk mendeteksi kelainan atau gangguan.", 1500000.0, "CT-Scan"),
            ("X-Ray Machine", "Philips Healthcare", "Menggunakan radiasi untuk menghasilkan gambar bagian dalam tubuh.", "Digunakan untuk mendeteksi patah tulang, infeksi, dan kelainan tubuh lainnya.", 100000.0, "Xray"),
            ("Ultrasound Machine", "Toshiba Medical", "Menggunakan gelombang suara berfrekuensi tinggi untuk menghasilkan gambar bagian dalam tubuh.", "Biasanya digunakan untuk pemeriksaan kehamilan dan mendiagnosis gangguan internal lainnya.", 20000.0, "ultrasound"),
            ("Defibrillator", "Zoll Medical", "Memberikan kejutan listrik untuk mengembalikan irama jantung normal.", "Digunakan dalam kasus darurat ketika jantung berhenti berdetak dengan normal.", 25000.0, "Defibiliator"),
            ("Ventilator", "Philips Respironics", "Membantu pasien bernafas dengan mengalirkan udara atau oksigen ke paru-paru.", "Umumnya digunakan untuk pasien yang tidak dapat bernapas dengan baik, seperti pada kondisi ICU.", 10000.0, "Ventilator"),
            ("ECG Machine", "Medtronic", "Mengukur aktivitas listrik jantung.", "Digunakan untuk mendeteksi gangguan jantung dan memonitor ritme jantung.", 2500.0, "ECG"),
            ("Endoscope", "Olympus", "Menggunakan kamera kecil untuk melihat bagian dalam tubuh melalui lubang kecil atau sayatan.", "Digunakan untuk pemeriksaan saluran cerna, saluran pernapasan, dan organ lainnya.", 15000.0, "endoscope"),
            ("Laser Surgery Equipment", "Lumenis", "Menggunakan sinar laser untuk melakukan pembedahan atau terapi.", "Digunakan dalam prosedur bedah untuk memotong atau menghancurkan jaringan tubuh.", 50000.0, "Lasersurgery"),
            ("Blood Pressure Monitor", "Omron", "Mengukur tekanan darah seseorang.", "Digunakan untuk memonitor kondisi hipertensi atau hipotensi.", 100.0, "bloodpreasure")
        ]
        
        for barang in barangData {
            let newBarang = NSManagedObject(entity: barangEntity, insertInto: context)
            newBarang.setValue(barang.namaproduk, forKey: "namaproduk")
            newBarang.setValue(barang.brand, forKey: "brand")
            newBarang.setValue(barang.carakerja, forKey: "carakerja")
            newBarang.setValue(barang.detail, forKey: "detail")
            newBarang.setValue(barang.harga, forKey: "harga")
            
            // Menyimpan gambar sebagai data
            if let image = UIImage(named: barang.gambar) {
                if let imageData = image.pngData() {
                    newBarang.setValue(imageData, forKey: "gambar")
                }
            }
        }
        
        // Simpan context
        do {
            try context.save()
        } catch let error as NSError {
            print("Failed to save data: \(error), \(error.userInfo)")
        }
    }
    
    func deleteAllBarang() {
        guard let context = context else {
            print("Context is nil!")
            return
        }
        
        // Membuat fetch request untuk mengambil semua entitas Barang
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "Barang")
        
        // Mengambil semua objek Barang
        do {
            // Mengambil semua entitas Barang dari Core Data
            let barangList = try context.fetch(fetchRequest)
            
            // Menghapus setiap objek Barang
            for object in barangList {
                if let managedObject = object as? NSManagedObject {
                    context.delete(managedObject)
                }
            }
            
            // Menyimpan perubahan setelah penghapusan
            try context.save()
            print("Semua data Barang berhasil dihapus!")
            
        } catch let error as NSError {
            print("Gagal menghapus data Barang: \(error), \(error.userInfo)")
        }
    }
    
    func fetchDetail(namaProduk: String, brand: String) {
        // Inisialisasi array detail untuk menyimpan hasil fetch
        detail = [detailBarang]()

        // Membuat fetch request untuk entitas Barang
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Barang")

        // Membuat predicate untuk mencari berdasarkan nama produk dan brand
        let predicate = NSPredicate(format: "namaproduk == %@ AND brand == %@", namaProduk, brand)
        fetchRequest.predicate = predicate

        do {
            // Mengambil data dari Core Data dengan filter berdasarkan nama produk dan brand
            let result = try context.fetch(fetchRequest) as! [NSManagedObject]

            // Memetakan hasil fetch ke array detailBarang
            for item in result {
                if let nama = item.value(forKey: "namaproduk") as? String,
                   let detailText = item.value(forKey: "detail") as? String,
                   let imageData = item.value(forKey: "gambar") as? Data,  // Gambar disimpan sebagai Data
                   let gambar = UIImage(data: imageData),  // Mengonversi Data ke UIImage
                   let harga = item.value(forKey: "harga") as? Double,
                   let caraKerja = item.value(forKey: "carakerja") as? String {
                    
                    // Menambahkan detail barang ke array detail
                    let newBarang = detailBarang(nama: nama, detail: detailText, harga: harga, carakerja: caraKerja, image: gambar)
                    detail.append(newBarang)
                }
            }

            print("Data detail barang berhasil diambil!")
            print("Jumlah detail barang: \(detail.count)")
        } catch let error as NSError {
            print("Failed to fetch data: \(error), \(error.userInfo)")
        }
    }
    
    func addItemToCart(namaproduk: String, quantity: Int32, email: String, from viewController: UIViewController) {
        // Mendapatkan context dari app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Error: Could not get AppDelegate")
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        
        // Membuat instance baru dari entitas Cart
        let newCartItem = NSEntityDescription.insertNewObject(forEntityName: "Cart", into: context)
        
        // Menetapkan nilai-nilai untuk atribut Cart
        newCartItem.setValue(namaproduk, forKey: "namaproduk")
        newCartItem.setValue(quantity, forKey: "quantity")
        newCartItem.setValue(email, forKey: "email")
        
        // Menyimpan perubahan
        do {
            try context.save()
            print("Item berhasil ditambahkan ke Cart")
            // Menampilkan alert setelah berhasil menambahkan item
                    let alert = UIAlertController(title: "Berhasil", message: "Item '\(namaproduk)' telah berhasil ditambahkan ke keranjang.", preferredStyle: .alert)
                    
                    // Menambahkan action untuk alert
                    let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                        // Anda bisa menambahkan tindakan lain jika diperlukan setelah klik OK
                    }
                    alert.addAction(okAction)
                    
                    // Menampilkan alert
                    viewController.present(alert, animated: true, completion: nil)
        } catch {
            print("Error saving context: \(error.localizedDescription)")
            // Menampilkan alert jika terjadi error saat menyimpan
                    let errorAlert = UIAlertController(title: "Error", message: "Terjadi kesalahan saat menambahkan item ke keranjang. Silakan coba lagi.", preferredStyle: .alert)
                    let errorAction = UIAlertAction(title: "OK", style: .default)
                    errorAlert.addAction(errorAction)
                    viewController.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    // Fungsi untuk mengambil data Cart berdasarkan email, termasuk namaproduk, quantity, harga, dan image dari Assets
        func fetchCartItems(email: String) {
            
            listCart = [cartItem]()  // Array untuk menyimpan item cart yang akan diambil
            
            // Membuat fetch request untuk entitas Cart berdasarkan email
            let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Cart")
            fetchRequest.predicate = NSPredicate(format: "email == %@", email)
            
            do {
                // Mengambil semua data dari entitas Cart berdasarkan email
                let cartList = try context.fetch(fetchRequest)
                
                // Melakukan iterasi terhadap semua item di Cart
                for item in cartList {
                    // Memastikan bahwa kita bisa mengambil nilai yang diperlukan dari item Cart
                    if let namaproduk = item.value(forKey: "namaproduk") as? String,
                       let quantity = item.value(forKey: "quantity") as? Int32,
                       let email = item.value(forKey: "email") as? String {
                        
                        // Mengambil harga dan gambar produk terkait dari entitas Barang
                        if let productData = getProductDataForProduct(namaproduk: namaproduk, context: context) {
                            // Ambil gambar dari Assets.xcassets menggunakan nama gambar
                            let gambar = UIImage(data:  productData.imageName)
                            
                            // Membuat item cart dengan informasi yang sudah diambil
                            let cartItem = cartItem(email: email,
                                                     namaproduk: namaproduk,
                                                     quantity: Int(quantity),
                                                     image: gambar ?? UIImage(), // Gunakan gambar default jika tidak ditemukan
                                                     harga: productData.harga)
                            
                            // Menambahkan item ke dalam listCart
                            listCart.append(cartItem)
                        } else {
                            // Jika produk tidak ditemukan di entitas Barang
                            print("Data produk tidak ditemukan untuk \(namaproduk)")
                        }
                    }
                }
                
                // Menyimpan perubahan jika diperlukan
                do {
                    try context.save()  // Simpan context jika ada perubahan
                } catch {
                    print("Failed to save context after fetching cart items: \(error.localizedDescription)")
                }
                
            } catch let error as NSError {
                // Menangani error jika fetch request gagal
                print("Failed to fetch Cart items: \(error), \(error.userInfo)")
            }
        }
        
        // Fungsi untuk mengambil data produk (harga, nama gambar) berdasarkan namaproduk dari entitas Barang
    private func getProductDataForProduct(namaproduk: String, context: NSManagedObjectContext) -> (harga: Double, imageName: Data)? {
            // Membuat fetch request untuk entitas Barang
            let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Barang")
            fetchRequest.predicate = NSPredicate(format: "namaproduk == %@", namaproduk)
            
            do {
                // Mengambil barang yang sesuai
                let barangList = try context.fetch(fetchRequest)
                
                if let barang = barangList.first {
                    // Mengambil harga produk dan nama gambar produk dari entitas Barang
                    if let harga = barang.value(forKey: "harga") as? Double,
                       let imageName = barang.value(forKey: "gambar") as? Data {
                        return (harga, imageName)  // Mengembalikan harga dan nama gambar
                    } else {
                        print("Data harga atau gambar tidak ditemukan untuk produk \(namaproduk)")
                    }
                }
            } catch let error as NSError {
                // Menangani error jika fetch request gagal
                print("Failed to fetch product data: \(error), \(error.userInfo)")
            }
            
            return nil  // Kembalikan nil jika data tidak ditemukan
        }
    
    func updateCartQuantityInCoreData(for cartItem: cartItem, newQuantity: Int, email: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Cart")
        fetchRequest.predicate = NSPredicate(format: "namaproduk == %@ AND email == %@", cartItem.namaproduk, email)  // Ganti dengan email yang sesuai
        
        do {
            let result = try context.fetch(fetchRequest)
            if let cartEntity = result.first {
                cartEntity.setValue(newQuantity, forKey: "quantity")
                try context.save()
                
                print("item update")
            }
        } catch let error as NSError {
            print("Error updating cart quantity: \(error), \(error.userInfo)")
        }
    }

    func deleteCartItemByProductName(productName: String, email: String) {
        // Mendapatkan referensi ke konteks managed object
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Membuat request untuk mencari item berdasarkan nama produk
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Cart")
        fetchRequest.predicate = NSPredicate(format: "namaproduk == %@ AND email == %@", productName, email)
        
        do {
            // Mengambil data cart dengan nama produk dan email yang sesuai
            let cartItems = try context.fetch(fetchRequest)
            
            // Jika ada item yang ditemukan, hapus item tersebut
            if let cartItem = cartItems.first {
                context.delete(cartItem)
                
                // Menyimpan perubahan ke Core Data
                try context.save()
                print("Item \(productName) berhasil dihapus dari keranjang.")
                
                // Setelah penghapusan, fetch ulang data dan update UI
                fetchCartItems(email: email) // Pastikan untuk memanggil ulang fetch data cart
                
            } else {
                print("Item \(productName) tidak ditemukan dalam keranjang.")
            }
            
        } catch let error {
            print("Gagal menghapus item: \(error.localizedDescription)")
        }
    }
    
    func deleteAllCartItemsByEmail(email: String) {
        // Mendapatkan referensi ke konteks managed object
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Membuat request untuk mencari semua item berdasarkan email
        let fetchRequest: NSFetchRequest<NSManagedObject> = NSFetchRequest(entityName: "Cart")
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        
        do {
            // Mengambil semua data cart yang sesuai dengan email
            let cartItems = try context.fetch(fetchRequest)
            
            // Jika ada item yang ditemukan, hapus semua item tersebut
            for cartItem in cartItems {
                context.delete(cartItem)
            }
            
            // Menyimpan perubahan ke Core Data
            try context.save()
            print("Semua item dari keranjang dengan email \(email) berhasil dihapus.")
            
            // Setelah penghapusan, fetch ulang data dan update UI
            fetchCartItems(email: email) // Pastikan untuk memanggil ulang fetch data cart
            
        } catch let error {
            print("Gagal menghapus semua item: \(error.localizedDescription)")
        }
    }




}
