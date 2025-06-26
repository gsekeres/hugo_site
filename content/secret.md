---
title: "Decoder"
date: 1963-11-22
lastmod: 1963-11-22
tags: []
author: ["Gabriel Sekeres"]
description: ""
summary: ""
---

1. Choose whether you want to **encode** (add noise) or **decode** (remove noise)
2. Upload your image (supports JPG, PNG, GIF, WebP)
3. Enter your secret key
4. Click the process button
5. View or Download the result

<div class="noise-tool-container">
    <div class="noise-tool-controls">
        <div class="noise-mode-selector">
            <label>
                <input type="radio" name="mode" value="encode" checked>
                <span>Encode (Add Noise)</span>
            </label>
            <label>
                <input type="radio" name="mode" value="decode">
                <span>Decode (Remove Noise)</span>
            </label>
        </div>
        <div class="noise-file-upload">
            <label for="image-input">Choose Image:</label>
            <input type="file" id="image-input" accept="image/*">
        </div>
        <div class="noise-key-input">
            <label for="key-input">Secret Key:</label>
            <input type="text" id="key-input" placeholder="Enter your secret key">
        </div>
        <div class="noise-controls">
            <label for="noise-strength">Noise Strength:</label>
            <input type="range" id="noise-strength" min="0.1" max="2.0" step="0.1" value="0.5">
            <span id="noise-value" class="noise-value">0.5</span>
        </div>
        <button id="process-btn" class="noise-process-btn" disabled>Process Image</button>
    </div>
    <div class="noise-image-display">
        <div class="noise-image-container">
            <h3>Original Image</h3>
            <canvas id="original-canvas"></canvas>
        </div>
        <div class="noise-image-container">
            <h3>Processed Image</h3>
            <canvas id="processed-canvas"></canvas>
        </div>
    </div>
    <div class="noise-download-section" style="display: none;">
        <button id="download-btn" class="noise-download-btn">Download Processed Image</button>
    </div>
</div> 