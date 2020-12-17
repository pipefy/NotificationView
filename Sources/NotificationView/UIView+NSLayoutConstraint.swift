//
//  UIView+NSLayoutConstraint.swift
//  NotificationView
//
//  Created by Amadeu Cavalcante on 17/12/20.
//

import Foundation
import UIKit

internal extension UIView {
    func pinEdgesToSuperview() {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        constraints.append(self.topAnchor.constraint(equalTo: superview.topAnchor))
        constraints.append(self.leadingAnchor.constraint(equalTo: superview.leadingAnchor))
        constraints.append(self.trailingAnchor.constraint(equalTo: superview.trailingAnchor))
        constraints.append(self.bottomAnchor.constraint(equalTo: superview.bottomAnchor))
        NSLayoutConstraint.activate(constraints)
    }
}
