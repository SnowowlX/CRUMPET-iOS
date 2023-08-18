//
//  ContentSized.swift
//  CRUMPET
//
//  Created by Andrew Shoben on 18/08/2023.
//  Copyright © 2023 Iottive. All rights reserved.
//

import Foundation
import UIKit

final class ContentSizedTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric,
                     height: contentSize.height + adjustedContentInset.top)
    }
}
