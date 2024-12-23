import UIKit

class ProfileDetail: UIViewController {

    @IBOutlet weak var backgroundputih: UIView!
    @IBOutlet weak var tlpLBL: UILabel!
    
    @IBOutlet weak var usernameLBL: UILabel!
    @IBOutlet weak var emailLBL: UILabel!
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tlpLBL.text = UserDefaults.standard.string(forKey: "tlp")
        usernameLBL.text = UserDefaults.standard.string(forKey: "username")
        emailLBL.text = UserDefaults.standard.string(forKey: "email")

        // Make the backgroundputih view have rounded corners
        backgroundputih.layer.cornerRadius = 40  // Adjust the value as needed
        backgroundputih.layer.masksToBounds = true  // Ensure content inside the view is clipped to the rounded corners
    }
}
