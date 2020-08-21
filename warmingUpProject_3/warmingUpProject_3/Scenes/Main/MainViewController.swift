//
//  MainViewController.swift
//  warmingUpProject_3
//
//  Created by 이규현 on 2020/08/12.
//  Copyright © 2020 team3. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Action
import NSObject_Rx
import NMapsMap
import CoreLocation

class MainViewController: UIViewController, ViewModelBindableType {
    
    var viewModel: MainViewModel!
    
    var locationManager: CLLocationManager?
    
    let naverMapView = NMFNaverMapView()
    
    var markers: [NMFMarker] = [NMFMarker(position: NMGLatLng(lat: 37.5666102, lng: 126.9783881))]
    
    var mapView: NMFMapView {
        let locationOverlay = naverMapView.mapView.locationOverlay
        locationOverlay.circleOutlineWidth = 50
        locationOverlay.circleColor = UIColor.blue
        locationOverlay.hidden = false
        locationOverlay.icon = NMFOverlayImage(name: "imgLocationDirection", in: Bundle.naverMapFramework())
        locationOverlay.subIcon = nil
        
        naverMapView.mapView.touchDelegate = self
//        locationOverlay.touchHandler = { [unowned self] Bool in
//        }
        return naverMapView.mapView
    }
    
    let profileBaseView: UIView = {
        let profileView = UIView()
        profileView.backgroundColor = .white
        profileView.layer.cornerRadius = 23
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Profile")
        imageView.layer.cornerRadius = 19
        
        let lbTitle = UILabel()
        lbTitle.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        lbTitle.textAlignment = .center
        lbTitle.setTextWithLetterSpacing(text: "외로운 규현", letterSpacing: -0.06, lineHeight: 16)
        profileView.addSubview(imageView)
        profileView.addSubview(lbTitle)
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(4)
            make.leading.equalTo(4)
            make.width.equalTo(38)
            make.bottom.equalTo(-4)
        }
        
        lbTitle.snp.makeConstraints { (make) in
            make.top.equalTo(15)
            make.leading.equalTo(imageView.snp.trailing).offset(9)
            make.trailing.equalTo(-16)
            make.bottom.equalTo(-15)
        }
        
        return profileView
    }()
    
    let baseView: UIView = {
        let baseView = UIView()
        baseView.backgroundColor = .white
        //FIXME: 임의로 한 값 - 제플린에 정확히 수치 나오면 적용해야함.
        baseView.layer.cornerRadius = 15
        baseView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        baseView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        baseView.layer.shadowOpacity = 1
        baseView.layer.shadowOffset = CGSize(width: 0, height: -2)
        baseView.layer.shadowRadius = 8 / 2
        
        return baseView
    }()
    
    let timeListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 7
        layout.minimumInteritemSpacing = 0
        layout.estimatedItemSize = CGSize(width: 10, height: 34)
        layout.scrollDirection = .horizontal
        let timeListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        timeListCollectionView.contentInset = UIEdgeInsets(top: 16, left: 20, bottom: 12, right: 20)
        timeListCollectionView.backgroundColor = .white
        timeListCollectionView.showsHorizontalScrollIndicator = false
        timeListCollectionView.register(RoundCollectionCell.self, forCellWithReuseIdentifier: String(describing: RoundCollectionCell.self))
        return timeListCollectionView
    }()
    
    let separateLine: UIView = {
        let separateLine = UIView()
        separateLine.frame.size = CGSize(width: Dimens.deviceWidth, height: 1)
        separateLine.backgroundColor = ColorUtils.color242
        return separateLine
    }()
    
    let bookListCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.minimumLineSpacing = 18
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: 130, height: 168 + 132)
        layout.scrollDirection = .horizontal
        let bookListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        bookListCollectionView.contentInset = UIEdgeInsets(top: 16, left: 20, bottom: 0, right: 20)
        bookListCollectionView.backgroundColor = .white
        bookListCollectionView.showsHorizontalScrollIndicator = false
        bookListCollectionView.register(BookCoverCollectionCell.self, forCellWithReuseIdentifier: String(describing: BookCoverCollectionCell.self))
        return bookListCollectionView
    }()
    
    var btnWrite: UIButton = {
        let btnWrite = UIButton(type: .custom)
        btnWrite.backgroundColor = .white
        btnWrite.setImage(#imageLiteral(resourceName: "write"), for: .normal)
        btnWrite.layer.masksToBounds = false
        btnWrite.layer.cornerRadius = 29
        btnWrite.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.05).cgColor
        btnWrite.layer.shadowOpacity = 1
        btnWrite.layer.shadowOffset = CGSize(width: 0, height: 2)
        btnWrite.layer.shadowRadius = 4 / 2
        
        let layer1 = CALayer()
        layer1.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        layer1.shadowOpacity = 1
        layer1.shadowOffset = CGSize(width: 0, height: 4)
        layer1.shadowRadius = 10 / 4
        
        btnWrite.layer.insertSublayer(layer1, at: 1)
        
        return btnWrite
    }()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        naverMapView.mapView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: baseView.frame.height, right: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        // MARK: 현재 위치 설정 - 매니저로 뺴야하는데
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.requestLocation()
        
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: locationManager?.location?.coordinate.latitude ?? 37.5666102, lng: locationManager?.location?.coordinate.longitude ?? 126.9783881))
        cameraUpdate.pivot = CGPoint(x: 0.5, y: 0.3)
        mapView.moveCamera(cameraUpdate)
    }
    
    func bindViewModel() {
        btnWrite.rx.action = viewModel.writeAction()
        
        viewModel.writeData
            .subscribe(onNext: { [unowned self ] value in
                // 다 지우고
                self.markers.forEach { $0.mapView = nil }
                
                // 한방에 들어오네
                for (idx, value) in value.enumerated() {
                    self.markers.append(NMFMarker(position: NMGLatLng(lat: value.location.lat, lng: value.location.lng)))
                    self.markers[idx].iconImage = NMFOverlayImage(image: ImageUtils.getColorBookIcon(value.color))
                    self.markers[idx].mapView = self.naverMapView.mapView
//                    self.markers[idx].isHideCollidedMarkers = true
//                    self.markers[idx].isHideCollidedCaptions = true
                }
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.writeData.bind(to: bookListCollectionView.rx.items(cellIdentifier: String(describing: BookCoverCollectionCell.self), cellType: BookCoverCollectionCell.self)) { (row, element, cell) in
            cell.bookCover.bind(color: element.color, text: element.content)
            cell.lbBookTitle.setTextWithLetterSpacing(text: element.book, letterSpacing: -0.07, lineHeight: 17)
            cell.lbWriter.setTextWithLetterSpacing(text: element.write, letterSpacing: -0.06, lineHeight: 14)
        }.disposed(by: rx.disposeBag)
        
        viewModel.times.bind(to: timeListCollectionView.rx.items(cellIdentifier: String(describing: RoundCollectionCell.self), cellType: RoundCollectionCell.self)) { (row, element, cell) in
            cell.lbRoundText.setTextWithLetterSpacing(text: element, letterSpacing: -0.06, lineHeight: 20)
            
        }.disposed(by: rx.disposeBag)
        
        timeListCollectionView.rx
            .itemSelected
            .do(onNext: { [unowned self] indexPath in
                self.timeListCollectionView.indexPathsForVisibleItems.forEach { indexPath in
                    // 레이어 보더 모두 해제
                    let cell = self.timeListCollectionView.cellForItem(at: indexPath) as? RoundCollectionCell
                    cell?.lbRoundText.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                    cell?.lbRoundText.textColor = ColorUtils.color68
                    cell?.layer.borderWidth = 1
                    cell?.layer.borderColor = ColorUtils.color231.cgColor
                    cell?.backgroundColor = .white
                }
            }).subscribe(onNext: { [unowned self] indexPath in
                let cell = self.timeListCollectionView.cellForItem(at: indexPath) as? RoundCollectionCell
                cell?.lbRoundText.font = UIFont.systemFont(ofSize: 13, weight: .medium)
                cell?.lbRoundText.textColor = .white
                cell?.backgroundColor = ColorUtils.colorTimeSelected
                cell?.layer.borderWidth = 0
            }).disposed(by: rx.disposeBag)
    }
}

extension MainViewController {
    private func setUI() {
        self.view.backgroundColor = .white
        self.view.addSubview(naverMapView)
        self.view.addSubview(profileBaseView)
        self.view.addSubview(baseView)
        self.baseView.addSubview(timeListCollectionView)
        self.baseView.addSubview(separateLine)
        self.baseView.addSubview(bookListCollectionView)
        self.view.addSubview(btnWrite)
        
        //TODO: 스냅킷 데모에서 사용하던데 이유는?
        self.view.setNeedsUpdateConstraints()
        setLayout()
        setNaverMap()
    }
    
    private func setLayout() {
        naverMapView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view.snp.width).multipliedBy(1)
            make.height.equalTo(self.view.snp.height).multipliedBy(1)
            make.centerX.equalTo(self.view.snp.centerX)
            make.centerY.equalTo(self.view.snp.centerY)
        }
        
        profileBaseView.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.width.equalTo(153)
            make.height.equalTo(46)
        }
        
        baseView.snp.makeConstraints { (make) in
            make.height.equalTo(view.snp.width).offset(4)
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        timeListCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(baseView.snp.top)
            make.leading.equalTo(baseView.snp.leading)
            make.trailing.equalTo(baseView.snp.trailing)
            make.height.equalTo(62)
        }
        
        separateLine.snp.makeConstraints { (make) in
            make.top.equalTo(timeListCollectionView.snp.bottom)
            make.leading.equalTo(baseView.snp.leading)
            make.trailing.equalTo(baseView.snp.trailing)
            make.height.equalTo(1)
            make.bottom.equalTo(bookListCollectionView.snp.top)
        }
        
        bookListCollectionView.snp.makeConstraints { (make) in
            make.leading.equalTo(baseView.snp.leading)
            make.trailing.equalTo(baseView.snp.trailing)
            make.bottom.equalTo(baseView.snp.bottom)
        }
        
        btnWrite.snp.makeConstraints { (make) in
            make.width.equalTo(58)
            make.height.equalTo(58)
            make.bottom.equalToSuperview().offset(-24)
            make.trailing.equalToSuperview().offset(-22)
        }
    }
    
    private func setNaverMap() {
        naverMapView.showCompass = false
        naverMapView.showZoomControls = false
        naverMapView.showLocationButton = false
        naverMapView.showScaleBar = false
    }
}

extension MainViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            print("LocationManager didChangeAuthorization denied")
        case .notDetermined:
            print("LocationManager didChangeAuthorization notDetermined")
        case .authorizedWhenInUse:
            print("LocationManager didChangeAuthorization authorizedWhenInUse")
            
            locationManager?.requestLocation()
        case .authorizedAlways:
            print("LocationManager didChangeAuthorization authorizedAlways")

            locationManager?.requestLocation()
        case .restricted:
            print("LocationManager didChangeAuthorization restricted")
        default:
            print("LocationManager didChangeAuthorization")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.forEach { (location) in
            mapView.locationOverlay.location = NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("----------- didFailWithError \(error.localizedDescription)")
        if let error = error as? CLError, error.code == .denied {
            locationManager?.stopMonitoringSignificantLocationChanges()
            return
        }
    }
}

extension MainViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        
        
        let xx = naverMapView.mapView.pickAll(point, withTolerance: 1)
        print("------", xx)
        let tt = sortingMarker(picks: naverMapView.mapView.pickAll(point, withTolerance: 1))
        
        print("-------", tt)
    }
}
private func sortingMarker(picks: [NMFPickable]? ) -> [Any] {
    let sortMarkers = picks?.filter { $0.isKind(of: NMFMarker.self) }
    let count = sortMarkers?.count ?? 0
    var hospitals: [Any] = []

    for idx in 0..<count {
        let tempMarker = sortMarkers?[idx] as? NMFMarker
        guard let userInfo = tempMarker?.userInfo else { return [] }
        var keys = Array(userInfo.keys)
        for idx in 0..<keys.count {
            if let dictKey = keys[idx] as? String {
                hospitals.append(userInfo[dictKey] as Any)
            }
        }

    }
    return hospitals
}
