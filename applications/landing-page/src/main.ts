import './style.css';

let fadeOutTimeout: number;

document.addEventListener('mousemove', (event) => {
    const shadowDiv = document.querySelector('.shadow') as HTMLElement;
    if (!shadowDiv) {
        return;
    }

    // Reset the fade-out timer
    clearTimeout(fadeOutTimeout);

    // Show the shadow and move it to the cursor position
    shadowDiv.style.opacity = '1';
    shadowDiv.style.left = `${event.pageX - 75}px`;
    shadowDiv.style.top = `${event.pageY - 75}px`;

    // Set a timer to fade out the shadow after 1 second of inactivity
    fadeOutTimeout = window.setTimeout(() => {
        shadowDiv.style.opacity = '0';
    }, 50);
});
