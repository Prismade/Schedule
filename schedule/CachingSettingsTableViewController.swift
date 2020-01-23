import UIKit


class CachingSettingsTableViewController: UITableViewController {

    @IBOutlet weak var cachingSwitch: UISwitch!
    var numberOfSections = 2

    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true

        cachingSwitch.isOn = UserDefaults.standard.bool(forKey: "EnableCaching")
        cachingSwitch.addTarget(self, action: #selector(onSwitchToggle(sender:)), for: .valueChanged)

        if (cachingSwitch.isOn) {
            numberOfSections = 2
            toggleCell(row: UserDefaults.standard.integer(forKey: "RequestInterval"))
        } else {
            numberOfSections = 1
        }

        
    }

    @objc private func onSwitchToggle(sender: UISwitch) {
        UserDefaults.standard.set(sender.isOn, forKey: "EnableCaching")
        
        if (sender.isOn) {
            numberOfSections = 2
            tableView.reloadData()
        } else {
            numberOfSections = 1
            tableView.reloadData()
        }
    }
    
    private func toggleCell(row: Int) {
        for i in 0..<3 {
            let indexPath = IndexPath(row: i, section: 1)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.accessoryType = i == row ? .checkmark : .none
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 {
            toggleCell(row: indexPath.row)
            tableView.deselectRow(at: indexPath, animated: true)            
            UserDefaults.standard.set(indexPath.row, forKey: "RequestInterval")
        }
    }


}
