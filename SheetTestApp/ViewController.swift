import UIKit

class ViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(tableView)
		view.addSubview(stickyFooterView)
		view.backgroundColor = .systemGroupedBackground

		NSLayoutConstraint.activate([
			tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			tableView.widthAnchor.constraint(lessThanOrEqualToConstant: 700),
			tableView.topAnchor.constraint(equalTo: view.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: stickyFooterView.topAnchor),
			stickyFooterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			stickyFooterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			stickyFooterView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		])

		let widthConstraint = tableView.widthAnchor.constraint(equalTo: view.widthAnchor)
		widthConstraint.priority = .defaultLow
		widthConstraint.isActive = true
	}

	private func presentSheet() {
		let viewController = UIViewController()
		var presentingVC: UIViewController = self
		while let presentedVC = presentingVC.presentedViewController {
			presentingVC = presentedVC
		}
		viewController.view = makeSheetContentView(dismissClosure: {
			presentingVC.dismiss(animated: true)
		})
		viewController.modalPresentationStyle = sheetType

		if let sheetPresentationController = viewController.presentationController as? UISheetPresentationController {
			if mediumDetentEnabled {
				sheetPresentationController.detents = [.medium(), .large()]
			}

			if let smallestUndimmed = smallestUndimmedDetent {
				sheetPresentationController.smallestUndimmedDetentIdentifier = smallestUndimmed
			}

			sheetPresentationController.prefersScrollingExpandsWhenScrolledToEdge = scrollingExpandsSheet
			sheetPresentationController.prefersGrabberVisible = grabberVisible
			sheetPresentationController.prefersEdgeAttachedInCompactHeight = edgeAttachedInCompactHeight
			sheetPresentationController.widthFollowsPreferredContentSizeWhenEdgeAttached = widthFollowsPreferredContentSize
		}


		presentingVC.present(viewController, animated: true)
	}

	private func makeNestedSheetButton() -> UIView {
		var configuration = UIButton.Configuration.filled()
		configuration.title = "Another one"
		let button = UIButton(configuration: configuration, primaryAction: UIAction() {_ in
			self.presentSheet()
		})
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}

	private func makeDismissButton(action: @escaping () -> ()) -> UIView {
		var configuration = UIButton.Configuration.gray()
		configuration.title = "Dismiss"
		let button = UIButton(configuration: configuration, primaryAction: UIAction() {_ in
			action()
		})
		button.translatesAutoresizingMaskIntoConstraints = false
		return button
	}

	private func makeSheetContentView(dismissClosure: @escaping () -> ()) -> UIView {
		let view = UIView()
		let anotherSheetButton = makeNestedSheetButton()
		let dismissButton = makeDismissButton(action: dismissClosure)
		let stack = UIStackView(arrangedSubviews: [anotherSheetButton, dismissButton])
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.distribution = .fillEqually
		stack.spacing = 20
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .systemBackground
		view.addSubview(stack)

		NSLayoutConstraint.activate([
			stack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
			stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
			stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
		])
		return view
	}

	private lazy var stickyFooterView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .systemBackground
		view.addSubview(button)

		NSLayoutConstraint.activate([
			button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
			button.topAnchor.constraint(equalTo: view.topAnchor, constant: 20)
		])
		return view
	}()

	private lazy var button: UIButton = {
		var configuration = UIButton.Configuration.filled()
		configuration.title = "Present sheet"
		let button = UIButton(configuration: configuration, primaryAction: UIAction(handler: { _ in
			self.presentSheet()
		}))
		button.translatesAutoresizingMaskIntoConstraints = false
		button.widthAnchor.constraint(equalToConstant: 250).isActive = true
		return button
	}()

	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .insetGrouped)
		tableView.translatesAutoresizingMaskIntoConstraints = false
		tableView.dataSource = self
		tableView.delegate = self

		return tableView
	}()

	private var sheetType: UIModalPresentationStyle = .pageSheet
	private var detents: Set<UISheetPresentationController.Detent.Identifier> = []
	private var smallestUndimmedDetent: UISheetPresentationController.Detent.Identifier?
	private var mediumDetentEnabled: Bool = false
	private var scrollingExpandsSheet: Bool = true
	private var grabberVisible: Bool = false
	private var edgeAttachedInCompactHeight: Bool = false
	private var widthFollowsPreferredContentSize: Bool = false

	private lazy var sections = [
		SettingSection(title: "Sheet type", items: [
			SettingItem(title: "Page sheet", action: { _ in self.sheetType = .pageSheet }, isSelected: true),
			SettingItem(title: "Form sheet", action: { _ in self.sheetType = .formSheet })
		]),
		SettingSection(title: "Smallest undimmed detent", items: [
			SettingItem(title: ".medium", action: {_ in self.smallestUndimmedDetent = .medium}),
			SettingItem(title: ".large", action: {_ in self.smallestUndimmedDetent = .large}),
			SettingItem(title: "nil", action: {_ in self.smallestUndimmedDetent = nil}, isSelected: true)
		]),
		SettingSection(title: "Settings", items: [
			BooleanSettingItem(title: ".medium detent", action: {item in
				if let booleanItem = item as? BooleanSettingItem {
					self.mediumDetentEnabled = booleanItem.isOn
				}
			}, isOn: mediumDetentEnabled, subtitle: "Enabling this passes [.medium(), .large()] as the detents list. The default is [.large()]"),
			BooleanSettingItem(title: "Scrolling expands", action: {item in
				if let booleanItem = item as? BooleanSettingItem {
					self.scrollingExpandsSheet = booleanItem.isOn
				}
			}, isOn: scrollingExpandsSheet, subtitle: "Scrolling the sheet content will expand the sheet up to its largest detent."),
			BooleanSettingItem(title: "Grabber visible", action: {item in
				if let booleanItem = item as? BooleanSettingItem {
					self.grabberVisible = booleanItem.isOn
				}
			}, isOn: grabberVisible),
			BooleanSettingItem(title: "Edge attached in compact height", action: {item in
				if let booleanItem = item as? BooleanSettingItem {
					self.edgeAttachedInCompactHeight = booleanItem.isOn
				}
			}, isOn: edgeAttachedInCompactHeight, subtitle: "This forces a sheet presentation in heights where the view controller would otherwise be full screen (iPhone landscape)."),
			BooleanSettingItem(title: "Width follows preferred content size when edge attached", action: {item in
				if let booleanItem = item as? BooleanSettingItem {
					self.widthFollowsPreferredContentSize = booleanItem.isOn
				}
			}, isOn: widthFollowsPreferredContentSize, subtitle: "Only applies in cases where the sheet doesn't fill the screen width by default.")
		])
	]
}

extension ViewController: UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return sections.count
	}

	func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let headerView: UITableViewHeaderFooterView = UITableViewHeaderFooterView()
		var content = UIListContentConfiguration.groupedHeader()
		content.text = sections[section].title
		headerView.contentConfiguration = content
		return headerView
	}

	func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return sections[section].title
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sections[section].items.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let settingItem = sections[indexPath.section].items[indexPath.row]
		let cell = UITableViewCell()
		var configuration = UIListContentConfiguration.cell()

		configuration.text = settingItem.title

		if settingItem.subtitle != "" {
			configuration.secondaryText = settingItem.subtitle
		}

		cell.contentConfiguration = configuration

		if let booleanSettingItem = settingItem as? BooleanSettingItem {
			let switchView = UISwitch(frame: .zero, primaryAction: UIAction() {action in
				if let switchSender = action.sender as? UISwitch {
					booleanSettingItem.isOn = switchSender.isOn
					booleanSettingItem.action?(booleanSettingItem)
				}
			})
			switchView.isOn = booleanSettingItem.isOn
			cell.accessoryView = switchView
		} else {
			cell.accessoryType = settingItem.isSelected ? .checkmark : .none
		}

		return cell
	}
}

extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let cell = tableView.cellForRow(at: indexPath) else {
			return
		}
		let settingItem = sections[indexPath.section].items[indexPath.row]
		if !(settingItem is BooleanSettingItem) {
			if settingItem.multipleChoice {
				settingItem.isSelected.toggle()
				cell.accessoryType = settingItem.isSelected ? .checkmark : .none
				settingItem.action?(settingItem)
			} else {
				if !settingItem.isSelected {
					settingItem.isSelected = true
					cell.accessoryType = .checkmark
					settingItem.action?(settingItem)

					for (i, item) in sections[indexPath.section].items.enumerated() {
						if i != indexPath.row {
							item.isSelected = false
							if let otherCell = tableView.cellForRow(at: IndexPath(row: i, section: indexPath.section)) {
								otherCell.accessoryType = .none
							}
						}
					}
				}
			}
		}
		tableView.deselectRow(at: indexPath, animated: true)
	}
}

class SettingSection {
	init(title: String, items: [SettingItem]) {
		self.title = title
		self.items = items
	}

	var title: String = ""
	var items: [SettingItem] = []
}

class SettingItem {
	init(title: String, action: @escaping (SettingItem) -> (), multipleChoice: Bool = false, isSelected: Bool = false, subtitle: String = "") {
		self.title = title
		self.action = action
		self.multipleChoice = multipleChoice
		self.isSelected = isSelected
		self.subtitle = subtitle
	}

	var title: String = ""
	var subtitle: String = ""
	var multipleChoice: Bool
	var isSelected: Bool = false
	var action: ((SettingItem) -> ())?
}

class BooleanSettingItem: SettingItem {
	init(title: String, action: @escaping (SettingItem) -> (), isOn: Bool, subtitle: String = "") {
		super.init(title: title, action: action, subtitle: subtitle)
		self.isOn = isOn
	}
	var isOn: Bool = false
}

