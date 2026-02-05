import SwiftUI

#Preview {
    let state = AppState()
    state.load()
    return AccountQuickActionsView(state: state, onClose: {}, onOpenAccount: {})
}
