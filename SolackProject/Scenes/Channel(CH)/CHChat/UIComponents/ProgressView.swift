//
//  ProgressView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/27/24.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
final class CHProgressVC: BaseVC{
    var progressNumber: BehaviorSubject<Float> = .init(value: 0)
    var placeholder = ""{
        didSet{
            self.progressView.placeholder = placeholder
        }
    }
    func makeInit(){
        self.progressView.progress.setProgress(0, animated: false)
    }
    private var disposeBag = DisposeBag()
    private let progressView = CHProgressView()
    override func viewDidLoad() {
        super.viewDidLoad()
        progressNumber.subscribe(on: MainScheduler.instance).bind(with: self) { owner, value in
            Task{@MainActor in
                owner.progressView.progress.setProgress(value, animated: true)
            }
        }.disposed(by: disposeBag)
        view.backgroundColor = .gray.withAlphaComponent(0.33)
    }
    override func configureView() {
        view.addSubview(progressView)
        progressView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
final class CHProgressView: UIView{
    var progress = UIProgressView()
    var progressNumber: BehaviorSubject<Float> = .init(value: 0)
    var placeholder:String = ""{
        didSet{ label.text = placeholder }
    }
    let label = UILabel()
    private var disposeBag = DisposeBag()
    private lazy var stView = {
       let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.addArrangedSubview(label)
        stackView.addArrangedSubview(progress)
        label.font = FontType.title1.get()
        progress.snp.makeConstraints { make in
            make.height.equalTo(4)
        }
        progress.progressViewStyle = .bar
        progress.layer.cornerRadius = 5
        progress.layer.cornerCurve = .circular
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        return stackView
    }()
    init(){
        super.init(frame: .zero)
        let view = UIView()
        addSubview(view)
        view.addSubview(stView)
        view.snp.makeConstraints { make in
            make.center.equalToSuperview()
            
            make.horizontalEdges.equalToSuperview().inset(24)
            make.height.equalTo(view.snp.width).multipliedBy(0.5)
        }
        stView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        view.backgroundColor = .gray6
        view.layer.cornerRadius = 16
        view.layer.cornerCurve = .circular
        self.backgroundColor = .gray3.withAlphaComponent(0.66)
        label.textColor = .white
        progress.tintColor = .accent
        progress.trackTintColor = .gray1
        label.textAlignment = .center
        self.progressNumber.subscribe(on: MainScheduler.instance).bind(with: self) { owner, value in
            Task{@MainActor in
                owner.progress.setProgress(value,animated:true)
            }
        } .disposed(by: disposeBag)
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
