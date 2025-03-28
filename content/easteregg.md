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
    cursor: pointer !important;
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

@media screen and (max-width: 768px) {
    .button-container {
        flex-direction: column !important;
        align-items: center !important;
    }
    
    .easter-button {
        max-width: 80% !important;  /* Makes buttons wider on mobile */
    }
}
</style>

<script>
async function openRandomLongreadsArticle() {
  try {
    // Fetch the JSON file containing article links
    const response = await fetch('/data/longreads_articles.json');
    if (!response.ok) {
      throw new Error('Failed to load article list');
    }
    
    // Parse the JSON data
    const articles = await response.json();
    
    if (articles && articles.length > 0) {
      // Select a random article from the list
      const randomIndex = Math.floor(Math.random() * articles.length);
      const randomArticle = articles[randomIndex];
      
      // Open the article in a new tab
      window.open(randomArticle, '_blank');
    } else {
      console.error('No articles found in the JSON file');
      // Fallback to the original longreads random page
      window.open('https://longform.org/random', '_blank');
    }
  } catch (error) {
    console.error('Error loading random article:', error);
    // Fallback to the original longreads random page if there's an error
    window.open('https://longreads.com/', '_blank');
  }
}
</script>

<div class="button-container">
    <a href="/" class="easter-button">Return Home</a>
    <button onclick="openRandomLongreadsArticle()" class="easter-button">Read a Random Article</button>
    <a href="https://zoo.sandiegozoo.org/cams/ape-cam" class="easter-button">Ape Cam</a>
</div>

<div style="text-align: center;">
    <h2>Choose wisely! Enjoy some birds while you're here.</h2>
</div>
    <div style="display: flex; justify-content: center;">
        <iframe 
            width="600" 
            height="337" 
            src="https://www.youtube.com/embed/x10vL6_47Dw?autoplay=1&mute=1&playsinline=1" 
            frameborder="0" 
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
            allowfullscreen>
        </iframe>
    </div>


## The Random Article Button

At some point in March 2025, my favorite button on the entire internet, the "Get a Random Article" button on the [longform.org](https://web.archive.org/web/20250311104911/https://longform.org/) website, stopped working. The longform archive is [preserved in the wayback machine](https://web.archive.org/web/20250114190750/https://longform.org/sections), but the random button no longer works at all. In order to even slightly approximate that feature, I scraped the longreads.com website to compile a list of approximately 500 articles from their year-end lists. The random button now selects from this list. It is significantly worse, but it exists! The code to do everything is [in the repo](https://github.com/gsekeres/hugo_site), in the `scraper.py` file and the `content/easteregg.md` file. If you can figure out a better implementation, I'll love you forever.







