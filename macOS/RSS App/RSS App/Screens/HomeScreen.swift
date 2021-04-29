
import SwiftUI
import WrappingHStack

extension View {
    func inExpandingRectangle() -> some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
            self
        }
    }

    func inRectangle(width: CGFloat? = nil, height: CGFloat? = nil) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: width, height: height)
            self
        }
    }
}

struct HomeScreen: View {
    @EnvironmentObject private var location: AppLocationManager

    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            Button {
                location.push(.feeds)
            } label: {
                Text("Feeds").font(.title).bold()
                    .inRectangle(width: 175, height: 75)
            }
            .buttonStyle(RSSAppButtonStyle())

            Button {
                location.push(.categories)
            } label: {
                Text("Categories").font(.title).bold()
                    .inRectangle(width: 175, height: 75)
            }
            .buttonStyle(RSSAppButtonStyle())

            Button {
                location.push(.settings)
            } label: {
                Text("Settings").font(.title).bold()
                    .inRectangle(width: 175, height: 75)
            }
            .buttonStyle(RSSAppButtonStyle())

            Spacer()
        }
    }
}

//struct HomeScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeScreen()
//    }
//}
