//
//  ProfileViewController.swift
//  Messenger
//
//  Created by MAC on 17/02/22.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
class ProfileViewController: UIViewController {

    @IBOutlet var tableView: UITableView!
    let data = ["Log Out"]
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let actionsheet = UIAlertController(title: "",
                                            message: "Are you sure",
                                            preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Log Out",
                                            style: .destructive, handler: { [weak self]_ in
            guard let strongSelf = self else {
                return
            }
            // log out facebook
            FBSDKLoginKit.LoginManager().logOut()
            // Google signout
            GIDSignIn.sharedInstance.signOut()
            do{
                try Firebase.Auth.auth().signOut()
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                strongSelf.present(nav, animated: true, completion: nil)
            }
            catch
            {
                print("Failed to log out...")
            }
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        present(actionsheet, animated: true, completion: nil)
       
    }
}
