//
//  PoilabsPositioning.swift
//  PoilabsPositioning
//
//  Created by Emre Kuru on 13.01.2022.
//

import Foundation
import CoreLocation

@objc
public protocol PoilabsPositioningDelegate {
    @objc func poilabsPositioning(didStatusChange status: PLPStatus, reason: PLPLocationStatusReason)
    @objc func poilabsPositioning(didFindBeacon uuid: String, major: String, minor: String)
    @objc func poilabsPositioning(didFail error: PoilabsPositioningError)
    @objc func poilabsPositioning(didUpdateLocation location: CLLocationCoordinate2D, floorLevel: Int, accuracy: Double, placeId: String)
    @objc func poilabsPositioning(didUpdateHeading heading: CLHeading)
    @objc func poilabsPositioningDidStart()
    @objc func poilabsPositioning(didThresholdChange threshold: Int)
    @objc func poilabsPositioning(didUpdateLocation location: CLLocation, placeId: String)
    @objc func poilabsPositioning(didUpdate modeInfo: PLPositioningModeInfo)
}

class PLPHeading: CLHeading {
    var _trueHeading: CLLocationDirection?
    var _magneticHeading: CLLocationDirection?
    var _headingAccuracy: CLLocationDirection?
    var _x: CLHeadingComponentValue?
    var _y: CLHeadingComponentValue?
    var _z: CLHeadingComponentValue?
    var _timestamp: Date?
    
    init(heading: CLHeading) {
        super.init()
        self._trueHeading = heading.trueHeading
        self._magneticHeading = heading.magneticHeading
        self._headingAccuracy = heading.headingAccuracy
        self._x = heading.x
        self._y = heading.y
        self._z = heading.z
        self._timestamp = heading.timestamp
    }
    
    override var trueHeading: CLLocationDirection {
        get {
            return fixHeadingDegree(heading: (_trueHeading ?? 0.0) - PLPPDRConstants.mapRotateAngle)
        }
    }
    
    override var magneticHeading: CLLocationDirection {
        get {
            return _magneticHeading ?? 0.0
        }
    }
    
    override var headingAccuracy: CLLocationDirection {
        get {
            return _headingAccuracy ?? 0.0
        }
    }
    
    override var x: CLHeadingComponentValue {
        get {
            return _x ?? 0.0
        }
    }
    
    override var y: CLHeadingComponentValue {
        get {
            return _y ?? 0.0
        }
    }
    
    override var z: CLHeadingComponentValue {
        get {
            return _z ?? 0.0
        }
    }
    
    override var timestamp: Date {
        get {
            return Date()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func fixHeadingDegree(heading: Double) -> Double {
        var fixedHeading = heading
        if fixedHeading >= 360 {
            fixedHeading -= 360
        }
        if fixedHeading <= 0 {
            fixedHeading += 360
        }
        return fixedHeading
    }
}

@objc
public class PLPositioning: NSObject {
    
    private var timer: Timer?
    private var lastLocation: CLLocationCoordinate2D? = nil
    private var currentFloorLevel: Int? = nil
    private var accuracy = 3.0
    
    private var config: PLPConfig!
    private var beaconLocationManager: PLPBeaconPositionFinder!
    private var pdrManager: PLPPDRManager!
    private var indoorPositioning: PLPIndoorPositioning!
    @objc public var delegate: PoilabsPositioningDelegate?
    
    private var locationManager: PLPLocationManager?
    
    private var bluetoohStatus: Bool = true
    
    private var positioningMode: PLPositioningMode = .edge
    
    @objc
    public init(config: PLPConfig) {
        super.init()
        self.config = config
        indoorPositioning = PLPIndoorPositioning(scanInvertal: config.scanInterval, multilateration: config.multilateration)
        pdrManager = PLPPDRManager()
        PLPRssiThresholdCalculator.shared.delegate = self
    }
    
    @objc public func setMapRotateAngle(mapRotateAngle: Double) {
        PLPPDRConstants.mapRotateAngle = mapRotateAngle
    }
    
    @objc public func setConversionFactor(conversionFactor: Double) {
        PLPPDRConstants.conversionFactor = conversionFactor
    }
    
    @objc public func setWeinbergConstant(weinberg: Double) {
        PLPPDRConstants.PLPStep.weinberg = weinberg
    }
    
    @objc
    public func startPoilabsPositioning() {
        if beaconLocationManager == nil {
            beaconLocationManager = PLPBeaconPositionFinder(config: config, indoorPositioning: indoorPositioning)
        }
        beaconLocationManager.delegate = self
        delegate?.poilabsPositioning(didStatusChange: .waitingForLocation, reason: .noReason)
        beaconLocationManager.startBeaconPositioning()
        self.startTimer()

        pdrManager.delegate = self
    }
    
    @objc public func startPoilabsOutdoorPositioning() {
        locationManager = PLPLocationManager(config: self.config)
        locationManager?.delegate = self
        locationManager?.startLocationUpdates()
    }
    
    @objc public func startHybridPositioning() {
        if beaconLocationManager == nil {
            beaconLocationManager = PLPBeaconPositionFinder(config: config, indoorPositioning: indoorPositioning)
        }
        beaconLocationManager.delegate = self
        delegate?.poilabsPositioning(didStatusChange: .waitingForLocation, reason: .noReason)
        beaconLocationManager.startHybridPositioning()
        self.startTimer()

        pdrManager.delegate = self
    }
    
    @objc public func stopPoilabsOutdoorPositioning() {
        locationManager?.stopLocationUpdates()
    }
    
    @objc public func getLocationStatus() -> Bool {
        return beaconLocationManager.getLocationManagerStatus()
    }
    
    @objc public func getBluetoothStatus() -> Bool {
        return self.bluetoohStatus
    }
    
    @objc public func startPoilabsPositioning(with beaconList: [PLPBeaconNode]) {
        self.config.beaconList = beaconList
    }
    
    @objc
    public func stopPoilabsPositioning() {
        self.stopTimer()
        beaconLocationManager.stopBeaconPositioning()
        pdrManager.stopPDR()
    }
    
    @objc
    public func closeAllActions() {
        beaconLocationManager.closeBeaconPositioning()
        beaconLocationManager = nil
    }
    
}

extension PLPositioning {
    private func startTimer() {
        let locationUpdateInterval = self.config.locationUpdateInterval
        timer = Timer.scheduledTimer(timeInterval: locationUpdateInterval*5, target: self, selector: #selector(tickOnlocationUpdateInterval), userInfo: nil, repeats: false)
    }
    
    private func stopTimer() {
        PoilabsPositioningUtils.logDebugInformations(log: "Timer stoped", priority: 10)
        timer?.invalidate()
    }
    
    @objc func tickOnlocationUpdateInterval() {
        if lastLocation == nil {
            delegate?.poilabsPositioning(didFail: .beaconNotFound)
            delegate?.poilabsPositioning(didStatusChange: .locationNotFound, reason: .beaconNotFound)
        }
        stopTimer()
    }
}

extension PLPositioning: PLPLocationManagerDelegate {
    func locationManager(positioningModeDidChange mode: PLPositioningMode) {
        
    }
    
    func locationManager(didUpdatePositioningModeInfo modeInfo: PLPositioningModeInfo) {
        
    }
    
    func locationManager(didChangeAuthorization status: CLAuthorizationStatus) {
        
    }
    
    func locationManager(didFail error: PoilabsPositioningError) {
        
    }
    
    func locationManager(didFound beacons: [PLPBeacon]) {
        
    }
    
    func locationManager(didUpdateHeading newHeading: CLHeading) {
        delegate?.poilabsPositioning(didUpdateHeading: newHeading)
    }
    
    func locationManagerDidStartRanging() {
        
    }
    
    func locationManager(didUpdateLocation location: CLLocation) {
        delegate?.poilabsPositioning(didUpdateLocation: location, placeId: "")
    }
    
    
}

extension PLPositioning: PLPBeaconPositionFinderDelegate {
    func beaconPositionFinder(didUpdate positioningModeInfo: PLPositioningModeInfo) {
        delegate?.poilabsPositioning(didUpdate: positioningModeInfo)
    }
    
    func beaconPositionFinder(didUpdateLocation location: CLLocation) {
        self.positioningMode = .outdoor
        delegate?.poilabsPositioning(didUpdateLocation: location, placeId: "")
        pdrManager.stopPDR()
    }
    
    func beaconPositionFinder(didFindLocation location: PLPLocation, accuracy: Double) {
        if self.positioningMode == .outdoor {
            pdrManager.restartPDR()
        }
        self.positioningMode = .indoor
        let locationCoordinates = location.getLocation()
        self.accuracy = accuracy
        self.lastLocation = locationCoordinates
        self.currentFloorLevel = location.floorLevel
        guard let floorLevel = self.currentFloorLevel else { return }
        let placeId = PLPGeoJSONMapManager.shared.getPlaceId(for: location.getLocation()) ?? ""
        delegate?.poilabsPositioning(didUpdateLocation: locationCoordinates, floorLevel: floorLevel, accuracy: accuracy, placeId: placeId)
        pdrManager.currentFloorLevel = location.floorLevel
        pdrManager.startPDR(startCoordinate: locationCoordinates)
        indoorPositioning.setLastPdrLocation(coordinates: locationCoordinates)
    }
    
    func beaconPositionFinderDidStart() {
        self.bluetoohStatus = true
        delegate?.poilabsPositioningDidStart()
    }
    
    func beaconPositionFinder(didFindBeacon uuid: String, major: String, minor: String) {
        delegate?.poilabsPositioning(didFindBeacon: uuid, major: major, minor: minor)
    }
    
    func beaconPositionFinder(didFindHeading heading: CLHeading) {
        //let heading = fixHeadingDegree(heading: heading.trueHeading - config.mapRotateAngle)
        delegate?.poilabsPositioning(didUpdateHeading: PLPHeading(heading: heading))
    }
    
    func beaconPositionFinder(didFailWithError error: PoilabsPositioningError) {
        switch error {
        case .emptyList:
            delegate?.poilabsPositioning(didStatusChange: .locationNotFound, reason: .emptyList)
        case .invalidUUID:
            delegate?.poilabsPositioning(didStatusChange: .locationNotFound, reason: .invalidUUID)
        case .didFailWithError:
            delegate?.poilabsPositioning(didStatusChange: .locationNotFound, reason: .noReason)
        case .monitoringDidFailFor:
            delegate?.poilabsPositioning(didStatusChange: .locationNotFound, reason: .noReason)
        case .didFailRangingFor:
            delegate?.poilabsPositioning(didStatusChange: .locationNotFound, reason: .noReason)
        case .timeIntervalInvalid:
            delegate?.poilabsPositioning(didStatusChange: .locationNotFound, reason: .noReason)
        case .beaconNotFound:
            PoilabsPositioningUtils.logDebugInformations(log: "beacon not found", priority: 20)
        case .bluetoothNotAvaible:
            self.bluetoohStatus = false
            delegate?.poilabsPositioning(didFail: .bluetoothNotAvaible)
            delegate?.poilabsPositioning(didStatusChange: .locationNotFound, reason: .missingPermission)
        case .locationNotAvaible:
            delegate?.poilabsPositioning(didFail: .locationNotAvaible)
            delegate?.poilabsPositioning(didStatusChange: .locationNotFound, reason: .missingPermission)
        }
    }
}


extension PLPositioning: PLPPDRManagerDelegate {
    func plpPdrManagerStuck() {
        indoorPositioning.forceToResetAfterStuck()
    }
    
    func plpPdrManager(newLocationCalculated location: CLLocationCoordinate2D) {
        if PLPGeoJSONMapManager.shared.walkways.isEmpty {
            return
        }
        self.accuracy += 0.1
        guard let floorLevel = self.currentFloorLevel else { return }
        let placeId = PLPGeoJSONMapManager.shared.getPlaceId(for: location) ?? ""
        delegate?.poilabsPositioning(didUpdateLocation: location, floorLevel: floorLevel, accuracy: self.accuracy, placeId: placeId)
        self.lastLocation = location
        indoorPositioning.setLastPdrLocation(coordinates: location)
    }
}

extension PLPositioning: PLPRssiThresholdCalculatorDelegate {
    func rssiThresholdCalculator(didThresholdChange threshold: Int) {
        self.delegate?.poilabsPositioning(didThresholdChange: threshold)
    }
}
