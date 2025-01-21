//
//  NavigationView.swift
//  GloriaNavigation
//
//  Created by Emre Kuru on 21.01.2025.
//

import UIKit
import PoilabsNavigation

class NavigationView: UIView {
  
  var currentCarrier: PLNNavigationMapView?
  
  @objc var language: NSString = "tr" {
    didSet {
      PLNNavigationSettings.sharedInstance().applicationLanguage = language as String
      if self.currentCarrier != nil {
        self.currentCarrier?.removeFromSuperview()
        initMap()
      }
    }
  }
  
  @objc var showOnMap: NSString?
  @objc var getRouteTo: NSString?
  
  //initWithFrame to init view from code
  override init(frame: CGRect) {
      super.init(frame: frame)
      initMap()
  }
  
  //initWithCode to init view from xib or storyboard
  required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      initMap()
  }

  func initMap() {
    NotificationCenter.default.addObserver(self, selector: #selector(showPointOnMap), name: Notification.Name("showPointOnMap"), object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(navigateTo), name: Notification.Name("getRouteTo"), object: nil)

    PLNNavigationSettings.sharedInstance().applicationId = "APPLICATION_ID"
    PLNNavigationSettings.sharedInstance().applicationSecret = "SECRET_KEY"
  PLNNavigationSettings.sharedInstance().navigationUniqueIdentifier = "UNIQUE_ID"

    PLNavigationManager.sharedInstance()?.getReadyForStoreMap(completionHandler: { (error) in
      if error == nil {
          let carrierView = PLNNavigationMapView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
          carrierView.awakeFromNib()
          carrierView.delegate = self
          carrierView.searchBarBaseView.backgroundColor = UIColor.black
          carrierView.searchCancelButton.setTitleColor(.white, for: .normal)
          self.currentCarrier = carrierView
          self.addSubview(carrierView)
        } else {
          //show error
        }
    })
  }
  
  override func removeFromSuperview() {
    NotificationCenter.default.removeObserver(self)
  }
  
  @objc func showPointOnMap(_ notification: Notification) {
    if let storeId = notification.userInfo?["storeId"] as? String {
      currentCarrier?.getShowonMapPin(storeId)
    }
  }
  
  @objc func navigateTo(_ notification: Notification) {
    if let storeId = notification.userInfo?["storeId"] as? String {
      currentCarrier?.navigateWithStoreId(to: storeId)
    }
  }
}

extension NavigationView: PLNNavigationMapViewDelegate {
  func childsAreReady() {
    if let storeId = showOnMap {
      currentCarrier?.getShowonMapPin(storeId as String)
    } else if let storeId = getRouteTo {
      currentCarrier?.navigateWithStoreId(to: storeId as String)
    }
  }
}
