//
//  ForecastViewCell.swift
//  SecondWeather
//
//  Created by Atif Khan  on 07/07/2026.
//

import UIKit

class ForecastViewCell: UICollectionViewCell {
    static let identifier: String = "ForecastViewCell"
    var weatherimage:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "sun.rain.fill")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .clear
        return imageView
    }()
    var urlImage:String = ""

    var daylb:UILabel = {
        let UIlabel = UILabel()
        UIlabel.textAlignment = .center
        UIlabel.font = .boldSystemFont(ofSize: 12)
        UIlabel.textColor = .black
        
       
        UIlabel.translatesAutoresizingMaskIntoConstraints = false
        return UIlabel
    }()
    
    var templb:UILabel = {
        let UIlabel = UILabel()
        UIlabel.textAlignment = .center
        UIlabel.font = UIFont.preferredFont(forTextStyle: .title3)
        UIlabel.textColor = .black
        UIlabel.font = .boldSystemFont(ofSize: 20)
        UIlabel.translatesAutoresizingMaskIntoConstraints = false
        return UIlabel
    }()
    
    let dateFormatterGet = DateFormatter()
   

    let dateFormatterPrint = DateFormatter()
   
    override init(frame: CGRect){
        super.init(frame: frame)
        setupUI()
        
        
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setupUI(){
        contentView.backgroundColor = .clear
        contentView.addSubview(daylb)
        contentView.addSubview(templb)
        loadImage(from: urlImage, into: weatherimage)
        contentView.addSubview(weatherimage)
        NSLayoutConstraint.activate([
            daylb.centerXAnchor.constraint(equalTo: centerXAnchor),
            daylb.topAnchor.constraint(equalTo: topAnchor,constant: 3),
            weatherimage.centerXAnchor.constraint(equalTo: centerXAnchor),
            weatherimage.centerYAnchor.constraint(equalTo: centerYAnchor),
            templb.centerXAnchor.constraint(equalTo: centerXAnchor),
            templb.bottomAnchor.constraint(equalTo: weatherimage.bottomAnchor,constant: 15)
           
        ])
        
        
    }
    func config(with weather:WeatherDayModel ){
        self.daylb.text = weather.day
        self.templb.text = weather.tempC
        self.urlImage = weather.icon

        // Source - https://stackoverflow.com/a/35700409
        // Posted by LorenzOliveto, modified by community. See post 'Timeline' for change history
        // Retrieved 2026-07-08, License - CC BY-SA 4.0

        dateFormatterGet.dateFormat = "yyyy-MM-dd"
        dateFormatterPrint.dateFormat = "EEE"
        var currentDate = dateFormatterGet.string(from: Date())
        
        if let days = dateFormatterGet.date(from: "\(weather.day)"){
            self.daylb.text = dateFormatterPrint.string(from: days)
            if currentDate == dateFormatterGet.string(from: days) {
                self.daylb.text = "Today"
            }
        }
        

        setupUI()
    }
    
    
    func loadImage(from urlString: String, into imageView: UIImageView) {
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            
            guard let data = data,
                  let image = UIImage(data: data) else { return }
            
            DispatchQueue.main.async {
                imageView.image = image
            }
            
        }.resume()
    }

}
