//
//  SignUpView+CollectionView.swift
//  SolackProject
//
//  Created by 김태윤 on 1/3/24.
//

import UIKit
extension SignUpView{
    func configureCollectionView(){
        
    }
    var layout: UICollectionViewCompositionalLayout{
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
}
