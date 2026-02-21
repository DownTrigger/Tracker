import UIKit

final class CustomDatePickerView: UIView {

    // MARK: - Public API
    var date: Date {
        get { datePicker.date }
        set {
            datePicker.date = newValue
            updateDateLabel()
        }
    }

    var onDateChanged: ((Date) -> Void)?

    // MARK: - Subviews
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .compact
        picker.locale = .current
        picker.calendar = .current
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.alpha = Constants.pickerAlphaForHitTesting
        return picker
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = AppColors.datepickerBackground
        view.layer.cornerRadius = Constants.cornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: Constants.fontSize, weight: .regular)
        label.textColor = AppColors.accentBlack
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        return label
    }()

    private lazy var pressGesture: UILongPressGestureRecognizer = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handlePress(_:)))
        gesture.minimumPressDuration = 0
        gesture.delegate = self
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        return gesture
    }()

    // MARK: - Constants
    private enum Constants {
        static let width: CGFloat = 77
        static let height: CGFloat = 34
        static let cornerRadius: CGFloat = 8
        static let fontSize: CGFloat = 17
        static let pickerAlphaForHitTesting: CGFloat = 0.02
        static let pressAnimationDuration: TimeInterval = 0.15
        static let pressedAlpha: CGFloat = 0.7
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup
    private func setup() {
        setupHierarchy()
        setupConstraints()
        updateDateLabel()
        datePicker.addTarget(self, action: #selector(pickerValueChanged), for: .valueChanged)
        datePicker.addGestureRecognizer(pressGesture)
    }

    private func setupHierarchy() {
        addSubview(containerView)
        containerView.addSubview(dateLabel)
        addSubview(datePicker)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: Constants.width),
            heightAnchor.constraint(equalToConstant: Constants.height),

            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),

            dateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            dateLabel.topAnchor.constraint(equalTo: containerView.topAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

            datePicker.leadingAnchor.constraint(equalTo: leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func updateDateLabel() {
        dateLabel.text = Date.trackerDateString(from: datePicker.date)
    }

    // MARK: - Actions
    @objc private func handlePress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            setPressed(true)
        case .ended, .cancelled:
            setPressed(false)
        default:
            break
        }
    }

    @objc private func pickerValueChanged() {
        updateDateLabel()
        onDateChanged?(datePicker.date)
    }

    // MARK: - Press animation
    private func setPressed(_ pressed: Bool) {
        UIView.animate(
            withDuration: Constants.pressAnimationDuration,
            delay: 0,
            options: [.beginFromCurrentState, .allowUserInteraction]
        ) {
            self.containerView.alpha = pressed ? Constants.pressedAlpha : 1
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension CustomDatePickerView: UIGestureRecognizerDelegate {

    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
