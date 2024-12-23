import UIKit

class cartListTableViewCell: UITableViewCell {

    @IBOutlet weak var namaProdukLBL: UILabel!
    @IBOutlet weak var hargaLBL: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var gambar: UIImageView!
    @IBOutlet weak var stepper: UIStepper!
    
    var tableView: UITableView! // Referensi ke tableView
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Rotasi stepper agar tampil secara vertikal
        stepper.transform = CGAffineTransform(rotationAngle: -CGFloat.pi / 2)
        
        // Menambahkan target untuk memperbarui label quantity saat stepper berubah
        stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)
        
        // Menambahkan corner radius pada cell
        self.layer.cornerRadius = 10
        self.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        guard let indexPath = self.indexPath else { return }
        
        // Ambil item dari dataCart berdasarkan indexPath
        var cartItem = dataCart.listCart[indexPath.row]
        
        // Ambil nilai baru dari stepper
        let newQuantity = Int(sender.value)
        
        // Update Core Data dengan quantity yang baru
        dataCart.updateCartQuantityInCoreData(for: cartItem, newQuantity: newQuantity, email: UserDefaults.standard.string(forKey: "email")!)
        
        // Update model lokal (listCart)
        dataCart.listCart[indexPath.row].quantity = newQuantity
        
        // Update label quantity pada cell
        self.quantity.text = "\(newQuantity)"
        
        // Reload item untuk refleksikan kuantitas yang terupdate
        // Pastikan kita reload hanya cell yang berubah, dengan indexPath yang sesuai
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
        // Memperbarui total harga di ViewController
        if let viewController = self.tableView.delegate as? ViewController {
            viewController.updateTotalPriceLabel()
        }
    }
}
