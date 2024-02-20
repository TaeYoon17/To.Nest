//
//  DMEmptyView.swift
//  SolackProject
//
//  Created by 김태윤 on 2/14/24.
//
import UIKit
import SnapKit
import RxSwift
import RxCocoa
final class DMEmptyView:UIView{
    var tap: ControlEvent<Void>!
    let titleLabel = UILabel()
    let descLabel = UILabel()
    let btn = UIButton()
    lazy var stView = {
        let st = UIStackView(arrangedSubviews: [titleLabel,descLabel,btn])
        st.axis = .vertical
        st.spacing = 19
        st.alignment = .fill
        st.distribution = .fill
        btn.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
        return st
    }()
    init(){
        super.init(frame: .zero)
        titleLabel.text = "워크스페이스에\n멤버가 없어요"
        titleLabel.font = FontType.title1.get()
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        descLabel.text = "새로운 팀원을 초대해보세요."
        descLabel.font = FontType.body.get()
        descLabel.textAlignment = .center
        btn.config.backgroundColor(.accent).cornerRadius(8).foregroundColor(.white)
            .text("팀원 초대하기", font: FontType.title2)
            .apply()
        self.addSubview(stView)
        stView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-46)
            make.width.equalTo(300)
        }
        self.tap = btn.rx.tap
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
}
