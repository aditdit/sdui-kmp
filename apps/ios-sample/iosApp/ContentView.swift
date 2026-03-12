import SwiftUI
import Shared
import SDUI

struct ContentView: View {
    let parser = SduiParser()
    @State private var components: [SDUIComponent] = []

    var body: some View {
        VStack {
            SDUIRenderer(components: components)
        }
        .onAppear {
            let mockJson = parser.getMockData()
            self.components = parser.parse(json: mockJson)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
