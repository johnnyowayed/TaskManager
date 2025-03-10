//
//  UIViewController+Extensions.swift
//  TaskManager
//
//  Created by Johnny Owayed on 07/03/2025.
//

import UIKit

extension UIViewController {
    func preferredUserInterfaceStyleOverride(_ style: UIUserInterfaceStyle) -> UIViewController {
        self.overrideUserInterfaceStyle = style
        return self
    }
}
