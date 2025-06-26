class ImageNoiseProcessor {
    constructor() {
        this.originalCanvas = document.getElementById('original-canvas');
        this.processedCanvas = document.getElementById('processed-canvas');
        this.originalCtx = this.originalCanvas.getContext('2d');
        this.processedCtx = this.processedCanvas.getContext('2d');
        
        this.setupEventListeners();
    }
    
    setupEventListeners() {
        const imageInput = document.getElementById('image-input');
        const keyInput = document.getElementById('key-input');
        const processBtn = document.getElementById('process-btn');
        const downloadBtn = document.getElementById('download-btn');
        const noiseStrength = document.getElementById('noise-strength');
        const noiseValue = document.getElementById('noise-value');
        
        imageInput.addEventListener('change', (e) => this.handleImageUpload(e));
        keyInput.addEventListener('input', () => this.updateProcessButton());
        processBtn.addEventListener('click', () => this.processImage());
        downloadBtn.addEventListener('click', () => this.downloadImage());
        noiseStrength.addEventListener('input', (e) => {
            noiseValue.textContent = e.target.value;
        });
    }
    
    handleImageUpload(event) {
        const file = event.target.files[0];
        if (!file) return;
        
        const reader = new FileReader();
        reader.onload = (e) => {
            const img = new Image();
            img.onload = () => {
                this.displayOriginalImage(img);
                this.updateProcessButton();
            };
            img.src = e.target.result;
        };
        reader.readAsDataURL(file);
    }
    
    displayOriginalImage(img) {
        // Set canvas size
        const maxWidth = 400;
        const maxHeight = 400;
        let { width, height } = img;
        
        if (width > maxWidth || height > maxHeight) {
            const ratio = Math.min(maxWidth / width, maxHeight / height);
            width *= ratio;
            height *= ratio;
        }
        
        this.originalCanvas.width = width;
        this.originalCanvas.height = height;
        this.processedCanvas.width = width;
        this.processedCanvas.height = height;
        
        // Draw original image
        this.originalCtx.drawImage(img, 0, 0, width, height);
        
        // Store image data
        this.imageData = this.originalCtx.getImageData(0, 0, width, height);
    }
    
    updateProcessButton() {
        const imageInput = document.getElementById('image-input');
        const keyInput = document.getElementById('key-input');
        const processBtn = document.getElementById('process-btn');
        
        processBtn.disabled = !imageInput.files[0] || !keyInput.value.trim();
    }
    
    processImage() {
        const mode = document.querySelector('input[name="mode"]:checked').value;
        const key = document.getElementById('key-input').value.trim();
        const noiseStrength = parseFloat(document.getElementById('noise-strength').value);
        
        if (!this.imageData) return;
        
        const processedData = new ImageData(
            new Uint8ClampedArray(this.imageData.data),
            this.imageData.width,
            this.imageData.height
        );
        
        if (mode === 'encode') {
            this.addNoise(processedData, key, noiseStrength);
        } else {
            this.removeNoise(processedData, key, noiseStrength);
        }
        
        this.processedCtx.putImageData(processedData, 0, 0);
        document.querySelector('.noise-download-section').style.display = 'block';
    }
    
    addNoise(imageData, key, strength) {
        const seed = this.hashCode(key);
        const rng = this.seededRandom(seed);
        
        for (let i = 0; i < imageData.data.length; i += 4) {
            const noise = (rng() - 0.5) * 2 * strength * 255;
            
            imageData.data[i] = Math.max(0, Math.min(255, imageData.data[i] + noise));     // R
            imageData.data[i + 1] = Math.max(0, Math.min(255, imageData.data[i + 1] + noise)); // G
            imageData.data[i + 2] = Math.max(0, Math.min(255, imageData.data[i + 2] + noise)); // B
            // Alpha channel (i + 3) remains unchanged
        }
    }
    
    removeNoise(imageData, key, strength) {
        const seed = this.hashCode(key);
        const rng = this.seededRandom(seed);
        
        for (let i = 0; i < imageData.data.length; i += 4) {
            const noise = (rng() - 0.5) * 2 * strength * 255;
            
            imageData.data[i] = Math.max(0, Math.min(255, imageData.data[i] - noise));     // R
            imageData.data[i + 1] = Math.max(0, Math.min(255, imageData.data[i + 1] - noise)); // G
            imageData.data[i + 2] = Math.max(0, Math.min(255, imageData.data[i + 2] - noise)); // B
            // Alpha channel (i + 3) remains unchanged
        }
    }
    
    hashCode(str) {
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32-bit integer
        }
        return Math.abs(hash);
    }
    
    seededRandom(seed) {
        let m = 0x80000000; // 2**31
        let a = 1103515245;
        let c = 12345;
        let state = seed ? seed : Math.floor(Math.random() * (m - 1));
        
        return function() {
            state = (a * state + c) % m;
            return state / (m - 1);
        };
    }
    
    downloadImage() {
        const link = document.createElement('a');
        link.download = 'processed-image.png';
        link.href = this.processedCanvas.toDataURL();
        link.click();
    }
}

// Initialize the tool when the page loads
document.addEventListener('DOMContentLoaded', () => {
    new ImageNoiseProcessor();
}); 