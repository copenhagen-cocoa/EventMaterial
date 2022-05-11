import SwiftUI

struct SomeViewModel {

    func performLongRunningTask() async {}
}

struct SomeView: View {

    private let viewModel = SomeViewModel()

    var body: some View {
        Button("Click Me!") {
            // Create an unstructured task to do some async work.
            Task {
                await viewModel.performLongRunningTask()
            }
        }
    }
}
