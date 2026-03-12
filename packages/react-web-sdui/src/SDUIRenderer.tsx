import React from 'react';
import { 
    SDUIComponent, TextComponent, ButtonComponent, 
    ContainerComponent, ColumnComponent, RowComponent,
    SDUIStyle 
} from 'shared';

interface SDUIRendererProps {
    components: SDUIComponent[] | any;
}

const getCSSStyle = (style?: SDUIStyle | null): React.CSSProperties => {
    if (!style) return {};

    const css: React.CSSProperties = {};

    // Background
    if (style.backgroundColor) {
        css.backgroundColor = style.backgroundColor;
    }

    // Dimensions
    if (style.width === 'match_parent' || style.width === 'fill') {
        css.width = '100%';
        css.boxSizing = 'border-box'; // include padding in width
    } else if (style.width && !isNaN(Number(style.width))) {
        css.width = `${style.width}px`;
        css.boxSizing = 'border-box';
    }

    if (style.height === 'match_parent' || style.height === 'fill') {
        css.height = '100%';
    } else if (style.height && !isNaN(Number(style.height))) {
        css.height = `${style.height}px`;
    }

    // Scrollable
    if (style.scrollable) {
        css.overflow = 'auto';
    }

    const parseSpacing = (spacingObj: any) => {
        if (!spacingObj) return undefined;
        return `${spacingObj.top ?? 0}px ${spacingObj.right ?? 0}px ${spacingObj.bottom ?? 0}px ${spacingObj.left ?? 0}px`;
    };

    // Padding
    if (style.padding) {
        css.padding = parseSpacing(style.padding);
        if (!css.boxSizing) css.boxSizing = 'border-box'; // prevent padding from adding to width
    }

    // Margin
    if (style.margin) {
        css.margin = parseSpacing(style.margin);
    }

    // Round
    if (style.round && !isNaN(Number(style.round))) {
        css.borderRadius = `${style.round}px`;
    }

    return css;
};

export const SDUIRenderer: React.FC<SDUIRendererProps> = ({ components }) => {
    const componentList = Array.isArray(components) ? components : [];

    return (
        <>
            {componentList.map((component, index) => (
                <SDUIComponentDispatcher key={index} component={component} />
            ))}
        </>
    );
};

const SDUIComponentDispatcher: React.FC<{ component: SDUIComponent }> = ({ component }) => {
    if (component instanceof TextComponent) {
        return <TextRenderer component={component} />;
    } else if (component instanceof ButtonComponent) {
        return <ButtonRenderer component={component} />;
    } else if (component instanceof ContainerComponent) {
        return <ContainerRenderer component={component} />;
    } else if (component instanceof ColumnComponent) {
        return <ColumnRenderer component={component} />;
    } else if (component instanceof RowComponent) {
        return <RowRenderer component={component} />;
    }
    return null;
};

const TextRenderer: React.FC<{ component: TextComponent }> = ({ component }) => {
    const style = getCSSStyle(component.style);
    
    let textAlign: any = 'left';
    if (component.style?.align === 'center') textAlign = 'center';
    else if (component.style?.align === 'end') textAlign = 'right';

    return (
        <span style={{
            fontSize: component.fontSize ? `${component.fontSize}px` : '16px',
            color: component.color || 'black',
            textAlign: textAlign,
            display: 'block',
            ...style
        }}>
            {component.text}
        </span>
    );
};

const ButtonRenderer: React.FC<{ component: ButtonComponent }> = ({ component }) => {
    const style = getCSSStyle(component.style);
    return (
        <button 
            style={{ 
                padding: component.style?.padding ? style.padding : '12px 24px',
                backgroundColor: component.style?.backgroundColor ? style.backgroundColor : '#007AFF',
                color: 'white',
                border: 'none',
                borderRadius: component.style?.round ? style.borderRadius : '8px',
                cursor: 'pointer',
                fontWeight: '600',
                fontSize: '16px',
                margin: style.margin, 
                width: style.width,
                height: style.height
            }}
            onClick={() => console.log(`Action: ${component.action}`)}
        >
            {component.label}
        </button>
    );
};

const ContainerRenderer: React.FC<{ component: ContainerComponent }> = ({ component }) => {
    const style = getCSSStyle(component.style);
    return (
        <div style={{ 
            display: 'flex', 
            flexDirection: 'column', 
            paddingLeft: '16px', 
            ...style 
        }}>
            <SDUIRenderer components={(component as any).childrenArray || []} />
        </div>
    );
};

const ColumnRenderer: React.FC<{ component: ColumnComponent }> = ({ component }) => {
    const style = getCSSStyle(component.style);
    
    const alignmentMap: Record<string, string> = { 'center': 'center', 'end': 'flex-end', 'start': 'flex-start' };
    const arrangementMap: Record<string, string> = { 
        'center': 'center', 
        'end': 'flex-end', 
        'space-around': 'space-around', 
        'space-between': 'space-between', 
        'space-evenly': 'space-evenly' 
    };

    return (
        <div style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: alignmentMap[component.style?.align || ''] || 'flex-start',
            justifyContent: arrangementMap[component.style?.arrangement || ''] || 'flex-start',
            ...style,
            gap: style.gap || '8px',
        }}>
            <SDUIRenderer components={(component as any).childrenArray || []} />
        </div>
    );
};

const RowRenderer: React.FC<{ component: RowComponent }> = ({ component }) => {
    const style = getCSSStyle(component.style);
    
    const alignmentMap: Record<string, string> = { 'center': 'center', 'bottom': 'flex-end', 'top': 'flex-start' };
    const arrangementMap: Record<string, string> = { 
        'center': 'center', 
        'end': 'flex-end', 
        'space-around': 'space-around', 
        'space-between': 'space-between', 
        'space-evenly': 'space-evenly' 
    };

    return (
        <div style={{
            display: 'flex',
            flexDirection: 'row',
            alignItems: alignmentMap[component.style?.align || ''] || 'flex-start',
            justifyContent: arrangementMap[component.style?.arrangement || ''] || 'flex-start',
            ...style,
            gap: style.gap || '8px',
        }}>
            <SDUIRenderer components={(component as any).childrenArray || []} />
        </div>
    );
};
