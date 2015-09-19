//
//  WSWeatherDetailsViewController.swift
//  Weather_Sample
//
//  Created by Uday Patial on 9/18/15.
//  Copyright © 2015 Uday Patial. All rights reserved.
//

import UIKit
import CoreLocation
import Charts



class WSWeatherDetailsViewController: WSBaseViewController,ChartViewDelegate {

    var location = CLLocation()
    var city = ""
    var weatherServiceType = WeatherServiceType.WeatherServiceTypeByCity
    
    let kGraphxAxisVals = 24
    let kxAxisIntervals = 3
    
    @IBOutlet weak var imgWeatherCondition: UIImageView!
    @IBOutlet weak var lblCityName: UILabel!
    @IBOutlet weak var lblTemperature: UILabel!
    @IBOutlet weak var chartView: LineChartView!
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchWeatherDetails()
        setupGraph()
        // Do any additional setup after loading the view.
    }
    
    //MARK: Weather API methods
    
    ///fetches weather details as per weather service type - city or location
    private func fetchWeatherDetails() {
        showLoading()
        //based on the method the corresponding web service class is assigned from the sql web service factory
        let request = WSFetchWeatherInfoRequest(method: .ETWebServiceMethodGetWeatherInfo)
        request.weatherServiceType = weatherServiceType
        request.city = city
        request.latitude = location.coordinate.latitude
        request.longitude = location.coordinate.longitude
        WSWeatherDataManager.sharedInstance().requestData(request) { (response, error) -> Void in
            self.hideLoading()
            let weatherResponse = response! as! WSFetchWeatherInfoResponse
            if weatherResponse.responseStatus == .ETBaseResponseStatusSuccess {
                self.setupUI(weatherResponse.weatherInfoResponse)
                self.getWeatherForecast()
            }
            else {
                WSUIUtils.showAlertView(NSLocalizedString("Could not fetch weather data. Please try again later", comment: ""), title: NSLocalizedString("Error ", comment: ""))
            }
        }
    }
    
    private func getWeatherForecast() {
        showLoading()
        //we can use WSFetchWeatherInfoRequest also. This is just to show that we can have different request/response classes for different services
        let request = WSGetWeatherForecastRequest(method: .ETWebServiceMethodGetWeatherForecast)
        request.weatherServiceType = weatherServiceType
        request.city = city
        request.latitude = location.coordinate.latitude
        request.longitude = location.coordinate.longitude
        WSWeatherDataManager.sharedInstance().requestData(request) { (response, error) -> Void in
            self.hideLoading()
            let forecastResponse = response! as! WSGetWeatherForecastResponse
            if forecastResponse.responseStatus == .ETBaseResponseStatusSuccess {
                self.setGraphData(forecastResponse.forecastArray)
            }
            else {
                WSUIUtils.showAlertView(NSLocalizedString("Could not fetch weather forecast data. Please try again later", comment: ""), title: NSLocalizedString("Error ", comment: ""))
            }
        }
    }
    
    //MARK: Graph methods
    
    private func setupGraph() {
        //standard graph attributes
        chartView.delegate = self;
        
        chartView.descriptionText = "";
        chartView.noDataTextDescription = NSLocalizedString("You need to provide data for the chart.", comment: "")
        
        chartView.drawGridBackgroundEnabled = false;
        chartView.highlightEnabled = true;
        chartView.dragEnabled = true;
        chartView.setScaleEnabled(true)
        chartView.pinchZoomEnabled = false;
        
        chartView.legend.position = .RightOfChart;
        //setDataCount(21, range: 10)
    }
    
    func setGraphData(forecastArray: [WSWeatherInfo]) {
        //get the next three days data arrays from forecastArray
        let currentDate = NSDate()
        let currentDateString = NSDate.stringFromDate(currentDate, formatter: "dd")
        let day1Int = Int(currentDateString!)!
        
        //filter the next 3 days data arrays
        let day1Array = forecastArray.filter{ $0.dateString == String(day1Int + 1) }
        let day2Array = forecastArray.filter{ $0.dateString == String(day1Int + 2) }
        let day3Array = forecastArray.filter{ $0.dateString == String(day1Int + 3) }
        
        
        var xVals = [String]()
        var i = 0
        //setting the x axis of the graph i.e 24 hours format
        repeat {
            xVals.append(String(i))
            i++
        }while(i <= kGraphxAxisVals)
        let colors = [ChartColorTemplates.vordiplom()[0], ChartColorTemplates.vordiplom()[1], ChartColorTemplates.vordiplom()[2]]
        var dataSets = [LineChartDataSet]()
        
        //create the data set for the three lines
            dataSets.append(getLineChartDataSet(0, dataArray: day1Array, colors: colors))
            dataSets.append(getLineChartDataSet(1, dataArray: day2Array, colors: colors))
        dataSets.append(getLineChartDataSet(2, dataArray: day3Array, colors: colors))
        
        dataSets[0].lineDashLengths = [5.0, 5.0]
        dataSets[0].colors = ChartColorTemplates.vordiplom()
        dataSets[0].circleColors = ChartColorTemplates.vordiplom()
        
        let data = LineChartData(xVals: xVals, dataSets: dataSets)
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 7.0))
        chartView.data = data
    }
    
    ///gets the plot points for each day
    func getLineChartDataSet(z:Int, dataArray:[WSWeatherInfo], colors:[UIColor]) -> LineChartDataSet {
        var values = [ChartDataEntry]()
        //since the service returns the forecast data in intervals of 3 hours
        for var i = 0; i < kGraphxAxisVals; i += kxAxisIntervals {
            var day1ArrayFilter = dataArray.filter{ $0.timeString == String(i)}
            if day1ArrayFilter.count > 0 {
                let weatherInfo = day1ArrayFilter[0]
                values.append(ChartDataEntry(value: Double(weatherInfo.temp), xIndex: i))
            }
        }
        
        let d = LineChartDataSet(yVals: values, label: "Day \(z+1)")
        d.lineWidth = 2.5
        d.circleRadius = 4.0
        let color = colors[z % colors.count]
        d.setColor(color)
        d.setCircleColor(color)
        return d
    }
    
    //MARK: Helper methods

    ///populate the UI with weather info object
    func setupUI(weatherInfo: WSWeatherInfo) {
        lblCityName.text = weatherInfo.locationName
        imgWeatherCondition.image = UIImage(named: weatherInfo.weatherConditions.getImageName()!)
        lblTemperature.text = String(weatherInfo.temp)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
