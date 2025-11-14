import { useEffect, useRef, useState } from "react";

function AutoFitText({ text, maxWidth, maxFontSize, y, x, anchor = "middle", className }) {
    const textRef = useRef();
    const [fontSize, setFontSize] = useState(maxFontSize);

    useEffect(() => {
        if (!textRef.current) return;

        let size = maxFontSize;
        textRef.current.setAttribute("font-size", size);

        while (textRef.current.getBBox().width > maxWidth && size > 1) {
            size -= 1;
            textRef.current.setAttribute("font-size", size);
        }

        setFontSize(size);
    }, [text, maxWidth, maxFontSize]);

    return (
        <text
            ref={textRef}
            x={x}
            y={y}
            fontSize={fontSize}
            textAnchor={anchor}
            className={className}
        >
            {text}
        </text>
    );
}

export default AutoFitText