import { useEffect, useMemo, useState } from "react";
import { useMediaQuery } from "react-responsive";

export function useColorScheme() {
    const systemPrefersDark = useMediaQuery({ query: "(prefers-color-scheme: dark)" });

    // Load persisted preference from localStorage
    const [isDark, setIsDark] = useState(() => {
        const stored = localStorage.getItem("colorScheme");
        return stored ? JSON.parse(stored) : undefined;
    });

    // Determine active mode (user preference OR system)
    const value = useMemo(
        () => (isDark === undefined ? systemPrefersDark : isDark),
        [isDark, systemPrefersDark]
    );

    // Persist when user changes preference
    useEffect(() => {
        if (isDark !== undefined) {
            localStorage.setItem("colorScheme", JSON.stringify(isDark));
        }
    }, [isDark]);

    // Apply dark/light mode to body
    useEffect(() => {
        document.body.classList.toggle("dark", value);
    }, [value]);

    return { isDark: value, setIsDark };
}
