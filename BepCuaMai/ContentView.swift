//
//  ContentView.swift
//  BepCuaMai
//
//  Created by Long Nguyễn văn on 05/10/2023.
//

import SwiftUI
import Combine

struct ContentView: View {
    @State private var content: String = ""
    @State private var menu1: String = ""
    @State private var menu2: String = ""
    @State private var menu3: String = ""
    @State public var isShowingMenu1: Bool = false
    @State public var isShowingMenu2: Bool = false
    @State public var isShowingMenu3: Bool = false
    @State public var isShowingImageSheet: Bool = false
    @State public var isOption: NSNumber = 1
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false
    @State private var errorMessage = ""
    @State private var isLoading: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                Text("Create menu").font(.system(size: 30, weight: .heavy, design: .serif)).foregroundColor(.white)
                Spacer()
                Button(action: {
                    dismiss()
                }) {
                    Circle().frame(width: 50, height: 50).foregroundColor(.black).overlay(
                        Image(systemName: "multiply")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    ).overlay(
                        Circle()
                            .stroke(Color.gray, lineWidth: 2)
                    )
                }
            }.padding()
            
            VStack {
                HStack {
                    Button (action: {
                        isShowingImageSheet.toggle()
                    }) {
                        Image("avatar").resizable().frame(width: 35, height: 35).cornerRadius(20)
                        Text("Thanh Maii").foregroundColor(.white)
                    }.padding(.vertical, 25).padding(.horizontal, 23)
                    Spacer()
                    Text("Thứ 2").padding(.trailing, 20).foregroundColor(.white).font(.system(size: 20, weight: .medium, design: .rounded))
                }.sheet(isPresented: $isShowingImageSheet) {
                    ProfilePopUp()
                }
                
                TextField("", text: $content, prompt: Text("Enter your question").foregroundColor(Color(red: 0.922, green: 0.756, blue: 0.712)), axis: .vertical).font(.system(size: 30)).foregroundColor(.white).accentColor(.white).padding(.horizontal).onReceive(Just(content)) { _ in limitText(50)}.disableAutocorrection(true)
                    .autocapitalization(.none).padding(.bottom).padding(.horizontal, 10)
                
                Spacer()
                
                createButton(isShowing: $isShowingMenu1, menu: $menu1, placeholder: "Menu 1")
                createButton(isShowing: $isShowingMenu2, menu: $menu2, placeholder: "Menu 2")
                createButton(isShowing: $isShowingMenu3, menu: $menu3, placeholder: "Menu 3").padding(.bottom)
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color(red: 0.816, green: 0.422, blue: 0.314)).cornerRadius(55).padding().onTapGesture {
                
                self.endTextEditing()
            }
            
            Spacer()
            
            VStack {
                Button(action: {
                    if (content.isEmpty || menu1.isEmpty || menu2.isEmpty) {
                        errorMessage = "Phải nhập cả question với menu 1 và menu 2 mới được :))"
                        showAlert = true
                    } else {
                        onPostMenu()
                    }
                }) {
                    HStack {
                        if (isLoading == true) {
                            ProgressView().foregroundColor(.white).progressViewStyle(CircularProgressViewStyle(tint: .black)).scaleEffect(1)
                        } else {
                            Text("Send to Long 😏😏😏").font(.system(size: 21, weight: .regular)).foregroundColor(.black)
                        }
                    }.frame(maxWidth: .infinity, maxHeight: 60).background(Color.white).cornerRadius(100).padding(.vertical, 20).padding(.horizontal, 35)
                    
                }.disabled(isLoading == true).alert(isPresented: $showAlert) {
                    Alert(
                        title: Text("Bị lỗi rồi Mai ơiii"),
                        message: Text(errorMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }.frame(maxWidth: .infinity).background(Color(red: 0.134, green: 0.134, blue: 0.134))
            
        }.background(.black).ignoresSafeArea(.keyboard).navigationBarBackButtonHidden(true)
    }
    
    //Function to keep text length in limits
    func limitText(_ upper: Int) {
        if content.count > upper {
            content = String(content.prefix(upper))
        }
    }
    
    func createButton(isShowing: Binding<Bool>, menu: Binding<String>, placeholder: String) -> some View {
        Button(action: {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            isShowing.wrappedValue = true
        }) {
            HStack {
                if menu.wrappedValue.isEmpty {
                    Image(systemName: "plus").font(.system(size: 20)).foregroundColor(Color(hue: 0.035, saturation: 0.063, brightness: 0.795)).padding(.leading, 25)
                }
                Text(menu.wrappedValue.isEmpty ? placeholder : menu.wrappedValue).foregroundColor(Color(hue: 0.035, saturation: 0.063, brightness: 0.795)).font(.system(size: 20)).foregroundColor(.white).accentColor(.white).padding(.horizontal).lineLimit(1)
                Spacer()
            }.frame(maxWidth: .infinity, maxHeight: 80).background(.black).cornerRadius(35).padding(.horizontal)
        }.sheet(isPresented: isShowing) {
            CreatePool(result: menu)
        }
    }
    
    func onPostMenu() {
        isLoading = true
        guard let url = URL(string: "https://0da4-118-70-175-236.ngrok-free.app/menu/add") else { return }
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let data = ["question": content,
                    "menu1": menu1,
                    "menu2": menu2,
                    "menu3": menu3.isEmpty == true ? "Menu 3" : menu3]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        
        request.httpBody = jsonData
        
        URLSession.shared.uploadTask(with: request, from: jsonData) { (data, response, error) in
            guard let data = data else { return }
            do {
                isLoading = false
                let res = try JSONDecoder().decode(MenuResponse.self, from: data)
                if(res.success == true) {
                    DispatchQueue.main.async {
                        dismiss()
                    }
                } else if(res.error?.isEmpty == false) {
                    errorMessage = res.error ?? "Lỗi rùii"
                    showAlert = true
                }
            } catch {
                isLoading = false
                print(String(describing: error))
            }
        }.resume()
    }
}

extension View {
    func endTextEditing () {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
