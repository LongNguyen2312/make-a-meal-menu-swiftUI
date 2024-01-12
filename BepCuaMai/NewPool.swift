//
//  ContentView.swift
//  BepCuaMai
//
//  Created by Long Nguyễn văn on 05/10/2023.
//

import SwiftUI
import Combine

struct Menu: Codable {
  let id: String
  let question: String
  let menu1: String
  let menu2: String
  let menu3: String
  let time_date: String
  let convert_time_date: String
  var selected: Int
  var rate: Int
}

struct MenuResponse: Codable {
  let success: Bool
  let data: [Menu]?
  let error: String?
}

struct NewPool: View {
  @State private var isShowingImageSheet: Bool = false
  @State private var isSelected: Int = 0
  @State private var dataMenu: [Menu] = []
  @State private var isLoading: Bool = false
  @State private var isShowPopUpDetail: Bool = false
  @State private var contentDetail: String = ""
  
  var body: some View {
    NavigationView {
      GeometryReader {geometry in
        VStack {
          HStack {
            Text("Bếp Của Maiii").font(.system(size: 30, weight: .heavy, design: .serif)).foregroundColor(.white)
            Spacer()
            NavigationLink(destination: ContentView()) {
              Circle()
                .frame(width: 50, height: 50)
                .foregroundColor(.black)
                .overlay(
                  Image(systemName: "plus")
                    .font(.system(size: 30))
                    .foregroundColor(.white)
                )
                .overlay(
                  Circle()
                    .stroke(Color.gray, lineWidth: 2)
                )
            }
          }.padding()
          
          ScrollView(.vertical, showsIndicators: false) {
            VStack {
              if isLoading {
                ProgressView().foregroundColor(.white).progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(1.5).padding(.bottom)
              }
              ForEach(dataMenu, id: \.id) { menu in
                let timeOfWeek = convertToDay(menu.convert_time_date) ?? ""
                let date = formatDate(menu.convert_time_date) ?? ""
                let disabled = compareDate(menu.convert_time_date)
                VStack {
                  VStack {
                    HStack {
                      Button (action: {
                        isShowingImageSheet.toggle()
                      }) {
                        Image("avatar").resizable().frame(width: 35, height: 35).cornerRadius(20)
                        VStack {
                          Text("Thanh Maii").foregroundColor(.white)
                          Text(date).foregroundColor(.white).font(.subheadline).italic()
                        }
                      }.padding(.vertical, 25).padding(.horizontal, 23)
                      Spacer()
                      Text(timeOfWeek).padding(.trailing, 20).foregroundColor(.white).font(.system(size: 20, weight: .medium, design: .rounded))
                    }.sheet(isPresented: $isShowingImageSheet) {
                      ProfilePopUp()
                    }
                    
                    Text(menu.question).foregroundColor(Color(red: 0.922, green: 0.756, blue: 0.712)).font(.largeTitle).foregroundColor(.white).accentColor(.white).frame(maxWidth: .infinity, alignment: .leading).padding(.horizontal, 30).padding(.bottom)
                    
                    Spacer()
                    
                    RatingStar(rating: menu.rate, callback: { star in
                      onUpdate(menu.id, star, true)
                    }).padding(.bottom)
                    
                    createButton(value: menu.menu1, type: 1, disabled: disabled, selected: menu.selected == 1, id: menu.id)
                    createButton(value: menu.menu2, type: 2, disabled: disabled, selected: menu.selected == 2, id: menu.id)
                    createButton(value: menu.menu3, type: 3, disabled: disabled, selected: menu.selected == 3, id: menu.id).padding(.bottom)
                    
                  }.frame(maxHeight: .infinity).background(Color(red: 0.816, green: 0.422, blue: 0.314)).cornerRadius(55).padding(.bottom)
                }.frame(height: geometry.size.height * 0.8).padding(.bottom)
                
              }
            }.padding()
          }.onAppear {
            let scrollProxy = UIScrollView.appearance()
            scrollProxy.contentOffset = .zero
            fetchMenus()
          }.refreshable {
            fetchMenus()
          }
        }.background(.black)
      }
    }
  }
  
  func createButton(value: String, type: Int, disabled: Bool, selected: Bool, id: String) -> some View {
    Button(action: {
      contentDetail = value
      isShowPopUpDetail.toggle()
    }) {
      HStack {
        Button (action: {
          onUpdate(id, type, false)
        }) {
          Image(systemName: selected ? "heart.circle" : "circle").font(.system(size: 20)).foregroundColor(Color(hue: 0.035, saturation: 0.063, brightness: 0.795)).padding(.leading, 25)
        }.disabled(disabled)
        Text(value).foregroundColor(Color(hue: 0.035, saturation: 0.063, brightness: 0.795)).font(.system(size: 20)).foregroundColor(.white).accentColor(.white).padding(.horizontal).lineLimit(1)
        Spacer()
      }.frame(maxWidth: .infinity, maxHeight: 80).background(.black).cornerRadius(35).padding(.horizontal)
    }.sheet(isPresented: $isShowPopUpDetail) {
      PopupDetail(content: $contentDetail)
    }
  }
  
  func fetchMenus() {
    isLoading = true
    guard let url = URL(string: "https://dc2a-118-70-175-236.ngrok-free.app/menu") else { return }
    
    URLSession.shared.dataTask(with: url) { (data, response, error) in
      guard let data = data else { return }
      do {
        let res = try JSONDecoder().decode(MenuResponse.self, from: data)
        DispatchQueue.main.async {
          isLoading = false
          self.dataMenu = res.data ?? []
        }
      } catch {
        isLoading = false
        print(String(describing: error))
      }
    }.resume()
  }
  
  func onUpdate(_ id: String, _ number: Int, _ isStar: Bool?) {
    guard let url = URL(string: "https://dc2a-118-70-175-236.ngrok-free.app/menu/update/" + id) else { return }
    var request = URLRequest(url: url)
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "PATCH"
    
    let data = isStar == true ? ["rate": number] : ["selected": number]
    
    let jsonData = try? JSONSerialization.data(withJSONObject: data)
    
    request.httpBody = jsonData
    
    URLSession.shared.uploadTask(with: request, from: jsonData) { (data, response, error) in
      guard let data = data else { return }
      do {
        let res = try JSONDecoder().decode(MenuResponse.self, from: data)
        if(res.success == true) {
          if let index = dataMenu.firstIndex(where: { $0.id == id }) {
            DispatchQueue.main.async {
              if (isStar == true) {
                dataMenu[index].rate = number
              } else {
                dataMenu[index].selected = number
              }
            }
          }
        }
      } catch {
        print(String(describing: error))
      }
    }.resume()
  }
  
  func convertToDay(_ dateString: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    
    if let date = dateFormatter.date(from: dateString) {
      let calendar = Calendar.current
      let weekday = calendar.component(.weekday, from: date)
      
      let weekdayNames = ["Chủ nhật", "Thứ 2", "Thứ 3", "thứ 4", "thứ 5", "Thứ 6", "Thứ 7"]
      
      guard (1...7).contains(weekday) else {
        return nil
      }
      
      return weekdayNames[weekday - 1]
    } else {
      return "Thứ 😀"
    }
  }
  
  func formatDate(_ param: String) -> String? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    if let date = dateFormatter.date(from: param) {
      let outputFormatter = DateFormatter()
      outputFormatter.dateFormat = "yyyy-MM-dd"
      let formattedDate = outputFormatter.string(from: date)
      
      return formattedDate
    } else {
      return ""
    }
  }
  
  func compareDate(_ param: String) -> Bool {
    let currentDate = Calendar.current.startOfDay(for: Date())
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    if let otherDate = dateFormatter.date(from: param) {
      let currentCalendar = Calendar.current
      let currentDateComponents = currentCalendar.dateComponents([.year, .month, .day], from: currentDate)
      let otherDateComponents = currentCalendar.dateComponents([.year, .month, .day], from: otherDate)
      if (currentDateComponents == otherDateComponents) {
        return false
      } else {
        return true
      }
    } else {
      return false
    }
  }
  
}

struct NewPool_Previews: PreviewProvider {
  static var previews: some View {
    NewPool()
  }
}
