const loadComponent = async (selector: string, file: string) => {
    try {
        const response = await fetch(file);
        if (!response.ok) throw new Error(`Failed to load ${file}`);
        const html = await response.text();
        document.querySelector(selector)!.innerHTML = html;
    } catch (error) {
        console.error(error);
    }
};

// Load the navbar and footer on all pages
loadComponent("#navbar", "/src/components/navbar.html");
loadComponent("#footer", "/src/components/footer.html");
