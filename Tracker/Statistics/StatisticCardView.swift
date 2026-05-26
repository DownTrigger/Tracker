import UIKit

final class StatisticCardView: UIView {

    // MARK: - UI
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = AppColors.primaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = AppColors.primaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Gradient border
    private let gradientLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        updateGradientBorder()
    }

    // MARK: - Public
    func configure(value: Int, title: String) {
        valueLabel.text = "\(value)"
        titleLabel.text = title
    }

    // MARK: - Private
    private func setup() {
        layer.cornerRadius = Constants.cornerRadius

        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.valueLabelTop),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding),

            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Constants.titleLabelBottom),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.horizontalPadding),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.horizontalPadding)
        ])
    }

    private func updateGradientBorder() {
        gradientLayer.removeFromSuperlayer()

        gradientLayer.frame = bounds
        gradientLayer.colors = [
            UIColor(hex: "#FD4C49").cgColor,
            UIColor(hex: "#46E69D").cgColor,
            UIColor(hex: "#007BFA").cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        borderMaskLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: Constants.cornerRadius
        ).cgPath
        borderMaskLayer.lineWidth = 1
        borderMaskLayer.strokeColor = UIColor.black.cgColor
        borderMaskLayer.fillColor = UIColor.clear.cgColor
        gradientLayer.mask = borderMaskLayer

        layer.insertSublayer(gradientLayer, at: 0)
    }
}

// MARK: - Constants
private extension StatisticCardView {
    enum Constants {
        static let cornerRadius: CGFloat = 16
        static let horizontalPadding: CGFloat = 12
        static let valueLabelTop: CGFloat = 12
        static let titleLabelBottom: CGFloat = 12
    }
}
