//
//  MainViewContent.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 18/04/2021.
//

import SwiftUI

struct MainViewContent: View {
    @State var bgcolor = Color(red: 221, green: 223, blue: 232)
    
    @State private var selected: TabName = .Training
    
    enum TabName {
        case Training
        case Vocabulary
    }
    
    var body: some View {
        TabView(selection: $selected) {
            VStack {
                Spacer(minLength: 200)
                Button(action: {}, label: {
                    Text("Manual selection")
                        .font(.title3)
                        .padding(.all)
                        .background(Color.secondary)
                        .cornerRadius(10)
                        .shadow(color: Color(red: 174, green: 174, blue: 192).opacity(0.4), radius: 10, x: 10, y: 10)
                        .shadow(color: .white, radius: 10, x: -10, y: -10)
                })
                .padding()
                Button(action: {}, label: {
                    Text("Use tags")
                        .font(.title3)
                        .padding(.all)
                        .background(bgcolor)
                        .cornerRadius(10)
                        .shadow(color: Color(red: 174, green: 174, blue: 192).opacity(0.4), radius: 10, x: 10, y: 10)
                        .shadow(color: .white, radius: 10, x: -10, y: -10)
                })
                .padding()
                Button(action: {}, label: {
                    Text("Start")
                        .font(.title2)
                        .padding(.all)
                        .background(bgcolor)
                        .cornerRadius(25)
                        .shadow(color: Color(red: 174, green: 174, blue: 192).opacity(0.4), radius: 10, x: 10, y: 10)
                        .shadow(color: .white, radius: 10, x: -10, y: -10)
                })
                .padding(.top, 40)
                .padding(.bottom, 30)
            }
            .tabItem {
                Label("Training", systemImage: "book.closed.fill")
            }
            .background(bgcolor).edgesIgnoringSafeArea(.all)
            
            ZStack {
                AnimationBackground().edgesIgnoringSafeArea(.all)
                    .blur(radius: 50)
                Text("Hello, world")
            }
            .tabItem {
                Label("L'autre", systemImage: "music.mic")
            }
        }
    }
}

struct MainViewContent_Previews: PreviewProvider {
    static var previews: some View {
        MainViewContent()
    }
}

struct AnimationBackground: View {
    
    @State var start = UnitPoint(x: 0, y: -2)
    @State var end = UnitPoint(x: 0, y: -2)
    
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    let colors = [Color.red, Color.blue, Color.pink, Color.green, Color.orange, Color.purple, Color.yellow]
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
            .animation(Animation.easeInOut(duration: 6).repeatForever())
            .onReceive(timer, perform: { _ in
                self.start = UnitPoint(x: CGFloat.random(in: -5...0), y: CGFloat.random(in: -5...0))
                self.end = UnitPoint(x: CGFloat.random(in: 0...5), y: CGFloat.random(in: 0...5))
            })
    }
}

class ChildHostingController: UIHostingController<MainViewContent> {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder,rootView: MainViewContent());
    }
}
