import { createElement } from '@lwc/engine-dom';
import CommonAccordion from 'c/commonAccordion';

describe('c-common-accordion', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('renders the accordion component', () => {
        // Arrange
        const element = createElement('c-common-accordion', {
            is: CommonAccordion
        });
        element.title = 'Test Accordion';

        // Act
        document.body.appendChild(element);

        // Assert
        const header = element.shadowRoot.querySelector('.accordion-header');
        expect(header).not.toBeNull();
        expect(header.textContent).toContain('Test Accordion');
    });

    it('displays the title correctly', () => {
        // Arrange
        const element = createElement('c-common-accordion', {
            is: CommonAccordion
        });
        element.title = 'My Section Title';

        // Act
        document.body.appendChild(element);

        // Assert
        const titleElement = element.shadowRoot.querySelector('h3');
        expect(titleElement).not.toBeNull();
        expect(titleElement.textContent).toBe('My Section Title');
    });

    it('is expanded by default when isCollapsedByDefault is false', () => {
        // Arrange
        const element = createElement('c-common-accordion', {
            is: CommonAccordion
        });
        element.title = 'Test';
        element.isCollapsedByDefault = false;

        // Act
        document.body.appendChild(element);

        // Assert
        return Promise.resolve().then(() => {
            const content = element.shadowRoot.querySelector('.accordion-content');
            expect(content).not.toBeNull();
            const icon = element.shadowRoot.querySelector('lightning-icon');
            expect(icon.getAttribute('icon-name')).toBe('utility:chevronup');
        });
    });

    it('is collapsed by default when isCollapsedByDefault is true', () => {
        // Arrange
        const element = createElement('c-common-accordion', {
            is: CommonAccordion
        });
        element.title = 'Test';
        element.isCollapsedByDefault = true;

        // Act
        document.body.appendChild(element);

        // Assert
        return Promise.resolve().then(() => {
            const content = element.shadowRoot.querySelector('.accordion-content');
            expect(content).toBeNull();
            const icon = element.shadowRoot.querySelector('lightning-icon');
            expect(icon.getAttribute('icon-name')).toBe('utility:chevrondown');
        });
    });

    it('toggles expanded state on click', () => {
        // Arrange
        const element = createElement('c-common-accordion', {
            is: CommonAccordion
        });
        element.title = 'Test';
        element.isCollapsedByDefault = true;
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            // Initially collapsed
            let content = element.shadowRoot.querySelector('.accordion-content');
            expect(content).toBeNull();

            // Act - Click to expand
            const header = element.shadowRoot.querySelector('.accordion-header');
            header.click();

            // Assert - Should be expanded
            return Promise.resolve().then(() => {
                content = element.shadowRoot.querySelector('.accordion-content');
                expect(content).not.toBeNull();
                const icon = element.shadowRoot.querySelector('lightning-icon');
                expect(icon.getAttribute('icon-name')).toBe('utility:chevronup');
            });
        });
    });

    it('toggles expanded state on Enter key press', () => {
        // Arrange
        const element = createElement('c-common-accordion', {
            is: CommonAccordion
        });
        element.title = 'Test';
        element.isCollapsedByDefault = true;
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            // Initially collapsed
            let content = element.shadowRoot.querySelector('.accordion-content');
            expect(content).toBeNull();

            // Act - Press Enter key
            const header = element.shadowRoot.querySelector('.accordion-header');
            const keyDownEvent = new KeyboardEvent('keydown', {
                key: 'Enter',
                bubbles: true,
                cancelable: true
            });
            header.dispatchEvent(keyDownEvent);

            // Assert - Should be expanded
            return Promise.resolve().then(() => {
                content = element.shadowRoot.querySelector('.accordion-content');
                expect(content).not.toBeNull();
            });
        });
    });

    it('toggles expanded state on Space key press', () => {
        // Arrange
        const element = createElement('c-common-accordion', {
            is: CommonAccordion
        });
        element.title = 'Test';
        element.isCollapsedByDefault = true;
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            // Initially collapsed
            let content = element.shadowRoot.querySelector('.accordion-content');
            expect(content).toBeNull();

            // Act - Press Space key
            const header = element.shadowRoot.querySelector('.accordion-header');
            const keyDownEvent = new KeyboardEvent('keydown', {
                key: ' ',
                bubbles: true,
                cancelable: true
            });
            header.dispatchEvent(keyDownEvent);

            // Assert - Should be expanded
            return Promise.resolve().then(() => {
                content = element.shadowRoot.querySelector('.accordion-content');
                expect(content).not.toBeNull();
            });
        });
    });

    it('renders slot content when expanded', () => {
        // Arrange
        const element = createElement('c-common-accordion', {
            is: CommonAccordion
        });
        element.title = 'Test';
        element.isCollapsedByDefault = false;

        // Add slot content
        const slotContent = document.createElement('div');
        slotContent.textContent = 'Slot Content';
        slotContent.slot = '';
        element.appendChild(slotContent);

        // Act
        document.body.appendChild(element);

        // Assert
        return Promise.resolve().then(() => {
            const content = element.shadowRoot.querySelector('.accordion-content');
            expect(content).not.toBeNull();
            const slot = element.shadowRoot.querySelector('slot');
            expect(slot).not.toBeNull();
        });
    });

    it('updates icon based on expanded state', () => {
        // Arrange
        const element = createElement('c-common-accordion', {
            is: CommonAccordion
        });
        element.title = 'Test';
        element.isCollapsedByDefault = true;
        document.body.appendChild(element);

        return Promise.resolve().then(() => {
            // Initially collapsed - chevron down
            let icon = element.shadowRoot.querySelector('lightning-icon');
            expect(icon.getAttribute('icon-name')).toBe('utility:chevrondown');

            // Act - Expand
            const header = element.shadowRoot.querySelector('.accordion-header');
            header.click();

            // Assert - chevron up
            return Promise.resolve().then(() => {
                icon = element.shadowRoot.querySelector('lightning-icon');
                expect(icon.getAttribute('icon-name')).toBe('utility:chevronup');
            });
        });
    });
});

