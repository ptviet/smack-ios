

import UIKit

@IBDesignable
class CircleImage: UIImageView {
  
  override func awakeFromNib() {
    self.setupView()
  }
  
  override func prepareForInterfaceBuilder() {
    super.prepareForInterfaceBuilder()
    self.setupView()
  }
  
  func setupView() {
    self.layer.cornerRadius = self.frame.width / 2
    self.clipsToBounds = true
  }

}
