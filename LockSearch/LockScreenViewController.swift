
// image by NASA: https://www.flickr.com/photos/nasacommons/29193068676/

import UIKit

class LockScreenViewController: UIViewController {

  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var dateTopConstraint: NSLayoutConstraint!

  let blurView = UIVisualEffectView(effect: nil)

  var settingsController: SettingsViewController!
  
  // let scale = UIViewPropertyAnimator(duration: 0.33, curve: .easeIn)

  override func viewDidLoad() {
    super.viewDidLoad()

    view.bringSubview(toFront: searchBar)
    blurView.effect = UIBlurEffect(style: .dark)
    blurView.alpha = 0
    blurView.isUserInteractionEnabled = false
    view.insertSubview(blurView, belowSubview: searchBar)

    tableView.estimatedRowHeight = 130.0
    tableView.rowHeight = UITableViewAutomaticDimension
  }

  override func viewWillAppear(_ animated: Bool) {
    
    tableView.transform = CGAffineTransform(scaleX: 0.67, y: 0.67)
    tableView.alpha = 0
    
    // scale.startAnimation()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    
    
//    scale.addAnimations {
//      self.tableView.alpha = 1.0
//    }
//    scale.addAnimations({
//      self.tableView.transform = .identity
//    }, delayFactor: 13.33)
//    scale.addCompletion { _ in
//      print("ready")
//    }
    AnimatorFactory.scaleUp(view: tableView).startAnimation()
    
  }
  
  
  override func viewWillLayoutSubviews() {
    blurView.frame = view.bounds
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  @IBAction func presentSettings(_ sender: Any? = nil) {
    //present the view controller
    settingsController = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
    present(settingsController, animated: true, completion: nil)
  }
  
  func toggleBlur(_ blurred: Bool) {
//    UIViewPropertyAnimator.runningPropertyAnimator(
//      withDuration: 0.5, delay: 0.1, options: .curveEaseOut,
//      animations: {
//        self.blurView.alpha = blurred ? 1 : 0
//      },
//      completion: nil
//    )
    AnimatorFactory.fade(view: blurView, visible: blurred)
  }
  
}

extension LockScreenViewController: UISearchBarDelegate {
  
  func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    toggleBlur(true)
  }
  
  func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
    toggleBlur(false)
  }
  
  func searchBarResultsListButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    
    if searchText.isEmpty {
      searchBar.resignFirstResponder()
    }
  }
}

extension LockScreenViewController: WidgetsOwnerProtocol { }

extension LockScreenViewController: UITableViewDataSource {

  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.row == 1 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Footer") as! FooterCell
      cell.didPressEdit = {[unowned self] in
        self.presentSettings()
      }
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! WidgetCell
      cell.tableView = tableView
      cell.owner = self
      return cell
    }
  }
}
