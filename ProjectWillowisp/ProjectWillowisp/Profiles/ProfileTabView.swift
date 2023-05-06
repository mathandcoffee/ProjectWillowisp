//
//  ProfileTabView.swift
//  mac-dystoria-ios
//
//  Created by Bryan Malumphy on 12/24/21.
//

import UIKit

class ProfileTabView: UIView {
    let stackView = UIStackView()
    let underlineView = UIView()
    var selectAction: ((Int) -> Void)?
    
    init(titles: [String]) {
        super.init(frame: .zero)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.backgroundColor = .background
        for index in 0..<titles.count {
            let title = titles[index]
            let button = UIButton()
            button.addTarget(self, action: #selector(tabButtonPressed(_:)), for: .touchUpInside)
            button.setTitleColor(.onBackground, for: .normal)
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = .overline
            stackView.addArrangedSubview(button)
        }
        
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.leading.top.trailing.equalToSuperview()
        }
        
        let seperatorView = UIView()
        seperatorView.backgroundColor = UITableView().separatorColor
        addSubview(seperatorView)
        seperatorView.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(stackView)
        }
        
        underlineView.backgroundColor = .onPrimary
        addSubview(underlineView)
        underlineView.snp.makeConstraints { make in
            make.height.equalTo(2)
            make.leading.equalToSuperview()
            make.bottom.equalTo(stackView)
            make.width.equalToSuperview().dividedBy(titles.count)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tabButtonPressed(_ button: UIButton) {
        guard let index = stackView.arrangedSubviews.firstIndex(of: button) else {
            fatalError()
        }
        
        selectTab(at: index, animated: true)
    }
    
    private func selectTab(at index: Int, animated: Bool) {
        selectAction?(index)
        for buttonIndex in 0..<stackView.arrangedSubviews.count {
            let button = stackView.arrangedSubviews[buttonIndex]
            button.applyEmphasis(buttonIndex == index ? .high : .disabled)
        }
        
        // Layout everything else before animation
        if animated {
            layoutIfNeeded()
        }

        let totalWidth = frame.width
        let buttonCount = stackView.arrangedSubviews.count
        let buttonWidth = totalWidth / CGFloat(buttonCount)
        underlineView.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(buttonWidth * CGFloat(index))
        }

        // Animate underline view
        if animated {
            UIView.animate(withDuration: 0.25) {
                self.layoutIfNeeded()
            }
        }
    }
}

