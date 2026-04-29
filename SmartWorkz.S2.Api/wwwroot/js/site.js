// SmartWorkz S2 Site JavaScript

// Carousel Component
function carousel() {
    return {
        currentSlide: 0,
        slides: 6,

        init() {
            setInterval(() => {
                this.currentSlide = (this.currentSlide + 1) % this.slides;
            }, 5000);
        },

        goToSlide(index) {
            this.currentSlide = index;
        }
    };
}

// Page initialization
document.addEventListener('DOMContentLoaded', function() {
    console.log('SmartWorkz S2 loaded');
});
