// Copyright 2019-present the Material Components for iOS authors. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import MaterialComponents.MaterialCards_Theming 
import MaterialComponents.MaterialColorScheme
import MaterialComponents.MaterialContainerScheme
import MaterialComponents.MaterialTypographyScheme

class CardCellsWithRippleExample: UIViewController,
  UICollectionViewDelegate,
  UICollectionViewDataSource,
  UICollectionViewDelegateFlowLayout
{

  enum ToggleMode: Int {
    case edit = 1
    case reorder
  }

  let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout())
  var toggle = ToggleMode.edit

  @objc var containerScheme: MDCContainerScheming

  @objc var colorScheme: MDCColorScheming {
    return containerScheme.colorScheme
  }

  @objc var typographyScheme: MDCTypographyScheming {
    return containerScheme.typographyScheme
  }

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    containerScheme = MDCContainerScheme()
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.frame = view.bounds
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = colorScheme.backgroundColor
    collectionView.alwaysBounceVertical = true
    collectionView.register(MDCCardCollectionCell.self, forCellWithReuseIdentifier: "Cell")
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.allowsMultipleSelection = true
    view.addSubview(collectionView)

    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "Reorder",
      style: .plain,
      target: self,
      action: #selector(toggleModes))

    let longPressGesture = UILongPressGestureRecognizer(
      target: self,
      action: #selector(reorderCards(gesture:)))
    longPressGesture.cancelsTouchesInView = false
    collectionView.addGestureRecognizer(longPressGesture)

    let guide = view.safeAreaLayoutGuide
    NSLayoutConstraint.activate([
      collectionView.leftAnchor.constraint(equalTo: guide.leftAnchor),
      collectionView.rightAnchor.constraint(equalTo: guide.rightAnchor),
      collectionView.topAnchor.constraint(equalTo: view.topAnchor),
      collectionView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
    ])
    collectionView.contentInsetAdjustmentBehavior = .always

    self.updateTitle()
  }

  func preiOS11Constraints() {
    self.view.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "H:|[view]|",
        options: [],
        metrics: nil,
        views: ["view": collectionView]))
    self.view.addConstraints(
      NSLayoutConstraint.constraints(
        withVisualFormat: "V:|[view]|",
        options: [],
        metrics: nil,
        views: ["view": collectionView]))
  }

  func updateTitle() {
    switch toggle {
    case .edit:
      navigationItem.rightBarButtonItem?.title = "Reorder"
      self.title = "Cards (Edit)"
    case .reorder:
      navigationItem.rightBarButtonItem?.title = "Edit"
      self.title = "Cards (Reorder)"
    }
  }

  @objc func toggleModes() {
    switch toggle {
    case .edit:
      toggle = .reorder
    case .reorder:
      toggle = .edit
    }
    self.updateTitle()
    collectionView.reloadData()
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    guard let cardCell = cell as? MDCCardCollectionCell else { return cell }
    cardCell.enableRippleBehavior = true
    cardCell.applyTheme(withScheme: containerScheme)
    cardCell.isSelectable = (toggle == .edit)
    cardCell.isAccessibilityElement = true
    cardCell.accessibilityLabel = title

    return cardCell
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    guard toggle == .edit else { return }
  }

  func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    guard toggle == .edit else { return }
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return 30
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let cardSize = (collectionView.bounds.size.width / 3) - 12
    return CGSize(width: cardSize, height: cardSize)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    insetForSectionAt section: Int
  ) -> UIEdgeInsets {
    return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumLineSpacingForSectionAt section: Int
  ) -> CGFloat {
    return 8
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    minimumInteritemSpacingForSectionAt section: Int
  ) -> CGFloat {
    return 8
  }

  func collectionView(
    _ collectionView: UICollectionView,
    canMoveItemAt indexPath: IndexPath
  ) -> Bool {
    return toggle == .reorder
  }

  func collectionView(
    _ collectionView: UICollectionView,
    moveItemAt sourceIndexPath: IndexPath,
    to destinationIndexPath: IndexPath
  ) {
  }

  @objc func reorderCards(gesture: UILongPressGestureRecognizer) {

    switch gesture.state {
    case .began:
      guard
        let selectedIndexPath = collectionView.indexPathForItem(
          at:
            gesture.location(in: collectionView))
      else { break }
      let cell = collectionView.cellForItem(at: selectedIndexPath)
      guard let cardCell = cell as? MDCCardCollectionCell else { break }
      collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
      if toggle == .reorder {
        cardCell.isDragged = true
      }
    case .changed:
      guard let gestureView = gesture.view else { break }
      collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gestureView))
    case .ended:
      collectionView.endInteractiveMovement()
    default:
      collectionView.cancelInteractiveMovement()
    }
  }

}

extension CardCellsWithRippleExample {

  @objc class func catalogMetadata() -> [String: Any] {
    return [
      "breadcrumbs": ["Ripple", "Card Cell with Ripple"],
      "primaryDemo": false,
      "presentable": true,
    ]
  }
}
