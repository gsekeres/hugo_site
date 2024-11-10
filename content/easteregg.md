---
title: "Hi!"
layout: "easteregg"
url: "/easteregg/"
summary: "easter egg"
hidemeta: true
---

Hi! Thanks for clicking on me! I hope you enjoyed the experience. You have three options:

<style>
@keyframes bounce {
    0%, 100% { transform: translateY(0); }
    50% { transform: translateY(-5px); }
}

.easter-button {
    display: flex !important;
    align-items: center !important;
    justify-content: center !important;
    padding: 20px !important;
    background-color: #f0f0f0 !important;
    color: var(--primary) !important;
    text-decoration: none !important;
    border-radius: 5px !important;
    flex: 1 !important;
    text-align: center !important;
    max-width: 250px !important;
    min-height: 70px !important;
    transition: all 0.2s ease !important;
    border: 1px solid var(--border) !important;
    box-shadow: 0 1px 3px rgba(0,0,0,0.1) !important;
    margin: 0 !important;
}

.easter-button:hover {
    animation: bounce 0.5s ease infinite;
    background-color: #e0e0e0 !important;
}

.button-container {
    display: flex !important;
    justify-content: center !important;
    gap: 20px !important;
    margin-top: 20px !important;
    width: 100% !important;
}
</style>

<div class="button-container">
    <a href="/" class="easter-button">Return Home</a>
    <a href="https://longform.org/random" class="easter-button">Read a Random Article</a>
    <a href="https://zoo.sandiegozoo.org/cams/ape-cam" class="easter-button">Ape Cam</a>
</div>

## Choose wisely!