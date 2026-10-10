//
//  AvroKeyboard
//
//  Copyright (c) 2012 OmicronLab. All rights reserved.
//

import Cocoa
import InputMethodKit

/// The Preferences panel: a toolbar switching between General, AutoCorrect and Credits panes.
final class PreferencesWindowController: NSWindowController {
    private enum Pane: String, CaseIterable {
        case general = "General"
        case autoCorrect = "AutoCorrect"
        case credits = "Credits"

        var identifier: NSToolbarItem.Identifier { NSToolbarItem.Identifier(rawValue) }
        var size: NSSize {
            switch self {
            case .general: return NSSize(width: 620, height: 390)
            case .autoCorrect: return NSSize(width: 620, height: 460)
            case .credits: return NSSize(width: 620, height: 500)
            }
        }
    }

    private var currentPane: Pane = .general
    private var currentView: NSView?

    private lazy var generalView = makeGeneralView()
    private lazy var autoCorrectView = makeAutoCorrectView()
    private lazy var creditsView = makeCreditsView()

    // AutoCorrect pane state
    private let autoCorrectEntries: [(replace: String, with: String)] = AutoCorrect.shared.entries
        .sorted { $0.key < $1.key }
        .map { (replace: $0.key, with: $0.value) }
    private var filteredEntries: [(replace: String, with: String)] = []
    private let autoCorrectTable = NSTableView()
    private let countLabel = NSTextField(labelWithString: "")

    init() {
        let panel = NSPanel(contentRect: NSRect(origin: .zero, size: Pane.general.size),
                            styleMask: [.titled, .closable, .nonactivatingPanel],
                            backing: .buffered,
                            defer: true)
        panel.title = "Amar Avro Keyboard"
        panel.isReleasedWhenClosed = false
        panel.hidesOnDeactivate = true
        panel.toolbarStyle = .preference
        panel.isMovableByWindowBackground = true
        panel.backgroundColor = .windowBackgroundColor
        super.init(window: panel)

        let toolbar = NSToolbar(identifier: "PreferencesToolbar")
        toolbar.delegate = self
        toolbar.displayMode = .iconAndLabel
        toolbar.selectedItemIdentifier = Pane.general.identifier
        panel.toolbar = toolbar

        filteredEntries = autoCorrectEntries
        show(.general, animated: false)
        panel.center()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Pane switching

    private func view(for pane: Pane) -> NSView {
        switch pane {
        case .general: return generalView
        case .autoCorrect: return autoCorrectView
        case .credits: return creditsView
        }
    }

    @objc private func switchPane(_ sender: NSToolbarItem) {
        guard let pane = Pane(rawValue: sender.itemIdentifier.rawValue), pane != currentPane else { return }
        show(pane, animated: true)
    }

    private func show(_ pane: Pane, animated: Bool) {
        guard let window else { return }
        let view = view(for: pane)
        currentPane = pane
        window.toolbar?.selectedItemIdentifier = pane.identifier

        // Resize the window around its top-left corner so the toolbar stays put.
        var frame = window.frameRect(forContentRect: NSRect(origin: .zero, size: pane.size))
        frame.origin.x = window.frame.origin.x
        frame.origin.y = window.frame.maxY - frame.height

        currentView?.removeFromSuperview()
        window.setFrame(frame, display: true, animate: animated)

        view.frame = window.contentView!.bounds
        view.autoresizingMask = [.width, .height]
        window.contentView?.addSubview(view)
        currentView = view
    }

    // MARK: - General

    private func makeGeneralView() -> NSView {
        let defaults = NSUserDefaultsController.shared

        let layout = NSPopUpButton(frame: .zero, pullsDown: false)
        for keyboardLayout in Preferences.KeyboardLayout.allCases {
            layout.addItem(withTitle: keyboardLayout.title)
            layout.lastItem?.tag = keyboardLayout.rawValue
        }
        layout.bind(.selectedTag, to: defaults, withKeyPath: "values.\(Preferences.Key.keyboardLayout)")

        let outputAsANSI = NSButton(checkboxWithTitle: "Output as ANSI (Bijoy fonts)", target: nil, action: nil)
        outputAsANSI.bind(.value, to: defaults, withKeyPath: "values.\(Preferences.Key.outputAsANSI)")

        let orientation = NSPopUpButton(frame: .zero, pullsDown: false)
        for (title, tag) in [("Horizontal", kIMKSingleRowSteppingCandidatePanel), ("Vertical", kIMKSingleColumnScrollingCandidatePanel)] {
            orientation.addItem(withTitle: title)
            orientation.lastItem?.tag = tag
        }
        orientation.bind(.selectedTag, to: defaults, withKeyPath: "values.\(Preferences.Key.candidatePanelType)")

        let includeDictionary = NSButton(checkboxWithTitle: "Include Dictionary Suggestions", target: nil, action: nil)
        includeDictionary.bind(.value, to: defaults, withKeyPath: "values.\(Preferences.Key.includeDictionary)")

        let commitNewline = NSButton(checkboxWithTitle: "Commit new line on Enter/Return", target: nil, action: nil)
        commitNewline.bind(.value, to: defaults, withKeyPath: "values.\(Preferences.Key.commitNewLineOnEnter)")

        // The remaining options only apply to phonetic typing (layout 0).
        for control in [orientation, includeDictionary, commitNewline] {
            control.bind(.enabled, to: defaults, withKeyPath: "values.\(Preferences.Key.keyboardLayout)",
                         options: [.valueTransformerName: NSValueTransformerName.negateBooleanTransformerName])
        }

        let layoutLabel = NSTextField(labelWithString: "Keyboard Layout:")
        let label = NSTextField(labelWithString: "Suggestion List Orientation:")
        label.alignment = .right

        let grid = NSGridView(views: [
            [layoutLabel, layout],
            [NSGridCell.emptyContentView, outputAsANSI],
            [label, orientation],
            [NSGridCell.emptyContentView, includeDictionary],
            [NSGridCell.emptyContentView, commitNewline],
        ])
        grid.rowSpacing = 8
        grid.columnSpacing = 8
        grid.column(at: 0).xPlacement = .trailing
        grid.row(at: 0).yPlacement = .center
        grid.row(at: 2).yPlacement = .center
        grid.row(at: 1).bottomPadding = 8

        // Branded, spacious settings surface with a clear title hierarchy.
        let container = NSView()
        let logo = NSImageView()
        logo.image = NSImage(named: NSImage.applicationIconName)
        logo.imageScaling = .scaleProportionallyUpOrDown
        logo.wantsLayer = true
        logo.layer?.cornerRadius = 11
        logo.layer?.masksToBounds = true

        let title = NSTextField(labelWithString: "Amar Avro Keyboard")
        title.font = .systemFont(ofSize: 21, weight: .bold)
        title.textColor = .labelColor

        let subtitle = NSTextField(labelWithString: "Your Bangla typing experience, tailored to you.")
        subtitle.font = .systemFont(ofSize: 12, weight: .regular)
        subtitle.textColor = .secondaryLabelColor

        let separator = NSBox()
        separator.boxType = .separator

        for view in [logo, title, subtitle, separator, grid] {
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
        }
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: container.topAnchor, constant: 22),
            logo.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 28),
            logo.widthAnchor.constraint(equalToConstant: 52),
            logo.heightAnchor.constraint(equalToConstant: 52),

            title.topAnchor.constraint(equalTo: logo.topAnchor, constant: 3),
            title.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: 14),
            title.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -28),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 5),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -28),

            separator.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 18),
            separator.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 28),
            separator.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -28),

            grid.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 22),
            grid.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 28),
            grid.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -28),
            orientation.widthAnchor.constraint(equalToConstant: 280),
            layout.widthAnchor.constraint(equalTo: orientation.widthAnchor),
        ])
        return container
    }

    // MARK: - AutoCorrect

    private func makeAutoCorrectView() -> NSView {
        let searchField = NSSearchField()
        searchField.target = self
        searchField.action = #selector(filterEntries(_:))
        searchField.sendsSearchStringImmediately = true

        for (title, key) in [("Replace", "replace"), ("With", "with")] {
            let column = NSTableColumn(identifier: NSUserInterfaceItemIdentifier(key))
            column.title = title
            column.width = 200
            column.isEditable = false
            autoCorrectTable.addTableColumn(column)
        }
        autoCorrectTable.usesAlternatingRowBackgroundColors = true
        autoCorrectTable.allowsMultipleSelection = false
        autoCorrectTable.allowsColumnReordering = false
        autoCorrectTable.columnAutoresizingStyle = .lastColumnOnlyAutoresizingStyle
        autoCorrectTable.dataSource = self
        autoCorrectTable.delegate = self

        let scrollView = NSScrollView()
        scrollView.documentView = autoCorrectTable
        scrollView.hasVerticalScroller = true
        scrollView.borderType = .bezelBorder

        countLabel.alignment = .right
        updateCountLabel()

        let container = NSView()
        let logo = NSImageView()
        logo.image = NSImage(named: NSImage.applicationIconName)
        logo.imageScaling = .scaleProportionallyUpOrDown
        logo.wantsLayer = true
        logo.layer?.cornerRadius = 9
        logo.layer?.masksToBounds = true

        let title = NSTextField(labelWithString: "AutoCorrect Dictionary")
        title.font = .systemFont(ofSize: 20, weight: .semibold)
        title.textColor = .labelColor
        let subtitle = NSTextField(labelWithString: "Search and review automatic text replacements.")
        subtitle.font = .systemFont(ofSize: 12, weight: .regular)
        subtitle.textColor = .secondaryLabelColor

        for view in [logo, title, subtitle, searchField, scrollView, countLabel] {
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
        }
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            logo.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            logo.widthAnchor.constraint(equalToConstant: 44),
            logo.heightAnchor.constraint(equalToConstant: 44),

            title.topAnchor.constraint(equalTo: logo.topAnchor, constant: 1),
            title.leadingAnchor.constraint(equalTo: logo.trailingAnchor, constant: 12),
            title.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -24),

            subtitle.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            subtitle.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            subtitle.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -24),

            searchField.topAnchor.constraint(equalTo: subtitle.bottomAnchor, constant: 16),
            searchField.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            searchField.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),

            scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 8),
            scrollView.leadingAnchor.constraint(equalTo: searchField.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: searchField.trailingAnchor),

            countLabel.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 8),
            countLabel.trailingAnchor.constraint(equalTo: searchField.trailingAnchor),
            countLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
        ])
        return container
    }

    @objc private func filterEntries(_ sender: NSSearchField) {
        let query = sender.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
        if query.isEmpty {
            filteredEntries = autoCorrectEntries
        } else {
            filteredEntries = autoCorrectEntries.filter {
                $0.replace.localizedCaseInsensitiveContains(query) || $0.with.contains(query)
            }
        }
        autoCorrectTable.reloadData()
        updateCountLabel()
    }

    private func updateCountLabel() {
        countLabel.stringValue = "\(filteredEntries.count) Items"
    }

    // MARK: - Credits

    private func makeCreditsView() -> NSView {
        let container = NSView()
        let logo = NSImageView()
        logo.image = NSImage(named: NSImage.applicationIconName)
        logo.imageScaling = .scaleProportionallyUpOrDown
        logo.wantsLayer = true
        logo.layer?.cornerRadius = 16
        logo.layer?.masksToBounds = true

        let title = NSTextField(labelWithString: "Amar Avro Keyboard")
        title.font = .systemFont(ofSize: 23, weight: .bold)
        title.textColor = .labelColor

        let version = NSTextField(labelWithString: "Version 1.0.0  •  Made with care for Bangla typing")
        version.font = .systemFont(ofSize: 12, weight: .medium)
        version.textColor = .secondaryLabelColor

        let divider = NSBox()
        divider.boxType = .separator

        let developerTitle = NSTextField(labelWithString: "Designed & maintained by")
        developerTitle.font = .systemFont(ofSize: 12, weight: .medium)
        developerTitle.textColor = .secondaryLabelColor

        let developer = NSTextField(labelWithString: "Md Rakib Hossain")
        developer.font = .systemFont(ofSize: 17, weight: .semibold)
        developer.textColor = .labelColor

        let description = NSTextField(wrappingLabelWithString: "A customized macOS Bangla input method with phonetic typing, fixed layouts, dictionary suggestions and AutoCorrect.")
        description.font = .systemFont(ofSize: 13, weight: .regular)
        description.textColor = .secondaryLabelColor

        let license = NSTextField(wrappingLabelWithString: "Open-source notices: This project includes upstream Avro Keyboard components. Original license terms and required notices are provided in the LICENSE file included with this distribution.")
        license.font = .systemFont(ofSize: 11, weight: .regular)
        license.textColor = .tertiaryLabelColor

        for view in [logo, title, version, divider, developerTitle, developer, description, license] {
            view.translatesAutoresizingMaskIntoConstraints = false
            container.addSubview(view)
        }
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: container.topAnchor, constant: 34),
            logo.centerXAnchor.constraint(equalTo: container.centerXAnchor),
            logo.widthAnchor.constraint(equalToConstant: 92),
            logo.heightAnchor.constraint(equalToConstant: 92),

            title.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: 16),
            title.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            version.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 6),
            version.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            divider.topAnchor.constraint(equalTo: version.bottomAnchor, constant: 24),
            divider.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 52),
            divider.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -52),

            developerTitle.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 22),
            developerTitle.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            developer.topAnchor.constraint(equalTo: developerTitle.bottomAnchor, constant: 5),
            developer.centerXAnchor.constraint(equalTo: container.centerXAnchor),

            description.topAnchor.constraint(equalTo: developer.bottomAnchor, constant: 14),
            description.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 64),
            description.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -64),

            license.topAnchor.constraint(equalTo: description.bottomAnchor, constant: 18),
            license.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 64),
            license.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -64),
        ])
        return container
    }
}

// MARK: - NSToolbarDelegate

extension PreferencesWindowController: NSToolbarDelegate {
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        toolbarDefaultItemIdentifiers(toolbar)
    }

    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        [Pane.general.identifier, Pane.autoCorrect.identifier, .flexibleSpace, Pane.credits.identifier]
    }

    func toolbarSelectableItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        Pane.allCases.map(\.identifier)
    }

    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        guard let pane = Pane(rawValue: itemIdentifier.rawValue) else { return nil }
        let item = NSToolbarItem(itemIdentifier: itemIdentifier)
        item.label = pane.rawValue
        item.paletteLabel = pane.rawValue
        item.image = NSImage(named: pane.rawValue)
        item.target = self
        item.action = #selector(switchPane(_:))
        return item
    }
}

// MARK: - NSTableViewDataSource / NSTableViewDelegate

extension PreferencesWindowController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        filteredEntries.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let tableColumn else { return nil }
        let entry = filteredEntries[row]
        let text = tableColumn.identifier.rawValue == "replace" ? entry.replace : entry.with

        let identifier = NSUserInterfaceItemIdentifier("cell")
        let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView ?? {
            let cell = NSTableCellView()
            cell.identifier = identifier
            let field = NSTextField(labelWithString: "")
            field.lineBreakMode = .byTruncatingTail
            field.translatesAutoresizingMaskIntoConstraints = false
            cell.addSubview(field)
            cell.textField = field
            NSLayoutConstraint.activate([
                field.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 2),
                field.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -2),
                field.centerYAnchor.constraint(equalTo: cell.centerYAnchor),
            ])
            return cell
        }()
        cell.textField?.stringValue = text
        return cell
    }
}
