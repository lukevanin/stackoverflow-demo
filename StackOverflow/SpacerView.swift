//
//  SpacerView.swift
//  StackOverflow
//
//  Created by Luke Van In on 2021/05/12.
//

import UIKit

final class VerticalSpacerView: UIView {
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        #warning("TODO: Make this view expand to fill the available space")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
