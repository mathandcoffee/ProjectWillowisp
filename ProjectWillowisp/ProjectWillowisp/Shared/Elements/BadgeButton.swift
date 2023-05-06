//
//  BadgeButton.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 3/23/23.
//

import UIKit

final class BadgeButton: UIButton {

    private var badgeLabel = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        badgeLabel.setTitleColor(.onPrimary, for: .normal)
        badgeLabel.backgroundColor = .primary
        badgeLabel.sizeToFit()
        badgeLabel.layer.cornerRadius = 7
        badgeLabel.layer.masksToBounds = true
        
        addSubview(badgeLabel)
        
        badgeLabel.isHidden = true
        badgeLabel.snp.makeConstraints { make in
            make.width.equalTo(0.toPostViewableString().count * 14)
            make.height.equalTo(14)
            make.centerX.equalTo(self.snp.right)
            make.centerY.equalTo(self.snp.top)
        }
    }

    func setBadge(number: Int) {
        let attrs = [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 10)]
        let attributedString = NSMutableAttributedString(string: number.toPostViewableString(), attributes: attrs)
        badgeLabel.setAttributedTitle(attributedString, for: .normal)
        badgeLabel.isHidden = number > 0 ? false : true
        badgeLabel.snp.remakeConstraints { make in
            make.width.equalTo(number.toPostViewableString().count * 14)
            make.height.equalTo(14)
            make.centerX.equalTo(self.snp.right)
            make.centerY.equalTo(self.snp.top)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setBadge(number: 0)
        fatalError("init(coder:) is not implemented")
    }
}
