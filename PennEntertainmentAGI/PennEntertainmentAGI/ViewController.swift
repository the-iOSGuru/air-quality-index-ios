//
//  ViewController.swift
//  PennEntertainmentAGI
//
//  Created by Buddy Rich on 7/11/24.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var activityIndicator: UIActivityIndicatorView?
    var shimmerViews: [UIView] = []
    var token: String?
    var shouldFetchData = true
    var o3ForecastData: [O3] = []
    var pm10ForecastData: [O3] = []
    var pm25ForecastData: [O3] = []
    var filteredData: [O3] = []
    
    var originalLatText: String?
    var originalLongText: String?
    
    let networkManager = NetworkManager()
    
    
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var latitudeText: UILabel!
    @IBOutlet weak var longitudeText: UILabel!
    @IBOutlet weak var currentAQILabel: UILabel!
    @IBOutlet weak var currentAQIInstructionsLabel: UILabel!
    @IBOutlet weak var cityStateLabel: UILabel!
    @IBOutlet weak var stationLabel: UILabel!
    @IBOutlet weak var latTextField: UITextField!
    @IBOutlet weak var longTextField: UITextField!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupActivityIndicator()
        setupLocationManager()
        setupCollectionView()
        
        shimmerViews = [updateButton, latitudeText, longitudeText, currentAQILabel, currentAQIInstructionsLabel, resetButton]
        
        guard let aqiToken = Bundle.main.infoDictionary?["AQI_TOKEN"] as? String else {
            showAlert(message: "API token is missing. Please check your configuration.")
            return
        }
        
        self.token = aqiToken
        startLoading()
        LocationManager.shared.requestLocation()
    }
    
    func setupUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tapGesture)
        
        latTextField.delegate = self
        longTextField.delegate = self
        
        addShimmerEffect(to: shimmerViews)
        
        segmentedControl.selectedSegmentIndex = 0
        updateFilteredData()
        
    }
    
    func addShimmerEffect(to views: [UIView]) {
        views.forEach { view in
            let shimmer = ShimmerView(frame: view.bounds)
            shimmer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(shimmer)
        }
    }
    
    func removeShimmerEffect(from views: [UIView]) {
        views.forEach { view in
            view.subviews.filter { $0 is ShimmerView }.forEach { $0.removeFromSuperview() }
        }
    }
    
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.color = .gray
        activityIndicator?.center = self.view.center
        
        if let activityIndicator = activityIndicator {
            self.view.addSubview(activityIndicator)
        }
    }
    
    func setupLocationManager() {
        LocationManager.shared.delegate = self
    }
    
    func setupCollectionView() {
        let nib = UINib(nibName: "PastPresentCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "PastPresentCollectionViewCell")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
    }
    
    func updateFilteredData() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            filteredData = o3ForecastData
        case 1:
            filteredData = pm10ForecastData
        case 2:
            filteredData = pm25ForecastData
        default:
            break
        }
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PastPresentCollectionViewCell", for: indexPath) as! PastPresentCollectionViewCell
        let forecast = filteredData[indexPath.item]
        cell.configure(with: forecast)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 165, height: 165)
    }
    
    func startLoading() {
        activityIndicator?.startAnimating()
        self.view.isUserInteractionEnabled = false
        addShimmerEffect(to: shimmerViews)
    }
    
    func stopLoading() {
        activityIndicator?.stopAnimating()
        self.view.isUserInteractionEnabled = true
        removeShimmerEffect(from: shimmerViews)
    }
    
    func fetchData(lat: Double, lng: Double) {
        guard let token = self.token else {
            showAlert(message: "API token is missing. Please check your configuration.")
            return
        }
        
        Task {
            do {
                let airQualityData = try await networkManager.fetchAirQualityData(lat: lat, lng: lng, token: token)
                updateUI(with: airQualityData)
            } catch {
                handleNetworkError(error)
            }
        }
    }
    
    func handleNetworkError(_ error: Error) {
        DispatchQueue.main.async {
            self.stopLoading()
            self.showAlert(message: "An error occurred: \(error.localizedDescription)")
        }
    }
    
    func updateUI(with airQualityData: GeoData) {
        DispatchQueue.main.async { [self] in
            stopLoading()
            
            // If not hidden gives strange black bar for space it would take during the shimmer effect.
            segmentedControl.isHidden = false
            latTextField.isHidden = false
            longTextField.isHidden = false
            
            let cityStateAttributedText = makeBoldText("Current Location: ", regularText: "\(airQualityData.data.city.name) \(airQualityData.data.city.location)")
            cityStateLabel.attributedText = cityStateAttributedText
            
            let stationAttributedText = makeBoldText("Station name: ", regularText: "\(airQualityData.data.attributions.first?.name ?? "")")
            stationLabel.attributedText = stationAttributedText
            
            latTextField.text = String(airQualityData.data.city.geo.first ?? 0)
            longTextField.text = String(airQualityData.data.city.geo.last ?? 0)
            
            let updateButtonAttributedTitle = makeBoldText("Update", regularText: "")
            updateButton.setAttributedTitle(updateButtonAttributedTitle, for: .normal)
            
            resetButton.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
            
            let aqiKeyInstructions = "Green - Good, Yellow - Moderate, Orange - Unhealthy for Sensitive Groups, Red - Unsafe"
            let aqiKeyInstructionsAttributedText = colorizeText(with: aqiKeyInstructions)
            currentAQIInstructionsLabel.attributedText = aqiKeyInstructionsAttributedText
            
            originalLatText = latTextField.text
            originalLongText = longTextField.text
            
            let currentAQIAttributedText = makeBoldText("Current AQI: ", regularText: "")
            let coloredAQIText = makeColoredAQIText(airQualityData.data.aqi)
            let fullAttributedText = NSMutableAttributedString(attributedString: currentAQIAttributedText)
            fullAttributedText.append(coloredAQIText)

            currentAQILabel.attributedText = fullAttributedText
            
            o3ForecastData = filterForecastData(airQualityData.data.forecast.daily.o3)
            pm10ForecastData = filterForecastData(airQualityData.data.forecast.daily.pm10)
            pm25ForecastData = filterForecastData(airQualityData.data.forecast.daily.pm25)
            updateFilteredData()
        }
    }
    
  
    
    func filterForecastData(_ forecastData: [O3]) -> [O3] {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let oneDayBefore = calendar.date(byAdding: .day, value: -2, to: currentDate)!
        let oneDayAfter = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let displayDateFormatter = DateFormatter()
        displayDateFormatter.dateFormat = "MMMM dd, yyyy" // Change date format to "July 15, 2024"
        
        let dayOfWeekFormatter = DateFormatter()
        dayOfWeekFormatter.dateFormat = "EEEE"
        
        return forecastData.compactMap {
            guard let forecastDate = dateFormatter.date(from: $0.day) else { return nil }
            if forecastDate >= oneDayBefore && forecastDate <= oneDayAfter {
                $0.day = displayDateFormatter.string(from: forecastDate)
                $0.dayOfWeek = dayOfWeekFormatter.string(from: forecastDate)
                return $0
            }
            return nil
        }
    }
    
    @objc func handleTap() {
        if latTextField.text?.isEmpty ?? false {
            latTextField.text = originalLatText
        }
        if longTextField.text?.isEmpty ?? false {
            longTextField.text = originalLongText
        }
        view.endEditing(true)
    }
    
    func showAlert(message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == latTextField {
            originalLatText = textField.text
        } else if textField == longTextField {
            originalLongText = textField.text
        }
        textField.text = ""
    }
    
    func roundToDecimalPlace(_ value: Double, _ decimalPlaces: Int) -> Double {
        let multiplier = pow(10.0, Double(decimalPlaces))
        return (value * multiplier).rounded() / multiplier
    }
    
    // MARK: IBACTIONS
    @IBAction func updateLatLong(_ sender: Any) {
        if let latText = latTextField.text, let longText = longTextField.text, let latitude = Double(latText), let longitude = Double(longText) {
            fetchData(lat: roundToDecimalPlace(latitude, 1), lng: roundToDecimalPlace(longitude, 1))
        } else {
            showAlert(message: "Please enter a number with the correct decimal or whole number. For example 12 or 12.4")
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        updateFilteredData()
    }
    
    @IBAction func resetLatLong (_ sender: Any) {
        shouldFetchData = true
        LocationManager.shared.requestLocation()
    }
}

// MARK: LOCATION MANAGER DELEGATE
extension ViewController: LocationManagerDelegate {
    func didFetchLocation(_ latitude: Double, _ longitude: Double) {
        if shouldFetchData {
            shouldFetchData.toggle()
            fetchData(lat: roundToDecimalPlace(latitude, 1), lng: roundToDecimalPlace(longitude, 1))
        }
    }
    
    func didFailWithError(_ error: Error) {
        print("Location manager failed with error: \(error.localizedDescription)")
    }
}

// MARK: EXTENSION COLLECTIONVIEW CELL
extension PastPresentCollectionViewCell {
    func configure(with forecast: O3) {
        dayOfWeekLabel.text = forecast.dayOfWeek
        dateLabel.text = forecast.day
        avgLabel.text = "Avg AQI: \(forecast.avg)"
        maxLabel.text = "Max AQI: \(forecast.max)"
        minLabel.text = "Min AQI: \(forecast.min)"
    }
}
