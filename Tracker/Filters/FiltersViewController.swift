import UIKit

final class FiltersViewController: UIViewController {

    // MARK: - ViewModel
    private let viewModel: FiltersViewModel

    // MARK: - Callbacks
    var onFilterSelected: ((TrackerFilter) -> Void)?

    // MARK: - UI
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = AppColors.primaryBackground
        table.rowHeight = Constants.rowHeight
        table.isScrollEnabled = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: Constants.cellReuseId)
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    // MARK: - Init
    init(viewModel: FiltersViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticsService.reportOpen(screen: Strings.analyticsScreen)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticsService.reportClose(screen: Strings.analyticsScreen)
    }

    // MARK: - Setup
    private func setupUI() {
        title = Strings.screenTitle
        view.backgroundColor = AppColors.primaryBackground
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: CGFloat.leastNormalMagnitude))
        tableView.contentInset = UIEdgeInsets(top: Constants.tableTopInset, left: 0, bottom: 0, right: 0)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellReuseId, for: indexPath)
        let filter = viewModel.filters[indexPath.row]
        cell.textLabel?.text = filter.title
        cell.textLabel?.font = .systemFont(ofSize: Constants.cellFontSize)
        cell.backgroundColor = AppColors.secondaryBackground
        cell.selectionStyle = .none
        let showCheckmark = filter == viewModel.activeFilter && filter != .all && filter != .today
        cell.accessoryType = showCheckmark ? .checkmark : .none
        cell.tintColor = AppColors.accentBlue
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        CGFloat.leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        nil
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = viewModel.filters[indexPath.row]
        AnalyticsService.reportClick(screen: Strings.analyticsScreen, item: filter.analyticsItem)
        viewModel.selectFilter(filter)
        onFilterSelected?(filter)
        dismiss(animated: true)
    }
}

// MARK: - Constants
private extension FiltersViewController {
    enum Constants {
        static let rowHeight: CGFloat = 75
        static let cellFontSize: CGFloat = 17
        static let cellReuseId = "FilterCell"
        static let tableTopInset: CGFloat = 24
    }

    enum Strings {
        static let screenTitle = "filter_title".localized
        static let analyticsScreen = "Filters"
    }
}
