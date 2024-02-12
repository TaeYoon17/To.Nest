//
//  BaseVC.swift
//  SlapProject
//
//  Created by 김태윤 on 1/2/24.
//

import UIKit
import RxSwift
class BaseVC: UIViewController{
    @MainActor private lazy var overLayer: CALayer = {
        var layer = CALayer()
        layer.frame = self.view.frame
        layer.backgroundColor = UIColor.black.withAlphaComponent(0.333).cgColor
        return layer
    }()
    @MainActor lazy var isLoading: Bool = false{
        didSet{
            Task{
                await MainActor.run {
                    if isLoading{
                        overLayer.isHidden = false
                        activitiIndicator.startAnimating()
                    }else{
                        overLayer.isHidden = true
                        activitiIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    private lazy var activitiIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.accent
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.medium
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureNavigation()
        configureConstraints()
        configureView()
        self.view.layer.addSublayer(overLayer)
        view.addSubview(activitiIndicator)
        overLayer.isHidden = true
    }
    func configureLayout(){ }
    func configureConstraints(){ }
    func configureView(){ }
    func configureNavigation(){ }
    
    
    
}
