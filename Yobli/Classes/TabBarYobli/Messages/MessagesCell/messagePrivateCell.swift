//
//  messagePrivateCell.swift
//  Yobli
//
//  Created by Brounie on 09/12/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import UIKit
import MessageKit

protocol messageCustomDelegate:class {
    func goTo(position: IndexPath)
}

// Customize this collection view cell with data passed in from message, which is of type .custom
open class messagePrivateCell: UICollectionViewCell {
    
    var delegate : messageCustomDelegate?
    var position: IndexPath?
    
    open func configure(with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        
        switch message.kind {
        
        case .custom(let content):
            
            guard let arrayNS = content as? NSArray else{
                return
            }
            
            self.contentView.backgroundColor = UIColor.init(red: 0, green: 215/255, blue: 255/255, alpha: 1)
            self.contentView.roundCustomView(divider: 32)
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapGesture(_:)))
            self.contentView.addGestureRecognizer(tap)
            
            let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height))
            
            messageLabel.text = ("\(arrayNS[1])")
            messageLabel.textAlignment = .center
            
            self.contentView.addSubview(messageLabel)
            
        default:
            break
        }
        
        
    }
    
    @objc open func handleTapGesture(_ gesture: UIGestureRecognizer) {
        
        guard let position = position else{
            print("It failed")
            return
        }
        
        delegate?.goTo(position: position)
        
    }
}
