import SwiftUI

struct PaletteView: View
{
    static let preferredWidth: CGFloat = 360

    @ObservedObject var model: PaletteModel

    var body: some View
    {
        VStack(alignment: .leading, spacing: 16)
        {
            HStack
            {
                Text("Arrange Window")
                    .font(.headline)
                Spacer()
                Picker("Grid", selection: dimensionBinding)
                {
                    ForEach(GridDimension.allCases, id: \.self)
                    {
                        dimension in
                        Text(dimension.title)
                            .tag(dimension)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .frame(width: 198)
            }

            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 5),
                spacing: 6
            )
            {
                ForEach(LayoutPreset.paletteCases, id: \.self)
                {
                    preset in
                    Button
                    {
                        model.commit(preset)
                    }
                    label:
                    {
                        Image(systemName: preset.systemImage)
                            .frame(maxWidth: .infinity, minHeight: 24)
                    }
                    .buttonStyle(.bordered)
                    .help(preset.title)
                    .accessibilityIdentifier("palette.preset.\(preset.rawValue)")
                    .accessibilityLabel(preset.title)
                }
            }

            HStack(spacing: 8)
            {
                Menu("Thirds")
                {
                    ForEach(LayoutPreset.horizontalThirdCases, id: \.self)
                    {
                        preset in
                        Button(preset.title)
                        {
                            model.commit(preset)
                        }
                    }

                    Divider()

                    ForEach(LayoutPreset.verticalThirdCases, id: \.self)
                    {
                        preset in
                        Button(preset.title)
                        {
                            model.commit(preset)
                        }
                    }
                }

                Menu("Center")
                {
                    ForEach(LayoutPreset.centeredSizeCases, id: \.self)
                    {
                        preset in
                        Button(preset.title)
                        {
                            model.commit(preset)
                        }
                    }

                    Divider()

                    Button(LayoutPreset.maximizeWidth.title)
                    {
                        model.commit(.maximizeWidth)
                    }

                    Button(LayoutPreset.maximizeHeight.title)
                    {
                        model.commit(.maximizeHeight)
                    }
                }

                Menu("Move")
                {
                    ForEach(WindowMovePosition.allCases, id: \.self)
                    {
                        position in
                        Button(position.title)
                        {
                            model.commit(.move(position))
                        }
                    }

                    Divider()

                    ForEach(WindowAdjustment.moveCases, id: \.self)
                    {
                        adjustment in
                        Button(adjustment.title)
                        {
                            model.commit(adjustment)
                        }
                    }
                }

                Menu("Resize")
                {
                    ForEach(WindowAdjustment.resizeCases, id: \.self)
                    {
                        adjustment in
                        Button(adjustment.title)
                        {
                            model.commit(adjustment)
                        }
                    }
                }
            }
            .menuStyle(.borderlessButton)
            .fixedSize(horizontal: false, vertical: true)

            ZStack
            {
                LazyVGrid(
                    columns: Array(
                        repeating: GridItem(.flexible(), spacing: 6),
                        count: model.dimension.columnCount
                    ),
                    spacing: 6
                )
                {
                    ForEach(cells, id: \.self)
                    {
                        cell in
                        GridCellView(
                            cell: cell,
                            dimension: model.dimension,
                            isSelected: model.selectedRegion?.contains(cell) == true
                        )
                        {
                            model.select(cell)
                        }
                    }
                }

                GridInteractionView(
                    begin:
                    {
                        location, size in
                        model.beginDrag(at: location, in: size)
                    },
                    update:
                    {
                        location, size in
                        model.updateDrag(at: location, in: size)
                    },
                    end:
                    {
                        location, size in
                        model.endDrag(at: location, in: size)
                    }
                )
                .accessibilityHidden(true)
            }
            .frame(height: gridHeight)
            .accessibilityIdentifier("palette.grid")
            .accessibilityLabel("Window layout grid")

            Text("Drag across cells. Use 2, 3, or 4 for grids; F to fill; C to center; Option-arrow to move; Command-arrow to resize.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(
            width: Self.preferredWidth,
            height: Self.preferredHeight(for: model.dimension),
            alignment: .topLeading
        )
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .accessibilityElement(children: .contain)
    }

    private var dimensionBinding: Binding<GridDimension>
    {
        Binding(
            get:
            {
                model.dimension
            },
            set:
            {
                model.setDimension($0)
            }
        )
    }

    private var cells: [GridCell]
    {
        (0..<model.dimension.rowCount).flatMap
        {
            row in
            (0..<model.dimension.columnCount).map
            {
                column in
                GridCell(row: row, column: column)
            }
        }
    }

    private var gridHeight: CGFloat
    {
        let spacing: CGFloat = 6
        let width: CGFloat = 324
        let cellWidth = (
            width - spacing * CGFloat(model.dimension.columnCount - 1)
        ) / CGFloat(model.dimension.columnCount)
        return cellWidth * CGFloat(model.dimension.rowCount)
            + spacing * CGFloat(model.dimension.rowCount - 1)
    }

    static func preferredHeight(for dimension: GridDimension) -> CGFloat
    {
        switch dimension
        {
        case .fourByTwo:
            return 422
        case .three, .four:
            return 602
        }
    }
}
