import UIKit

// Jika barang didefinisikan di tempat lain, pastikan sudah diimpor dengan benar.
class cartCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageUI: UIImageView!
    @IBOutlet weak var namaUi: UILabel!
    @IBOutlet weak var hargaUI: UILabel!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var quantity: UILabel!
    
    var collectionView: UICollectionView! // Menambahkan referensi ke collectionView
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Menerapkan rotasi pada stepper agar tampil vertikal
        stepper.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        
        // Menambahkan target untuk memperbarui label quantity saat stepper berubah
        stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
        
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        guard let indexPath = self.indexPath else { return }
        
        // Dapatkan item dari dataCart berdasarkan indexPath
        var cartItem = dataCart.listCart[indexPath.row]
        
        let newQuantity = Int(sender.value)
        
        // Update Core Data dengan quantity yang baru
        dataCart.updateCartQuantityInCoreData(for: cartItem, newQuantity: newQuantity, email: UserDefaults.standard.string(forKey: "email")!)
        
        // Update model lokal
        dataCart.listCart[indexPath.row].quantity = newQuantity
        
        // Update label quantity pada cell
        self.quantity.text = "\(newQuantity)"
        
        // Reload item untuk refleksikan kuantitas yang terupdate
        collectionView.reloadItems(at: [indexPath])
        
        // Memperbarui total harga di ViewController
        if let viewController = self.collectionView.delegate as? ViewController {
            viewController.updateTotalPriceLabel()
        }
    }
}
