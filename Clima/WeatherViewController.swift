
import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "f81a8edad7ce8f9f240d27efbebf2977"
    
    /***Get your own App ID at https://openweathermap.org/appid ****/
    


    
    let locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
 
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //- Networking
    /***************************************************************/
    
    //getWeatherData Method
    
    func getWeatherData(url: String, parameters: [String : String]){
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                
                let weatherJSON : JSON = JSON(response.result.value!)
                
                self.updateWeatherData(json: weatherJSON)
                
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    
    
    
    // - JSON Parsing
    /***************************************************************/
   
    
    //updateWeatherData Method
    
    func updateWeatherData(json: JSON){
        
      
        if let tempResult = json["main"]["temp"].double{
            
        weatherDataModel.temperature = Int(tempResult - 273.15)
        
        weatherDataModel.city = json["name"].stringValue
        
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
        
        updateUIWithWeatherData()
        
        } else {
            cityLabel.text = "Weather Unavailable"
        }
    }
    
    
    
    // - UI Updates
    /***************************************************************/
    
    
    //updateUIWithWeatherData Method
    
    func updateUIWithWeatherData(){
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)°C"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
    }
    
    
    
    

    //didUpdateLocations Method
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            
            print("Logitude = \(location.coordinate.longitude), Latitude = \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
            
        }
    }
    
    
    
    //didFailWithError Method
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }

    
    

    

    
    
    //userEnteredANewCityName Delegate Method
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }

    
    //PrepareForSegue Method
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
}



