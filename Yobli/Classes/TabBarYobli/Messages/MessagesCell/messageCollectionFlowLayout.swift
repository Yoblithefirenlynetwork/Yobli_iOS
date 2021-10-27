//
//  messageCollectionFlowLayout.swift
//  Yobli
//
//  Created by Brounie on 09/12/20.
//  Copyright © 2020 Brounie. All rights reserved.
//

import Foundation
import MessageKit

open class messageCollectionFlowLayout: MessagesCollectionViewFlowLayout {
    
    lazy open var customMessageSizeCalculator = CustomMessageSizeCalculator(layout: self)

    override open func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return customMessageSizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath);
    }
    
}

open class CustomMessageSizeCalculator: MessageSizeCalculator {
    open override func messageContainerSize(for message: MessageType) -> CGSize {
        
         //TODO - Customize to size your content appropriately. This just returns a constant size.
        if case .custom = message.kind{
            
            return CGSize(width: 80, height: 30)
            
        }
        
        return CGSize(width: 0, height: 0)
        
    }
}
