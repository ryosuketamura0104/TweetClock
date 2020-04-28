//
//  SettingsTableViewController.swift
//  TweetClock
//
//  Created by Ryosuke Tamura on 2020/04/25.
//  Copyright © 2020 Ryosuke Tamura. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var twitterAccountLabel: UILabel!
    
    private let twitter = SwifterWrapper.share
    private let twitterAccountStore = TwitterAccountStore.shared
    
    private let disposeBag = DisposeBag()
    
    private let authUserAccountUseCase = AuthUserAccountUseCase()
    private let loadTimeLineUseCase = LoadTimeLineUseCase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkTwitterAcccount()
        
        twitterAccountStore.update().skip(1).subscribe(){ _ in
            self.checkTwitterAcccount()
            self.twitter.getTimeline()
        }.disposed(by: disposeBag)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    // Cell が選択された場合
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            authUserAccountUseCase.execute(viewController: self,success: {
                self.loadTimeLineUseCase.execute()
                self.dismiss(animated: true, completion: nil)
            },error: {
                self.popAlert(title: "エラー", messege: "連携に失敗しました\n別のアカウントで接続してみるか、時間を空けてください", time: 1.0)
            })
        case 1:
            present(Router.presentColorSettingView(type: .BACKGROUND), animated: true, completion: nil)
        case 2:
            present(Router.presentColorSettingView(type: .TEXT), animated: true, completion: nil)
        default:
            print("Error")
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

private extension SettingsTableViewController{
    func checkTwitterAcccount(){
        if twitterAccountStore.value.isLogined(){
            twitterAccountLabel.text = "Twitterアカウント（設定済み）"
        }
    }
}
