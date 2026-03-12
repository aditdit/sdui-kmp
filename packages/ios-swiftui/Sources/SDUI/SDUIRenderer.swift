import SwiftUI
import Shared // Importing the KMM shared framework

public struct SDUIRenderer: View {
    public let components: [SDUIComponent]
    
    public init(components: [SDUIComponent]) {
        self.components = components
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(0..<components.count, id: \.self) { index in
                SDUIComponentDispatcher(component: components[index])
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

public struct SDUIComponentDispatcher: View {
    public let component: SDUIComponent
    
    public init(component: SDUIComponent) {
        self.component = component
    }
    
    public var body: some View {
        Group {
            if let textComp = component as? TextComponent {
                TextRenderer(component: textComp)
            } else if let buttonComp = component as? ButtonComponent {
                ButtonRenderer(component: buttonComp)
            } else if let containerComp = component as? ContainerComponent {
                ContainerRenderer(component: containerComp)
            } else if let columnComp = component as? ColumnComponent {
                ColumnRenderer(component: columnComp)
            } else if let rowComp = component as? RowComponent {
                RowRenderer(component: rowComp)
            } else {
                EmptyView()
            }
        }
    }
}

public struct TextRenderer: View {
    public let component: TextComponent
    
    public var body: some View {
        let alignStr = component.style?.align
        let textAlignment: TextAlignment = alignStr == "center" ? .center : (alignStr == "end" || alignStr == "right" ? .trailing : .leading)
        let frameAlignment: Alignment = alignStr == "center" ? .center : (alignStr == "end" || alignStr == "right" ? .trailing : .leading)

        Text(component.text)
            .font(.system(size: CGFloat(component.fontSize?.doubleValue ?? 16)))
            .foregroundColor(Color(hex: component.color ?? "#000000"))
            .multilineTextAlignment(textAlignment)
            // Expand to full width when align is set so alignment is visually visible
            .frame(maxWidth: alignStr != nil ? .infinity : nil, alignment: frameAlignment)
            .applySDUIStyle(component.style)
    }
}

public struct ButtonRenderer: View {
    public let component: ButtonComponent
    
    public var body: some View {
        Button(action: {
            print("Action: \(component.action)")
        }) {
            Text(component.label)
                .font(.system(size: 16, weight: .semibold))
                .padding(EdgeInsets(
                    top: CGFloat(component.style?.padding?.top?.doubleValue ?? 12),
                    leading: CGFloat(component.style?.padding?.left?.doubleValue ?? 24),
                    bottom: CGFloat(component.style?.padding?.bottom?.doubleValue ?? 12),
                    trailing: CGFloat(component.style?.padding?.right?.doubleValue ?? 24)
                ))
                .background(Color(hex: component.style?.backgroundColor ?? "#007AFF"))
                .foregroundColor(.white)
                .cornerRadius(CGFloat(Double(component.style?.round ?? "8") ?? 8))
        }
        .padding(EdgeInsets(
            top: CGFloat(component.style?.margin?.top?.doubleValue ?? 0),
            leading: CGFloat(component.style?.margin?.left?.doubleValue ?? 0),
            bottom: CGFloat(component.style?.margin?.bottom?.doubleValue ?? 0),
            trailing: CGFloat(component.style?.margin?.right?.doubleValue ?? 0)
        ))
    }
}

public struct ContainerRenderer: View {
    public let component: ContainerComponent
    
    public var body: some View {
        VStack(alignment: .leading) {
            SDUIRenderer(components: component.children)
        }
        .applySDUIStyle(component.style)
    }
}

public struct ColumnRenderer: View {
    public let component: ColumnComponent
    
    public var body: some View {
        let alignStr = component.style?.align
        let alignment = alignStr == "center" ? HorizontalAlignment.center : 
                        (alignStr == "end" || alignStr == "right" ? HorizontalAlignment.trailing : .leading)
        
        let arrangement = component.style?.arrangement
        let isSpaceBetween = arrangement == "space-between"
        let isSpaceAround = arrangement == "space-around" || arrangement == "space-evenly"
        let hasSpacers = isSpaceBetween || isSpaceAround

        // Only add surrounding spacers when explicitly requested (not default)
        let spacerTop = isSpaceAround || arrangement == "center" || arrangement == "end"
        let spacerBottom = isSpaceAround || arrangement == "center" || arrangement == "start"

        let content = VStack(alignment: alignment, spacing: hasSpacers ? nil : 10) {
            if spacerTop { Spacer(minLength: 0) }
            ForEach(0..<component.children.count, id: \.self) { index in
                SDUIComponentDispatcher(component: component.children[index])
                if index < component.children.count - 1 && hasSpacers {
                    Spacer(minLength: 0)
                }
            }
            if spacerBottom { Spacer(minLength: 0) }
        }
        
        if component.style?.scrollable == true {
            ScrollView { content }.applySDUIStyle(component.style)
        } else {
            content.applySDUIStyle(component.style)
        }
    }
}

public struct RowRenderer: View {
    public let component: RowComponent
    
    public var body: some View {
        let alignStr = component.style?.align
        let alignment = alignStr == "center" ? VerticalAlignment.center : 
                        (alignStr == "bottom" ? VerticalAlignment.bottom : .top)
        
        let arrangement = component.style?.arrangement
        let isSpaceBetween = arrangement == "space-between"
        let isSpaceAround = arrangement == "space-around" || arrangement == "space-evenly"
        let isCenterOrEnd = arrangement == "center" || arrangement == "end" || arrangement == "right"
        let hasSpacers = isSpaceBetween || isSpaceAround

        // For space-between/around: need full width, Spacers handle distribution
        // For center/end: leading Spacer, trailing Spacer respectively
        let spacerLeading = isSpaceAround || isCenterOrEnd
        let spacerTrailing = isSpaceAround || (arrangement == "center") || arrangement == nil || arrangement == "start"

        let content = HStack(alignment: alignment, spacing: hasSpacers ? nil : 10) {
            if spacerLeading { Spacer(minLength: 0) }
            ForEach(0..<component.children.count, id: \.self) { index in
                SDUIComponentDispatcher(component: component.children[index])
                if index < component.children.count - 1 && hasSpacers {
                    Spacer(minLength: 0)
                }
            }
            if spacerTrailing { Spacer(minLength: 0) }
        }
        // Spacers inside HStack only work if the HStack itself has full width
        .frame(maxWidth: hasSpacers || isCenterOrEnd ? .infinity : nil)
        
        if component.style?.scrollable == true {
            ScrollView(.horizontal) { content }.applySDUIStyle(component.style)
        } else {
            content.applySDUIStyle(component.style)
        }
    }
}

extension View {
    func applySDUIStyle(_ style: SDUIStyle?, overrideAlignment: Alignment? = nil) -> some View {
        guard let style = style else { return AnyView(self) }
        
        var view = AnyView(self)
        
        // 1. Padding (Inner spacing)
        if let p = style.padding {
            let edges = EdgeInsets(
                top: CGFloat(p.top?.doubleValue ?? 0),
                leading: CGFloat(p.left?.doubleValue ?? 0),
                bottom: CGFloat(p.bottom?.doubleValue ?? 0),
                trailing: CGFloat(p.right?.doubleValue ?? 0)
            )
            view = AnyView(view.padding(edges))
        }

        let alignStr = style.align
        let defaultAlignment: Alignment = alignStr == "center" ? .center : (alignStr == "end" || alignStr == "right" ? .trailing : .leading)
        let frameAlignment = overrideAlignment ?? defaultAlignment
        
        // 2. Dimensions (Frame) AFTER padding limits the background bounds
        let widthStr = style.width
        let heightStr = style.height
        let width = Double(widthStr ?? "")
        let height = Double(heightStr ?? "")
        
        if widthStr == "match_parent" || widthStr == "fill" {
            view = AnyView(view.frame(maxWidth: .infinity, alignment: frameAlignment))
        } else if let w = width {
            view = AnyView(view.frame(width: CGFloat(w), alignment: frameAlignment))
        }
        
        if heightStr == "match_parent" || heightStr == "fill" {
             view = AnyView(view.frame(maxHeight: .infinity, alignment: frameAlignment))
        } else if let h = height {
            view = AnyView(view.frame(height: CGFloat(h), alignment: frameAlignment))
        }

        // 3. Background (Fills the padded frame bounds)
        if let bgColor = style.backgroundColor {
            view = AnyView(view.background(Color(hex: bgColor)))
        }

        // 4. Corner Radius (Round) - Must be after background to clip it
        if let roundStr = style.round, let r = Double(roundStr) {
            view = AnyView(view.cornerRadius(CGFloat(r)))
        }

        // 5. Margin (Outer spacing outside of background clip)
        if let m = style.margin {
            let edges = EdgeInsets(
                top: CGFloat(m.top?.doubleValue ?? 0),
                leading: CGFloat(m.left?.doubleValue ?? 0),
                bottom: CGFloat(m.bottom?.doubleValue ?? 0),
                trailing: CGFloat(m.right?.doubleValue ?? 0)
            )
            view = AnyView(view.padding(edges))
        }
        
        return view
    }
}

// Helper for Color from Hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
