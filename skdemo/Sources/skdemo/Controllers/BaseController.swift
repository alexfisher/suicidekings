import Foundation
import ConsoleKit

protocol StackableController: class {
    var parentController: StackableController? { get set }
    
    func start()
    
    func push(child controller: BaseController)
    func pop()
}

class BaseController: Identifiable, StackableController {
    // MARK: Initialization
    init(with context: AppContext) {
        self.context  = context
        context.push()
    }

    // MARK: Deinitialization
    deinit {
        context.pop()
    }

    // MARK: Properties (Public)
    private(set) var id : UUID = UUID()
    let context         : AppContext
    let console         : Console = Terminal()

    weak var parentController: StackableController? {
        willSet {
            guard newValue == nil else {
                return
            }
            
            guard let parentController = self.parentController as? BaseController else {
                return
            }
            
            if let idx = parentController.childControllers.firstIndex(where: { $0.id == self.id }) {
                parentController.childControllers.remove(at: idx)
            }
        }
    }

    var childControllers: [BaseController] = []

    func start() { /* no-op */ }

    func push(child controller: BaseController) {
        controller.parentController = self
        childControllers.append(controller)
        controller.start()
    }

    func pop() {
        self.parentController = nil
    }
}
